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
    var fields: Dictionary<String, Dictionary<String, AnyObject>>
    
    init(name: String, inDatabase: String) {
        
        collectionName = name
        databaseName = inDatabase
        fields = [String: [String: AnyObject]]()
    }

    // Iterate over documents in a collection and build a dict of fields
    func enumerateFieldNames(limit: Int) {
        
        let start = NSDate()
        
        let dbHelper = DatabaseHelper()
        dbHelper.authenticateToDatabase()
        
        // Get collection for this collection's name
        let qualifiedName = "\(databaseName).\(collectionName)"
        let collection: MongoDBCollection = dbHelper.connection!.collectionWithName(qualifiedName)
        
        // Error object for database operations
        var error : NSError? = nil
        error = nil
        
        // Mongo predicate for finding alimited number of documents
        let findRequest = MongoFindRequest()
        findRequest.limitResults = Int32(limit)
        let cursor = collection.cursorForFindRequest(findRequest, error: &error)

        if let error = error {
            println("Error performing find request: \(error.description)")
        }
        
        error = nil
        
        let document = collection.findOneWithError(&error)

        if let error = error {
            println("Error getting document: \(error.description)")
        }
        
        // Iterate over documents
        var total : Int = 0
        while let document : BSONDocument = cursor?.nextObject() {
            total++

            enumerateFieldsInDocument(document, atPath: "")
        }
        
        let end = NSDate()
        let timeInterval = end.timeIntervalSinceDate(start)
        
        println("Enumerated fields from \(total) documents in \(timeInterval) seconds")
    }
    
    func enumerateFieldsInDocument(document: BSONDocument, atPath: String) {
        
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
                    if atPath != "" {
                        
                        expandedKey = "\(atPath).\(key)"
                    } else {
                        expandedKey = key
                    }
                    
                    // If this is a subdocument
                    if iterator.isEmbeddedDocument() {
                    
                        enumerateFieldsInDocument(iterator.embeddedDocumentValue(), atPath: expandedKey)
                    
                    } else if iterator.isArray() {
                        
                        enumerateFieldsInDocument(iterator.embeddedDocumentValue(), atPath: expandedKey)
                    
                    // Otherwise, store the key
                    } else {
                        
                        let index = fields.indexForKey(expandedKey)
                        
                        if index == nil {
                            
                            fields[expandedKey] = Dictionary<String, AnyObject>()
                            
                            // Get distinct values for this path
                            getDistinctValuesForField(expandedKey)
                        }
                    }
                }
            }
        }
    }
    
    func getDistinctValuesForField(keyPath: String) {
        
        // Connect to database
        let dbHelper = DatabaseHelper()
        dbHelper.authenticateToDatabase()
        
        // Build command for getting distinct values for a field
        let commandDictionary = [
            MongoDBCommandDictKey:["distinct": collectionName], "key": keyPath
        ]
        
        var error: NSError?
        
        // If command is successful
        if let result = dbHelper.connection?.runCommandWithDictionary(
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
                        
                        // Get a copy of the current inner dictionary
                        var currentInnerDict: [String: AnyObject] = fields[keyPath]!
                        
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
                            currentInnerDict["values"] = stringArray
                            currentInnerDict["type"] = "string"
                            fields[keyPath] = currentInnerDict
                            
                        case let resultInteger as Int:
                            
                            // Cast array to [Int] and sort it
                            var intArray = filteredResult as [Int]
                            
                            intArray.sort {
                                $0 < $1
                            }
                            
                            // Assign casted array to main dict
                            currentInnerDict["values"] = intArray
                            currentInnerDict["min"] = intArray.first
                            currentInnerDict["max"] = intArray.last
                            currentInnerDict["type"] = "numeric"
                            fields[keyPath] = currentInnerDict
                            
                        case let resultDouble as Double:
                            
                            // Cast array to [Double] and sort it
                            var doubleArray = filteredResult as [Double]
                            
                            doubleArray.sort {
                                $0 < $1
                            }
                            
                            // Assign casted array to main dict
                            currentInnerDict["values"] = doubleArray
                            currentInnerDict["min"] = doubleArray.first
                            currentInnerDict["max"] = doubleArray.last
                            currentInnerDict["type"] = "numeric"
                            fields[keyPath] = currentInnerDict
                            
                        case let resultBool as Bool:
                            
                            // Cast array to [Bool]
                            var boolArray = filteredResult as [Bool]
                            
                            // Assign casted array to main dict
                            currentInnerDict["values"] = boolArray
                            currentInnerDict["type"] = "boolean"
                            fields[keyPath] = currentInnerDict
                            
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
                            currentInnerDict["values"] = stringArray
                            currentInnerDict["type"] = "string"
                            fields[keyPath] = currentInnerDict
                            
                        case let resultDate as NSDate:
                            
                            // Cast array to [NSDate]
                            var dateArray = filteredResult as [NSDate]
                            
                            // Assign casted array to main dict
                            currentInnerDict["values"] = dateArray
                            currentInnerDict["min"] = dateArray.first
                            currentInnerDict["max"] = dateArray.last
                            currentInnerDict["type"] = "datetime"
                            fields[keyPath] = currentInnerDict
                            
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
