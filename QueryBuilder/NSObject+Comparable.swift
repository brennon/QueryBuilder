//
//  NSObject+Comparable.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 4/22/15.
//  Copyright (c) 2015 Brennon Bortz. All rights reserved.
//

extension NSObject: Comparable {}

public func <(lhs: NSObject, rhs: NSObject) -> Bool {
    return lhs.hashValue < rhs.hashValue
}
