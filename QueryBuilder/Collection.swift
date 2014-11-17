//
//  Collection.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 11/17/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import Foundation

struct MongoCredentials {
    let hostname = "db0.musicsensorsemotion.com"
    let port = "27017"
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
//        var documentsCount = collection.countWithPredicate(MongoPredicate(), error: &error)
//        
//        var serverStatus = collection.lastOperationDictionary()
//        println(serverStatus)
//        
//        println("count: \(documentsCount)")
        
//        var total: Int = 0
//        while let document = documentsCursor.nextObject() {
//            total++
//            println(document)
//        }
//        
//        println("total objects: \(total)")
    }
}
