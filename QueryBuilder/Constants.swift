//
//  Constants.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 12/3/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

// MARK: Layers

enum SceneLayer: CGFloat {
    case Background             = 0
    case PropertyTrayHandle
    case PropertyTrayContainer
    case PropertyTrayTiles
    case PredicateTiles
    case Foreground
}

// MARK: Collision / Contact Categories

enum SceneNodeCategories: UInt32 {
    case None           = 0
    case PredicateTile  = 1
}

// MARK: Colors

let PropertyTrayContainerColor  = UIColor.lightGrayColor()
let PropertyTrayBorderColor     = UIColor.darkGrayColor()
let TileLabelFontColor          = UIColor.whiteColor()
let SceneBackgroundColor        = UIColor(white: 0.9, alpha: 1.0)

// MARK: Node Names

let PredicateTileNodeName = "tile-predicate"

// MARK: Dimensions

let TileWidth:          CGFloat = 100
let TileHeight:         CGFloat = 50
let TileSize                    = CGSizeMake(TileWidth, TileHeight)
let TileCornerRadius:   CGFloat = 10
let TileBorderWidth:    CGFloat = 2
let TileMarginWidth:    CGFloat = 10

// MARK: Fonts

let TileLabelFontName = "HelveticaNeue-CondensedBold"