//
//  PredicateTileNode.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 12/3/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import SpriteKit

/**
    A `PredicateTileNode` is a visual representation of a predicate in a
    MongoDB query. A `PredicateTileNode` can also be used to represent 
    properties of MongoDB documents.
 */
class PredicateTileNode: TileNode {
    
    /**
        Assigns the node's sprite and name, and configures its physics.
    */
    init(label: String) {
        
        super.init()
        
        // Add label to userData
        if userData == nil {
            userData = NSMutableDictionary()
        }
        userData?.setValue(label, forKey: "label")
        
        // Create and add label node
        labelNode = SKLabelNode(text: label)
        labelNode!.position = CGPointZero
        labelNode!.fontName = "HelveticaNeue-CondensedBold"
        labelNode!.fontColor = UIColor.whiteColor()
        labelNode!.verticalAlignmentMode = .Center
        labelNode!.fontSize = calculateFontSize(label)
        addChild(labelNode!)
    }

    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
        Implements a handler for moving tiles around the scene.
    */
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        super.touchesMoved(touches, withEvent: event)
        
        // Get the touch
        if let touch = touches.anyObject() as? UITouch {
            
            // Get the location delta of the touch
            let previousLocation = touch.previousLocationInNode(scene)
            let currentLocation = touch.locationInNode(scene)
            let deltaX = currentLocation.x - previousLocation.x
            let deltaY = currentLocation.y - previousLocation.y
            
            position.x += deltaX
            position.y += deltaY
        }
    }
}
