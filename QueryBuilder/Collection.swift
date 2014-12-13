//
//  Collection.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 11/17/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import Foundation

/**
    The `MongoCredentials` struct provides useful information for connecting to 
    a MongoDB database.
*/
struct MongoCredentials {
    static let hostname = "localhost"
    static let port = "28017"
    static let authenticationDatabase = "eim"
    static let authenticationUsername = "eim"
    static let authenticationPassword = "eim"
    static var url: String {
        get {
            return "\(hostname):\(port)"
        }
    }
}

/**
    The `DatabaseHelper` contains helper methods to work in conjunction with 
    the `MongoCredentials` struct to connect to a MongoDB instance, to 
    authenticate against it, etc.
*/
class DatabaseHelper {
    
    /// The `MongoConnection` opened and maintained by a `DatabaseHelper`.
    let connection : MongoConnection? = nil
    
    /*!
        Authenticates against the database with the credentials contained in 
        `MongoCredentials.`
    
        :returns: It returns `true` if authentication was sucessful. Otherwise, 
        it returns `false`.
    */
    func authenticateToDatabase() -> Bool {
        
        if connection == nil {
            println("Not connected to database");
            return false
        }
        
        // Check for error
        var error : NSError? = nil
        
        connection?.authenticate(MongoCredentials.authenticationDatabase,
            username: MongoCredentials.authenticationUsername,
            password: MongoCredentials.authenticationPassword,
            error: &error)
        
        if let error = error {
            print("Error authenticating to database: ")
            println("\(error.localizedDescription)")
            return false
        } else {
            return true
        }
    }
    
    /**
        Opens a connection to the database described by `MongoCredentials`.
    */
    init() {
        var error : NSError? = nil
        
        // Connect to the provided connection, or create a new one using 
        // MongoCredentials
        connection = MongoConnection(
            forServer: MongoCredentials.url,
            error: &error
        )
        
        if let error = error {
            print("Error connecting to database: ")
            println("\(error.localizedDescription)")
        }
    }
}

class Collection {
    
    let collectionName: String
    let databaseName: String
    let connection: MongoConnection!
    var fields = NSMutableDictionary()
    var allKeyPaths = [String]()
    
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
        var total : Int = 0
        while let document : BSONDocument = cursor?.nextObject() {
            
            total++
            
            // Add the fields in this document to the fields dictionary
            enumerateFieldsInDocument(
                document,
                atPath: "",
                withParentDictionary: fields
            )
        }
        
        let end = NSDate()
        let timeInterval = end.timeIntervalSinceDate(start)
        
        print("Enumerated fields from \(total) documents ")
        println("in \(timeInterval) seconds")
    }
    
    /**
        Enumerates the fields in a specific document using a keyPath as context.
    
        :param: document The `BSONDocument` for which to enumerate fields.
        :param: atPath The keyPath to use as context. This is used when storing 
            the field in the `fields` dictionary.
    */
    func enumerateFieldsInDocument(
        document: BSONDocument,
        atPath path: String,
        withParentDictionary parentDictionary: NSMutableDictionary) {
        
        // Regex for property names (only word characters)
        let regex = NSRegularExpression(
            pattern: "^\\w+$",
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
                    
                    var expandedKey: String
                    
                    // Build dot-delimited key path
                    if path != "" {
                        
                        expandedKey = "\(path).\(key)"
                        
                    } else {
                        
                        expandedKey = key
                        
                    }
                    
                    // If this is a subdocument or an array
                    if iterator.isEmbeddedDocument() || iterator.isArray() {
                        
                        var subdictionary = NSMutableDictionary()
                        
                        fields.setValue(subdictionary, forKeyPath: expandedKey)
                    
                        enumerateFieldsInDocument(
                            iterator.embeddedDocumentValue(),
                            atPath: expandedKey,
                            withParentDictionary: subdictionary
                        )
                    
                    // Otherwise, store the key
                    } else {
                        
                        let existingDict = fields.valueForKeyPath(expandedKey) as? NSMutableDictionary
                        
                        if existingDict == nil {
                            
                            fields.setValue(NSMutableDictionary(), forKeyPath: expandedKey)
                            
                            // Add keypath to master list
                            let index = find(allKeyPaths, expandedKey)
                            
                            if index == nil {
                                allKeyPaths.append(expandedKey)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getDistinctValuesForAllFields() {
        
        for keyPath in allKeyPaths {
            
            getDistinctValuesForField(keyPath)
        }
    }
    
    func getDistinctValuesForField(keyPath: String) {
        
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
                if result["values"] is [AnyObject] {

                    let resultArray = result["values"] as [AnyObject]
                    
                    // If array has at least one entry
                    if resultArray.count > 0 {
                        
                        // Filter nulls from result array
                        var filteredResult = resultArray.filter {
                            !($0 is NSNull)
                        }
                        
                        // Switch on the first entry in the array
                        switch filteredResult[0] {
                        
                        // If type is String
                        case let resultString as String:
                            
                            // Cast array to [String] and sort it
                            var stringArray = filteredResult as [String]
                            
                            stringArray.sort {
                                $0 < $1
                            }
                            
                            // Assign casted array to main dict
                            fields.setValue(stringArray, forKeyPath: "\(keyPath).values")
                            fields.setValue("string", forKeyPath: "\(keyPath).type")
                            fields.setValue("\(keyPath)", forKeyPath: "\(keyPath).keyPath")
                            
                        case let resultInteger as Int:
                            
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
                                fields.setValue("numeric", forKeyPath: "\(keyPath).type")
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
                                fields.setValue("numeric", forKeyPath: "\(keyPath).type")
                                fields.setValue("\(keyPath)", forKeyPath: "\(keyPath).keyPath")
                            }
                            
                        case let resultBool as Bool:
                            
                            // Cast array to [Bool]
                            var boolArray = filteredResult as [Bool]
                            
                            // Assign casted array to main dict
                            fields.setValue(boolArray, forKeyPath: "\(keyPath).values")
                            fields.setValue("boolean", forKeyPath: "\(keyPath).type")
                            fields.setValue("\(keyPath)", forKeyPath: "\(keyPath).keyPath")

                        case let resultBSONObjectId as BSONObjectID:
                            
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
                            fields.setValue("string", forKeyPath: "\(keyPath).type")
                            fields.setValue("\(keyPath)", forKeyPath: "\(keyPath).keyPath")

                        case let resultDate as NSDate:
                            
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
                        }
                    }
                }
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
