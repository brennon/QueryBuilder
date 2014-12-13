//
//  PropertyTrayTileNode.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 12/13/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import SpriteKit

/**
    A `PropertyTrayTileNode` is a visual representation of a property/field in a
    MongoDB document.
*/
class PropertyTrayTileNode: TileNode {
    
    /// The dictionary for the field that this node represents, as configured
    /// by a `Collection`
    var propertyDict: NSMutableDictionary?
    
    /// The subproperties of the field that this node represents, as a 
    /// an array of `PropertyTrayTileNode`s.
    var childTiles = [PropertyTrayTileNode]()
    
    /**
        Assigns the node's sprite and name, and configures its physics.
        
        :param: label The string to use for the tile's label.
    */
    init(label: String) {
        
        super.init()
        
        // Create, configure, and add label node as child node
        labelNode = SKLabelNode(text: label)
        labelNode!.position = CGPointZero
        labelNode!.fontName = TileLabelFontName
        labelNode!.fontColor = TileLabelFontColor
        labelNode!.verticalAlignmentMode = .Center
        labelNode!.fontSize = calculateFontSize(label)
        addChild(labelNode!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
