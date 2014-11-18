//
//  Collection.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 11/17/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import Foundation

struct MongoCredentials {
    let hostname = "localhost"
    let port = "28017"
    var url: String {
        get {
            return "\(self.hostname):\(self.port)"
        }
    }
}

class Collection {
    
    let name: String
    let database: String
    let fields: Dictionary<String, AnyObject>
    
    init(name: String, inDatabase: String) {
        self.name = name
        self.database = inDatabase
        self.fields = Dictionary<String, AnyObject>()
    }

    // Iterate over documents in collections and build a list of field names
    func enumerateFieldNames() {
        
        var error : NSError? = nil
        
        var dbConn = MongoConnection(forServer:MongoCredentials().url, error: &error)
        
        if let error = error {
            println("Error connecting to server: \(error.description)")
        } else {
            println("Connected to server")
        }
        
        var qualifiedName = "\(database).\(name)"
//        println(qualifiedName)
        var collection: MongoDBCollection = dbConn.collectionWithName(qualifiedName)
        
        error = nil
        // Mongo predicate for finding one
//        let findRequest = MongoFindRequest()
//        findRequest.limitResults = 2
//        let documentCursor = collection.cursorForFindRequest(findRequest, error: &error)
        let document = collection.findOneWithError(&error)
        
        if let error = error {
            println("Error getting document: \(error.description)")
        } else {
            println("Got document from collection \(qualifiedName)")
        }
        
//        while let document : BSONDocument = documentCursor?.nextObject() {
//            total++

            // Iterate over document keys
            let iterator = document.iterator()

            while iterator.hasMore() {
                iterator.next()
                println("\(iterator.keyPathComponents())")
            }
        
            // If fields doesn't yet contain this key, add it
//            let fieldsArray = Array(fields.keys)
//            if find(
//        }
//
//        println("total objects: \(total)")
    }
}
