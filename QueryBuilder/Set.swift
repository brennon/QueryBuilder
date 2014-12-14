//
//  Set.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 12/14/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

class Set<T: Equatable> {
    
    private var array = Array<T>()
    
    func add(item: T) {
        
        let index = find(array, item)
        
        if index == nil {
            
            array.append(item)
        }
    }
    
    func remove(item: T) {
        
        if let index = find(array, item) {
            
            array.removeAtIndex(index)
        }
    }
    
    func itemArray() -> Array<T> {
        
        return array
    }
}
