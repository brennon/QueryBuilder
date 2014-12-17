//
//  Regex.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 12/15/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

infix operator =~ {}

func =~ (input: String, pattern: String) -> Bool {
    return Regex(pattern).test(input)
}

class Regex {
    let internalExpression: NSRegularExpression
    let pattern: String
    
    init(_ pattern: String) {
        self.pattern = pattern
        var error: NSError?
        self.internalExpression = NSRegularExpression(pattern: pattern, options: .CaseInsensitive, error: &error)!
    }
    
    func test(input: String) -> Bool {
        let matches = self.internalExpression.matchesInString(input, options: nil, range:NSMakeRange(0, countElements(input)))
        return matches.count > 0
    }
}
