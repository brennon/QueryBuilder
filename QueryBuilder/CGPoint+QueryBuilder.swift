//
//  CGPoint+QueryBuilder.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 1/19/15.
//  Copyright (c) 2015 Brennon Bortz. All rights reserved.
//

extension CGPoint {
    static func distance(fromPoint from: CGPoint, toPoint to: CGPoint) -> CGFloat {
        let dx = to.x - from.x
        let dy = to.y - from.y
        let sum = dx * dx + dy * dy
        return sqrt(sum)
    }
}
