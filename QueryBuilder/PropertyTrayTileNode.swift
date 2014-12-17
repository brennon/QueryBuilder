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
    var tapCount: Int = 0
    var tapTimeWindow = 0.5
    var tapBegin = NSDate()
    var tileExpanded = false
    
    /// The subproperties of the field that this node represents, as a 
    /// an array of `PropertyTrayTileNode`s.
    var childTiles = [PropertyTrayTileNode]()
    
    /**
        Assigns the node's sprite and name, and configures its physics.
        
        :param: label The string to use for the tile's label.
    */
    init(label: String) {
        
        super.init()
        
        // Configure tile position
        zPosition = SceneLayer.PropertyTrayTiles.rawValue
        
        // Create, configure, and add label node as child node
        labelNode = SKLabelNode(text: label)
        labelNode!.position = CGPointZero
        labelNode!.fontName = TileLabelFontName
        labelNode!.fontColor = TileLabelFontColor
        labelNode!.verticalAlignmentMode = .Center
        labelNode!.fontSize = calculateFontSize(label)
        addChild(labelNode!)
    }

    /**
        Tells the receiver when one or more fingers touch down in a view or 
        window.
    
        :param: touches A set of `UITouch` instances that represent the touches 
            for the starting phase of the event represented by `event`.
        :param: event An object representing the event to which the touches 
            belong.
    */
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        // Was it a single touch?
        if touches.count == 1 {
            
            // Start the tap timer
            tapBegin = NSDate()
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        // Was it a single touch?
        if touches.count == 1 {
            
            // Did the touch end within the tap time window?
            let tapDuration = NSDate().timeIntervalSinceDate(tapBegin)
            
            if tapDuration <= tapTimeWindow {
                
                handleSingleTap(touches.anyObject() as UITouch)
            }
        }
    }
    
    func handleSingleTap(touch: UITouch) {
        
        // Expand direct children tiles if they are collapsed
        if !tileExpanded {
            
            for (index, child) in enumerate(childTiles) {
//                child.position = CGPointMake(400, 400)
                child.position = CGPointMake(0, -(TileHeight + TileMarginWidth) * CGFloat(index + 1))
                addChild(child)
            }
        } else {
            
            for child in childTiles {
                child.removeFromParent()
            }
        }
        
        tileExpanded = !tileExpanded
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
