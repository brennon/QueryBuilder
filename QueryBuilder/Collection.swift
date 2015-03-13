//
//  Collection.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 11/17/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import Foundation

extension String {
    func isPrefixOf(longerString: String) -> Bool {
        return longerString =~ "\(self)\\.+"
    }
}

class Collection {
    
    let collectionName: String
    let databaseName: String
    let connection: MongoConnection!
    var fields = NSMutableDictionary()
    var allKeyPaths = [String]()
    var keyPathSet = Set<String>()
    
    init(name: String, inDatabase: String) {
        
        collectionName = name
        databaseName = inDatabase
        
        let dbHelper = DatabaseHelper()
        dbHelper.authenticateToDatabase()
        
        connection = dbHelper.connection
    }

    /**
        Iterate over documents in a collection and build a dict of fields.
    
        :param: limit Limit the numer of documents to examine when building the 
            dict of fields. If `limit` is 0, all documents will be examined.
    */
    func enumerateFieldNames(limit: Int) {
        
        let start = NSDate()
        
        // Get collection for this collection's name
        let qualifiedName = "\(databaseName).\(collectionName)"
        let collection: MongoDBCollection =
        connection.collectionWithName(qualifiedName)
        
        // Error object for database operations
        var error : NSError? = nil
        error = nil
        
        // Mongo predicate for finding documents
        let findRequest = MongoFindRequest()
        
        // If a limit > 0 was specified, use it
        if limit > 0 {
            findRequest.limitResults = Int32(limit)
        }
        
        // Get a cursor for the request
        let cursor = collection.cursorForFindRequest(findRequest, error: &error)
        
        if let error = error {
            println("Error performing find request: \(error.description)")
        }
        
        // Iterate over documents
        var total: Int = 0
        while let document : BSONDocument = cursor?.nextObject() {
            
            total++
            
            // Add the fields in this document to the fields dictionary
            enumerateFieldNamesInDocument(
                document,
                atPath: ""
            )
        }
        
        let end = NSDate()
        let timeInterval = end.timeIntervalSinceDate(start)
        
        print("Enumerated fields from \(total) documents ")
        println("in \(timeInterval) seconds")
        
        buildBaseDictionaryForKeyPaths()
        filterLeafKeyPaths()
    }
    
    func filterLeafKeyPaths() {
        
        // Get copy of key paths
        var keyPaths = keyPathSet.items()
        var keyPathsToRemove = [String]()
        
        // Iterate over key paths
        for keyPath in keyPaths {
            
            // Key paths are in alphabetical order. If a key path that comes 
            // first is a prefix of any of the remaining key paths, add it to 
            // the list of key paths to remove.
            let suffixes = keyPaths.filter {
                return keyPath.isPrefixOf($0)
            }
            
            if suffixes.count > 0 {
                keyPathsToRemove.append(keyPath)
            }
        }
        
        for keyPath in keyPathsToRemove {
            keyPathSet.remove(keyPath)
        }
    }
    
    /**
        Enumerates the fields in a specific document using a keyPath as context.
        
        :param: document The `BSONDocument` for which to enumerate fields.
        :param: atPath The keyPath to use as context. This is used when storing
        the field in the `fields` dictionary.
    */
    func enumerateFieldNamesInDocument(
        document: BSONDocument,
        atPath path: String) {

        // Regex for property names (only word characters)
        let regex = NSRegularExpression(
            pattern: "^[a-zA-Z0-9_]+$",
            options: nil,
            error: nil
        )

        // Iterate over document keys
        let iterator = document.iterator()
        
        while iterator.hasMore() {

            // Get next field
            iterator.next()

            if let key = iterator.key() {

                // Count number of regex matches
                var matchCount = regex!.numberOfMatchesInString(
                    key,
                    options: nil,
                    range: NSMakeRange(0, countElements(key))
                )

                // If we have one match
                if matchCount == 1 {

                    var expandedKeyPath: String

                    // Build dot-delimited key path
                    if path != "" {

                        expandedKeyPath = "\(path).\(key)"

                    } else {

                        expandedKeyPath = key
                        
                    }
                    
                    // Add keyPath to set
                    keyPathSet.add(expandedKeyPath)

                    // If this is a subdocument or an array, add the keypath
                    // and then recurse on the subdocument
                    if iterator.isEmbeddedDocument() || iterator.isArray() {

                        var embeddedDocument = iterator.embeddedDocumentValue()

                        enumerateFieldNamesInDocument(
                            embeddedDocument,
                            atPath: expandedKeyPath
                        )
                    }
                }
            }
        }
    }
    
    /**
        Helper method to build the base dictionary in `fields` based on the 
        key paths in `keyPathSet`.
    
        This method builds a nested `NSMutableDictionary` of other 
        `NSDictionary` objects such that all key paths in `keyPathSet` are 
        available as key paths in `fields`.
    */
    func buildBaseDictionaryForKeyPaths() {
        for keyPath in keyPathSet.items() {
            fields.setValue(NSMutableDictionary(), forKeyPath: keyPath)
        }
    }
    
    /**
        Populates the dictionaries in `fields` by repetedly calling
        `getDitinctValuesForField(_:) for each key path in `keyPathSet`.
    */
    func getDistinctValuesForAllFields() {
        for keyPath in keyPathSet.items() {
            getDistinctValuesForField(keyPath)
        }
    }
    
    // FIXME: Need to set NULLs to nil

    /**
        Populates the corresponding dictionary in `fields` for the a specific 
        key path with information about distinct, maximum, minimum values, etc.
    
        :param: keyPath The key path for which to retrieve data from the 
            database and populate a dictionary.
    */
    func getDistinctValuesForField(keyPath: String) {
        
        println("\(keyPath)")
        
        // Build command for getting distinct values for a field
        let commandDictionary = [
            MongoDBCommandDictKey:["distinct": collectionName], "key": keyPath
        ]
        
        var error: NSError?
        
        let integerRegex = NSRegularExpression(
            pattern: "^\\d+$",
            options: nil,
            error: nil
        )!
        
        // If command is successful
        if let result = connection.runCommandWithDictionary(
            commandDictionary,
            onDatabaseName: databaseName,
            error: &error) {

            // If returned result has a 'values' property
            if result.indexForKey("values") != nil {

                // If values is an array
                if let resultArray = result["values"] as? [AnyObject] {
                    
                    // If array has at least one entry
                    if resultArray.count > 0 {
                        
                        // Filter nulls from result array
                        var filteredResult = resultArray.filter {
                            !($0 is NSNull)
                        }
                        
                        println("type: \(_stdlib_getTypeName(filteredResult[0]))")
                        
                        // Switch on the first entry in the array
                        let typeString = _stdlib_getTypeName(filteredResult[0])
                        
                        switch typeString {
                        
                        // If type is String
                        case "__NSCFString":
                            
                            // Cast array to [String] and sort it
                            var stringArray = filteredResult as [String]
                            
                            stringArray.sort {
                                $0 < $1
                            }
                            
                            // Assign casted array to main dict
                            fields.setValue(stringArray, forKeyPath: "\(keyPath).values")
                            fields.setValue("string", forKeyPath: "\(keyPath).type")
                            fields.setValue("\(keyPath)", forKeyPath: "\(keyPath).keyPath")
                            
                        case "__NSCFNumber":
                            
                            // Test for Int vs Double
                            let asString = filteredResult[0].stringValue
                            
                            let intMatches = integerRegex.numberOfMatchesInString(
                                asString,
                                options: nil,
                                range: NSMakeRange(0, countElements(asString))
                            )
                            
                            // If it was an Integer
                            if intMatches == 1 {
                                
                                // Cast array to [Int] and sort it
                                var intArray = filteredResult as [Int]
                                
                                intArray.sort {
                                    $0 < $1
                                }
                                
                                // Assign casted array to main dict
                                fields.setValue(intArray, forKeyPath: "\(keyPath).values")
                                fields.setValue(intArray.first, forKeyPath: "\(keyPath).min")
                                fields.setValue(intArray.last, forKeyPath: "\(keyPath).max")
                                fields.setValue("int", forKeyPath: "\(keyPath).type")
                                fields.setValue("\(keyPath)", forKeyPath: "\(keyPath).keyPath")
                                
                            } else {
                                
                                // Cast array to [Double] and sort it
                                var doubleArray = filteredResult as [Double]
                                
                                doubleArray.sort {
                                    $0 < $1
                                }
                                
                                // Assign casted array to main dict
                                fields.setValue(doubleArray, forKeyPath: "\(keyPath).values")
                                fields.setValue(doubleArray.first, forKeyPath: "\(keyPath).min")
                                fields.setValue(doubleArray.last, forKeyPath: "\(keyPath).max")
                                fields.setValue("double", forKeyPath: "\(keyPath).type")
                                fields.setValue("\(keyPath)", forKeyPath: "\(keyPath).keyPath")
                            }
                            
                        case "__NSCFBoolean":
                            
                            // Cast array to [Bool]
                            var boolArray = filteredResult as [Bool]
                            
                            // Assign casted array to main dict
                            fields.setValue(boolArray, forKeyPath: "\(keyPath).values")
                            fields.setValue("boolean", forKeyPath: "\(keyPath).type")
                            fields.setValue("\(keyPath)", forKeyPath: "\(keyPath).keyPath")

                        case "BSONObjectID":
                            
                            // Create a sorted array of string representations
                            var oidArray = filteredResult as [BSONObjectID]
                            
                            var stringArray = oidArray.map({
                                (objectId: BSONObjectID) -> String in
                                    return objectId.stringValue()
                            })
                            
                            stringArray.sort {
                                $0 < $1
                            }
                            
                            // Assign casted array to main dict
                            fields.setValue(stringArray, forKeyPath: "\(keyPath).values")
                            fields.setValue("BSONObjectID", forKeyPath: "\(keyPath).type")
                            fields.setValue("\(keyPath)", forKeyPath: "\(keyPath).keyPath")

                        case "__NSTaggedDate":
                            
                            // Cast array to [NSDate]
                            var dateArray = filteredResult as [NSDate]
                            
                            dateArray.sort {
                                $0.timeIntervalSinceDate($1) < 1 ? true : false
                            }
                            
                            // Assign casted array to main dict
                            fields.setValue(dateArray, forKeyPath: "\(keyPath).values")
                            fields.setValue(dateArray.first, forKeyPath: "\(keyPath).min")
                            fields.setValue(dateArray.last, forKeyPath: "\(keyPath).max")
                            fields.setValue("datetime", forKeyPath: "\(keyPath).type")
                            fields.setValue("\(keyPath)", forKeyPath: "\(keyPath).keyPath")
                            
                        default:
                            println("Didn't handle values for \(keyPath)")
                            println("Type was \(typeString)")
                            println("First entry in array: \(filteredResult[0])")
                        }
                    }
                }
            
            // Otherwise, there was no 'values' property, so delete this
            // dictionary
//            } else {
//                
//                fields.setValue(nil, forKeyPath: keyPath)
            }
        }
    }
    
    func stripNullValuesFromArray(inout arr: [AnyObject]) {
        
        arr.filter {
            !($0 is NSNull)
        }
    }
}

// 2014-12-12T10:10:25.945-0500 [conn171] command eim.$cmd command: isMaster { key: "metadata.location", distinct: "trials" } ntoreturn:1 keyUpdates:0 numYields:0  reslen:138 0ms

// 2014-12-12T10:11:54.556-0500 [conn69] command eim.$cmd command: distinct { distinct: "trials", key: "metadata.location" } keyUpdates:0 numYields:0 locks(micros) r:606 reslen:210 0ms
