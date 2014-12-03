//
//  Constants.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 12/3/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

enum SceneLayer: CGFloat {
    case Background = 0
    case PredicateTiles
    case Foreground
}

enum SceneNodeCategories: UInt32 {
    case None = 0
    case PredicateTile = 1
}

// MARK: SKNode names
let PredicateTileNodeName = "tile-predicate"
