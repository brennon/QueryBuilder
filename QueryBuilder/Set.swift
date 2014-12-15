//
//  Set.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 12/14/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

class Set<T where T: Comparable, T: Hashable> {
    
    private var dict = Dictionary<T, Bool>()
    
    func add(item: T) {
        dict[item] = true
    }

    func remove(item: T) {
        if let index = dict.indexForKey(item) {
            dict.removeAtIndex(index)
        }
    }
    
    func items() -> [T] {
        return dict.keys.array.sorted {
            $0 < $1
        }
    }
}
