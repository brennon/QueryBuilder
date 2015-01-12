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
    case ScrollingIndicators
    case MenuRing
    case MenuKnob
    case Foreground
}

// MARK: Collision / Contact Categories

enum SceneNodeCategories: UInt32 {
    case None           = 0
    case PredicateTile  = 1
}

// MARK: Colors

let PropertyTrayContainerColor                  = UIColor(red: 0.314, green: 0.494, blue: 0.698, alpha: 1)
let PropertyTilePrimaryColor                    = UIColor(red: 0.2, green: 0.4, blue: 0.624, alpha: 1)
let PredicateTileHeaderColor                    = UIColor(red: 0.953, green: 0.682, blue: 0.251, alpha: 1)
let PredicateTileDescriptionColor               = UIColor(red: 1, green: 0.765, blue: 0.4, alpha: 1)
let PredicateTileChooserHeaderColor             = UIColor(red: 0.2, green: 0.392, blue: 0.624, alpha: 1)
let PredicateTileChooserChoicePrimaryColor      = UIColor(red: 0.314, green: 0.49, blue: 0.698, alpha: 1)
let PredicateTileChooserChoiceSecondaryColor    = UIColor(red: 0.094, green: 0.314, blue: 0.573, alpha: 1)
let TileLabelFontColor                          = UIColor.whiteColor()
let SceneBackgroundColor                        = UIColor(white: 0.9, alpha: 1.0)

// MARK: Node Names

let PredicateTileNodeName           = "tile-predicate"
let PropertyTrayNodeName            = "property-tray"
let PropertyTrayTileNodeName        = "property-tray-tile"
let PropertyTrayContainerNodeName   = "property-tray-container"

// MARK: Animation Durations

let PropertyTrayTileExpandDuration      = 0.2
let PropertyTrayTileContractDuration    = 0.2

// MARK: Dimensions

let TileHeight:                 CGFloat = 50
let TileWidth:                  CGFloat = 150
let TileSize                            = CGSizeMake(TileWidth, TileHeight)
let TileCornerRadius:           CGFloat = 10
let TileBorderWidth:            CGFloat = 2
let TileMarginHeight:           CGFloat = 10
let TileMarginWidth:            CGFloat = 10
let PropertyTrayMaximumHeight:  CGFloat = UIScreen.mainScreen().applicationFrame.height - 100

// MARK: Fonts

let TileLabelFontName = "HelveticaNeue-CondensedBold"