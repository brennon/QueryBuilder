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
    init(label: String, propertyTrayNode: PropertyTrayNode, rootTileNode: PropertyTrayTileNode?) {
        super.init()
        
        self.label = label
        self.propertyTrayNode = propertyTrayNode
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
        self.addGestureRecognizer(singleTapRecognizer)
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
    
    func handleSingleTap(recognizer: BBGestureRecognizer?) {
        
        if recognizer?.state == BBGestureRecognizerState.Recognized {
        
            // Expand direct children tiles if they are collapsed
            if !tileExpanded {
                
                for (index, child) in enumerate(childTiles) {
                    
                    println("frame of tapped tile: \(self.calculateAccumulatedFrame())")
                    
                    // Add each child and update layout as we go
                    child.alpha = 0
                    child.position = CGPointMake(0, -(TileHeight + TileMarginWidth) * CGFloat(index + 1))
                    addChild(child)
                    
//                    propertyTrayNode.updateLayout(self) {
//                        child.runAction(SKAction.fadeInWithDuration(0.25))
//                    }
                }
                
                propertyTrayNode.updateLayout(self, completion: nil)
                
                // Get number of visible property tiles
                var count: Int = 0
                enumerateChildNodesWithName(PropertyTrayTileNodeName, usingBlock: { (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                    count = count + 1
                })
                
                println("counted \(count) subtiles")
                
            } else {
                
                for child in childTiles {
                    child.removeFromParent()
                }
                
                propertyTrayNode.updateLayout(self, nil)
            }
            tileExpanded = !tileExpanded
        }
        
        // Tell tray node to update its layout
//        propertyTrayNode.updateLayout(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
