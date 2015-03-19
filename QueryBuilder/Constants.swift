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

// http://paletton.com/#uid=70O0u0kn-uvdZJdjg-0t9s1uwlC

let QBColorPrimaryLightest                      = UIColor(red: 0.953, green: 0.682, blue: 0.251, alpha: 1)
let QBColorPrimaryLighter                       = UIColor(red: 1, green: 0.831, blue: 0.565, alpha: 1)
let QBColorPrimary                              = UIColor(red: 1, green: 0.765, blue: 0.4, alpha: 1)
let QBColorPrimaryDarker                        = UIColor(red: 0.875, green: 0.565, blue: 0.078, alpha: 1)
let QBColorPrimaryDarkest                       = UIColor(red: 0.675, green: 0.424, blue: 0.031, alpha: 1)
let QBColorSecondaryALightest                   = UIColor(red: 0.953, green: 0.8, blue: 0.251, alpha: 1)
let QBColorSecondaryALighter                    = UIColor(red: 1, green: 0.906, blue: 0.565, alpha: 1)
let QBColorSecondaryA                           = UIColor(red: 1, green: 0.867, blue: 0.4, alpha: 1)
let QBColorSecondaryADarker                     = UIColor(red: 0.875, green: 0.702, blue: 0.078, alpha: 1)
let QBColorSecondaryADarkest                    = UIColor(red: 0.675, green: 0.533, blue: 0.031, alpha: 1)
let QBColorSecondaryBLightest                   = UIColor(red: 0.286, green: 0.239, blue: 0.663, alpha: 1)
let QBColorSecondaryBLighter                    = UIColor(red: 0.549, green: 0.518, blue: 0.831, alpha: 1)
let QBColorSecondaryB                           = UIColor(red: 0.392, green: 0.349, blue: 0.733, alpha: 1)
let QBColorSecondaryBDarker                     = UIColor(red: 0.18, green: 0.129, blue: 0.608, alpha: 1)
let QBColorSecondaryBDarkest                    = UIColor(red: 0.122, green: 0.082, blue: 0.471, alpha: 1)
let QBColorComplementLightest                   = UIColor(red: 0.2, green: 0.392, blue: 0.624, alpha: 1)
let QBColorComplementLighter                    = UIColor(red: 0.482, green: 0.631, blue: 0.808, alpha: 1)
let QBColorComplement                           = UIColor(red: 0.314, green: 0.486, blue: 0.698, alpha: 1)
let QBColorComplementDarker                     = UIColor(red: 0.094, green: 0.314, blue: 0.573, alpha: 1)
let QBColorComplementDarkest                    = UIColor(red: 0.055, green: 0.231, blue: 0.443, alpha: 1)
let RunQueryButtonColor                         = QBColorComplement
let PropertyTrayContainerColor                  = QBColorComplementLightest
let PropertyTilePrimaryColor                    = QBColorPrimaryLightest
let PredicateTileHeaderColor                    = QBColorPrimary
let PredicateTileDescriptionColor               = QBColorPrimaryLighter
let PredicateTileChooserHeaderColor             = QBColorSecondaryB
let PredicateTileChooserChoicePrimaryColor      = QBColorSecondaryBLighter
let PredicateTileChooserChoiceSecondaryColor    = QBColorSecondaryBDarker
let PredicateTileHighlightColor                 = QBColorComplement
let TileLabelFontColor                          = UIColor.whiteColor()
let SceneBackgroundColor                        = UIColor(white: 0.9, alpha: 1.0)

// MARK: Node Names

let PredicateTileNodeName           = "tile-predicate"
let PredicateGroupNodeName          = "predicate-group"
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
let TileMarginHeight:           CGFloat = 5
let TileMarginWidth:            CGFloat = 5
let PredicateGroupTileMarginWidth: CGFloat = 30
let PropertyTrayMaximumHeight:  CGFloat = UIScreen.mainScreen().applicationFrame.height - 100

// MARK: Fonts

let TileLabelFontName = "HelveticaNeue-CondensedBold"