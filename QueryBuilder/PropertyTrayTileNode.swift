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
        
        let tapTapDragGestureRecognizer = BBTapTapDragGestureRecognizer(target: self, action: PropertyTrayTileNode.handleTapAndAHalf)
        addGestureRecognizer(tapTapDragGestureRecognizer)
        
        panRecognizer.requireGestureRecognizerToFail(tapTapDragGestureRecognizer)
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
                
                println("scrolling")
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
    
    var lastRemovedTilePosition: CGPoint?
    var lastRemovedTileParentNode: SKNode?
    var lastRemovedTileKeyPath: String?
    var lastRemovedTile: PropertyTrayTileNode?
    
    func handleTapAndAHalf(recognizer: BBGestureRecognizer?) {
        
        if let tapRecognizer = recognizer as? BBTapTapDragGestureRecognizer {
            
            // Move the tile to the scene so that we can reposition it.
            if tapRecognizer.state == .Began {
                println("Began")
                
                if let oldScene = scene {
                    if let oldNode = tapRecognizer.node as? PropertyTrayTileNode {
                        if let oldParent = oldNode.parent {
                            if let oldKeyPath = oldNode.propertyDict?.valueForKey("keyPath") as? String {
                                
                                // Get all the information we need to replace the tile.
                                lastRemovedTileParentNode = oldParent
                                lastRemovedTilePosition = oldScene.convertPoint(oldNode.position, fromNode: oldParent)
                                lastRemovedTileKeyPath = oldKeyPath
                                lastRemovedTile = oldNode
                                
                                // Move the tile to the scene.
                                oldNode.removeFromParent()
                                oldNode.position = lastRemovedTilePosition!
                                oldScene.addChild(oldNode)
                                
                                // Remove tile constraints.
                                propertyTrayNode.removeAllTileConstraints()
                            }
                        }
                    }
                }
            
            // Reposition the tile.
            } else if tapRecognizer.state == .Changed {
                
                if let parent = lastRemovedTileParentNode {
                    if let tilePosition = lastRemovedTilePosition {
                        if let keyPath = lastRemovedTileKeyPath {
                            if let tile = lastRemovedTile {
                                
                                // Reset velocity--we don't need it.
                                tile.physicsBody?.velocity = CGVectorMake(0, 0)
                                
                                // Apply translation to tile and reset translation on recognizer.
                                let translation = tapRecognizer.translationInNode(scene!)
                                let newPosition = CGPointMake(position.x + translation.x, position.y + translation.y)
                                position = newPosition
                                tapRecognizer.setTranslation(CGPointZero, inNode: scene!)
                            }
                        }
                    }
                }
                
            // Snap the tile back to its original position and reattach it to original parent.
            } else if tapRecognizer.state == .Ended {
                
                if let parent = lastRemovedTileParentNode {
                    if let tilePosition = lastRemovedTilePosition {
                        if let keyPath = lastRemovedTileKeyPath {
                            if let tile = lastRemovedTile {
                                let oldScene = scene!
                                
                                let snapBack = snapBackAction(toPosition: tilePosition)
                                
                                tapRecognizer.node!.runAction(snapBack) {
                                    tapRecognizer.node!.removeFromParent()
                                    tapRecognizer.node!.position = parent.convertPoint(tilePosition, fromNode: oldScene)
                                    parent.addChild(tapRecognizer.node!)
                                    self.propertyTrayNode.addTileConstraints()
                                }

                                // Add a new PredicateTileNode at the new position.
                                let newPredicateTile = PredicateTileNode(propertyTile: tile, andLabel: keyPath)
                                newPredicateTile?.position = tapRecognizer.node!.position
                                if newPredicateTile != nil {
                                    oldScene.addChild(newPredicateTile!)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func snapBackAction(toPosition position: CGPoint) -> SKAction {
        let fadeOut = SKAction.fadeOutWithDuration(0)
        let scaleUp = SKAction.scaleTo(1.25, duration: 0)
        let snapBack = SKAction.moveTo(position, duration: 0)
        let disappear = SKAction.group([fadeOut, scaleUp, snapBack])
        
        let fadeIn = SKAction.fadeInWithDuration(0.25)
        let scaleDown = SKAction.scaleTo(1, duration: 0.25)
        let reappear = SKAction.group([fadeIn, scaleDown])
        
        let sequence = SKAction.sequence([disappear, reappear])
        
        return sequence
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
