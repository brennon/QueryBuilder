//
//  CGVector+QueryBuilder.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 1/19/15.
//  Copyright (c) 2015 Brennon Bortz. All rights reserved.
//

extension CGVector {
    static func angle(fromVector from: CGVector, toVector to: CGVector) -> CGFloat {
        let c = CGPoint.distance(fromPoint: CGPointMake(to.dx, to.dy), toPoint: CGPointMake(from.dx, from.dy))
        let a = CGPoint.distance(fromPoint: CGPointZero, toPoint: CGPointMake(to.dx, to.dy))
        let b = CGPoint.distance(fromPoint: CGPointZero, toPoint: CGPointMake(from.dx, from.dy))
        let sum = (a * a + b * b - (c * c)) / (2 * a * b)
        let gamma = acos(sum)
        
        if to.isClockwise(fromOtherVector: from) {
            return -gamma
        } else {
            return gamma
        }
    }
}
