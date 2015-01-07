//
//  MongoSettings.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 1/5/15.
//  Copyright (c) 2015 Brennon Bortz. All rights reserved.
//

/**
    The `MongoSettings` class provides useful information for connecting to a MongoDB database.
*/
private let _mongoSettingsSharedInstance = MongoSettings()

class MongoSettings {
    
    class var sharedInstance: MongoSettings {
        return _mongoSettingsSharedInstance
    }
    
    var hostname = "db0.musicsensorsemotion.com"
    var port = "27017"
    var authenticationDatabase = "eim"
    var authenticationUsername = "eim"
    var authenticationPassword = "eim"
    var url: String {
        get {
            return "\(hostname):\(port)"
        }
    }
}
