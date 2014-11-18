//
//  Collection.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 11/17/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import Foundation

struct MongoCredentials {
    static let hostname = "db0.musicsensorsemotion.com"
    static let port = "27017"
    static let authenticationDatabase = "eim"
    static let authenticationUsername = "eim"
    static let authenticationPassword = "eim"
    static var url: String {
        get {
            return "\(hostname):\(port)"
        }
    }
}

class DatabaseHelper {
    let connection : MongoConnection? = nil
    
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
            println("Error authenticating to database: \(error.localizedDescription)")
            return false
        } else {
            println("Successfully authenticated against database")
            return true
        }
    }
    
    init() {
        var error : NSError? = nil
        
        // Connect to the provided connection, or create a new one using MongoCredentials
        connection = MongoConnection(forServer: MongoCredentials.url, error: &error)
        
        if let error = error {
            println("Error connecting to database: \(error.localizedDescription)")
        }
    }
}

class Collection {
    
    let name: String
    let database: String
    var fields: Dictionary<String, AnyObject>
    
    init(name: String, inDatabase: String) {
        self.name = name
        self.database = inDatabase
        self.fields = Dictionary<String, Dictionary<String, AnyObject>>()
    }

    // Iterate over documents in collections and build a list of field names
    func enumerateFieldNames(limit: Int) {
        
//        println("Enumerating field names")
        let start = NSDate()
        
        let dbHelper = DatabaseHelper()
        dbHelper.authenticateToDatabase()
        
        // Get collection for this collection's name
        let qualifiedName = "\(database).\(name)"
        let collection: MongoDBCollection = dbHelper.connection!.collectionWithName(qualifiedName)
        
        // Error object for database operations
        var error : NSError? = nil
        error = nil
        
        // Mongo predicate for finding two documents
        let findRequest = MongoFindRequest()
        findRequest.limitResults = Int32(limit)
        let cursor = collection.cursorForFindRequest(findRequest, error: &error)

        if let error = error {
            println("Error performing find request: \(error.description)")
        } else {
//            println("Request results: \(cursor)")
        }
        
        error = nil
        
        let document = collection.findOneWithError(&error)

        if let error = error {
            println("Error getting document: \(error.description)")
        } else {
//            println("Got document from collection \(qualifiedName)")
        }
        
        var total : Int = 0
        while let document : BSONDocument = cursor?.nextObject() {
            total++

            // Iterate over document keys
            let iterator = document.iterator()

            while iterator.hasMore() {
                iterator.next()
                if let key = iterator.key() {
                    let index = fields.indexForKey(key)
                    
                    if index != nil {
                        fields[key] = Dictionary<String, AnyObject>()
                    }
                }
            }
        }
        
        let end = NSDate()
        let timeInterval = end.timeIntervalSinceDate(start)
        println("Enumerated fields from \(total) documents in \(timeInterval) seconds")
    }
}
