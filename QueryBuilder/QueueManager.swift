//
//  QueueManager.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 1/6/15.
//  Copyright (c) 2015 Brennon Bortz. All rights reserved.
//

private let _queueManagerSharedInstance = QueueManager()

class QueueManager {
    
    private var _databaseQueue: dispatch_queue_t!
    
    init() {
        let queueAttributes: dispatch_queue_attr_t = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0)
        _databaseQueue = dispatch_queue_create("com.brennonbortz.Monstructor.DatabaseQueue", queueAttributes)
    }
    
    class var sharedInstance: QueueManager {
        return _queueManagerSharedInstance
    }
    
    func getDatabaseQueue() -> dispatch_queue_t {
        return _databaseQueue
    }
}
