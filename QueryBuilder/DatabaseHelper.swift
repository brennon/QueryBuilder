//
//  DatabaseHelper.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 1/5/15.
//  Copyright (c) 2015 Brennon Bortz. All rights reserved.
//

/**
The `DatabaseHelper` contains helper methods to work in conjunction with
the `MongoCredentials` struct to connect to a MongoDB instance, to
authenticate against it, etc.
*/
class DatabaseHelper {
    
    /// The `MongoConnection` opened and maintained by a `DatabaseHelper`.
    let connection: MongoConnection? = nil
    
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
        
        connection?.authenticate(MongoSettings.sharedInstance.authenticationDatabase,
            username: MongoSettings.sharedInstance.authenticationUsername,
            password: MongoSettings.sharedInstance.authenticationPassword,
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
            forServer: MongoSettings.sharedInstance.url,
            error: &error
        )
        
        if let error = error {
            print("Error connecting to database: ")
            println("\(error.localizedDescription)")
        }
    }
}
