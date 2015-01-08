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
    var propertyTrayNode: PropertyTrayNode!
    var rootTileNode: PropertyTrayTileNode!
    var isRootTileNode = false
    var label: String!
    var depth: Int = 0
    
    enum possibleGestures: Int {
        case None   = 0
        case Scroll = 1
        case Tap    = 2
    }
    
    /// The subproperties of the field that this node represents, as a 
    /// an array of `PropertyTrayTileNode`s.
    var childTiles = [PropertyTrayTileNode]()
    
    /**
        Assigns the node's sprite and name, and configures its physics.
        
        :param: label The string to use for the tile's label.
    */
    init(label: String, propertyTrayNode: PropertyTrayNode, rootTileNode: PropertyTrayTileNode?, depth: Int) {
        super.init()
        
        self.label = label
        self.propertyTrayNode = propertyTrayNode
        self.depth = depth
        self.color = UIColor.blackColor()
        self.colorBlendFactor = 0.15 * CGFloat(depth)
        
        if rootTileNode != nil {
            self.rootTileNode = rootTileNode
            isRootTileNode = false
        } else {
            self.rootTileNode = self
            isRootTileNode = true
        }
        
        name = PropertyTrayTileNodeName
        
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
        
        // Add single-tap recognizer to node
        let singleTapRecognizer = BBTapGestureRecognizer(target: self, action: PropertyTrayTileNode.handleSingleTap)
        addGestureRecognizer(singleTapRecognizer)
        
        // Add pan recognizer to node
        let panRecognizer = BBPanGestureRecognizer(target: self, action: PropertyTrayTileNode.handlePan)
        addGestureRecognizer(panRecognizer)
    }
    
    func updateLayout() {
        
        // If this tile isn't expanded, return immediately.
        if !tileExpanded {
            return
        }
        
        // First, tell each child tile to layout itself.
        for child in childTiles {
            child.updateLayout()
        }
        
        // Then, position the child tiles now that they've been updated.
        var nextTileY = -TileHeight - TileMarginHeight
        for child in childTiles {
            child.position = CGPointMake(0, nextTileY)
            nextTileY -= (child.calculateAccumulatedFrame().height - (TileHeight / 2)) + TileMarginHeight + (TileHeight / 2)
        }
    }
    
    func expandTile() {
        
        tileExpanded = true
        
        // Add child tiles to parent node
        for (index, child) in enumerate(childTiles) {
            
            // Add each child and update layout as we go
            child.position = CGPointMake(0, -(TileHeight + TileMarginWidth) * CGFloat(index + 1))
            addChild(child)
        }
        
        if let tileParent = parent as? PropertyTrayTileNode {
            tileParent.updateLayout()
        }
        
        propertyTrayNode.needsLayout = true
    }
    
    func collapseTile() {
        
        tileExpanded = false
        
        // Collapse all child tiles
        for child in childTiles {
            
            child.collapseTile()
            child.removeFromParent()
        }
        
        if let tileParent = parent as? PropertyTrayTileNode {
            tileParent.updateLayout()
        }
        
        propertyTrayNode.needsLayout = true
    }
    
    func handlePan(recognizer: BBGestureRecognizer?) {
        
        if let panRecognizer = recognizer as? BBPanGestureRecognizer {
            
            if panRecognizer.state == BBGestureRecognizerState.Changed {
                
                let translation = panRecognizer.translationInNode(self.scene!)
                propertyTrayNode.scrollTiles(translation.y)
                panRecognizer.setTranslation(CGPointZero, inNode: self.scene!)
            }
        }
    }
    
    func handleSingleTap(recognizer: BBGestureRecognizer?) {
        
        if recognizer?.state == BBGestureRecognizerState.Recognized {
        
            // Expand direct children tiles if they are collapsed
            if !tileExpanded {
                expandTile()
            } else {
                collapseTile()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
