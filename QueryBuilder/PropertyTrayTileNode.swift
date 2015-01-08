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
        
        // Configure physics body
//        physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
//        physicsBody!.allowsRotation = false
//        physicsBody!.affectedByGravity = false
        
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
        
        println("expandTile called on \(label)")
        
        // Add child tiles to parent node
        for (index, child) in enumerate(childTiles) {
            
            // Add each child and update layout as we go
//            child.alpha = 0
            child.position = CGPointMake(0, -(TileHeight + TileMarginWidth) * CGFloat(index + 1))
            addChild(child)
        }
        
        if let tileParent = parent as? PropertyTrayTileNode {
            tileParent.updateLayout()
        }
        
//        println("root tile frame: \(rootTileNode.calculateAccumulatedFrame())")
        
        propertyTrayNode.updateLayout(rootTileNode, animated: true, completion: {})
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
        
        propertyTrayNode.updateLayout(rootTileNode, animated: true, completion: {})
    }

//    /**
//        Tells the receiver when one or more fingers touch down in a view or
//        window.
//    
//        :param: touches A set of `UITouch` instances that represent the touches 
//            for the starting phase of the event represented by `event`.
//        :param: event An object representing the event to which the touches 
//            belong.
//    */
//    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//        
//        // Was it a single touch?
//        if touches.count == 1 {
//            
//            // Start the tap timer
//            tapBegin = NSDate()
//        }
//    }
//    
//    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
//        
//        // Is it just one finger?
//        if touches.count == 1 {
//            
//            let touch = touches.anyObject() as UITouch
//            
//            // Get position delta
//            let deltaX = touch.locationInView(scene!.view).x - touch.previousLocationInView(scene!.view).x
//            let deltaY = touch.locationInView(scene!.view).y - touch.previousLocationInView(scene!.view).y
//            
//            // Update position with deltas
//            self.position.x += deltaX
//            self.position.y -= deltaY
//            
//            propertyTrayNode.updateLayout(self)
//        }
//    }
//    
//    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
//        
//        // Was it a single touch?
//        if touches.count == 1 {
//            
//            // Did the touch end within the tap time window?
//            let tapDuration = NSDate().timeIntervalSinceDate(tapBegin)
//            
//            if tapDuration <= tapTimeWindow {
//                
//                handleSingleTap(touches.anyObject() as UITouch)
//            }
//        }
//    }
    
    func handlePan(recognizer: BBGestureRecognizer?) {
        
        if let panRecognizer = recognizer as? BBPanGestureRecognizer {
            
            if panRecognizer.state == BBGestureRecognizerState.Changed {
                
                let translation = panRecognizer.translationInNode(self.scene!)
//                let newPosition = CGPointMake(position.x, position.y + translation.y)
//                position = newPosition
//                propertyTrayNode.updateLayout(rootTileNode, animated: false, completion: nil)
//                runAction(SKAction.moveTo(newPosition, duration: 0))
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
                
//                // Tell tray node to update its layout
//                propertyTrayNode.updateLayout(self.rootTileNode, animated: true) {
//                
//                    // Fade in the new tiles
//                    for tile in self.childTiles {
//                        let wait = SKAction.waitForDuration(PropertyTrayTileExpandDuration)
//                        let fadeIn = SKAction.fadeInWithDuration(0.1)
//                        let sequence = SKAction.sequence([wait, fadeIn])
//                        tile.runAction(sequence)
//                    }
//                }
//                
//                // Get number of visible property tiles
//                var count: Int = 0
//                enumerateChildNodesWithName(PropertyTrayTileNodeName, usingBlock: { (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
//                    count = count + 1
//                })
                
            } else {
                collapseTile()
//                for var i = childTiles.count - 1; i >= 0; i-- {
//                    let child = childTiles[i]
//                    let oldParent = child.parent!
//                    let fadeOut = SKAction.fadeOutWithDuration(0.1)
//                    child.runAction(fadeOut)
//                
//                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
//                    dispatch_after(delayTime, dispatch_get_main_queue()) {
//                        child.removeFromParent()
//                        
//                        self.propertyTrayNode.updateLayout(self.rootTileNode, animated: true, completion: nil)
//                    }
//                }
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
