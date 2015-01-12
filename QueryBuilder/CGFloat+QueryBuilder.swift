//
//  CGFloat+QueryBuilder.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 1/11/15.
//  Copyright (c) 2015 Brennon Bortz. All rights reserved.
//

var π: CGFloat = CGFloat(M_PI)

extension CGFloat {
    
    static func random(lower: CGFloat, upper: CGFloat) -> CGFloat {
        let range = upper - lower
        let initialRandom = CGFloat(arc4random_uniform(UINT32_MAX)) / CGFloat(UINT32_MAX)
        return (initialRandom * range) + lower
    }
    
    func toRadians() -> CGFloat {
        return CGFloat(Double(self) * M_PI / Double(180))
    }
    
    func toDegrees() -> CGFloat {
        return CGFloat(Double(self) * Double(180) / M_PI)
    }
}
