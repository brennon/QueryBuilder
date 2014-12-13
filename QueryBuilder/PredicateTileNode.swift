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
    MongoDB query.
 */
class PredicateTileNode: TileNode {
    
    /**
        Assigns the node's sprite and name, and configures its physics.
        
        :param: label The string to use for the tile's label.
    */
    init(label: String) {
        
        super.init()
        
        // Add label to userData
        if userData == nil {
            userData = NSMutableDictionary()
        }
        userData?.setValue(label, forKey: "label")
        
        // Create, configure, and add label node as child node
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
        Tells the receiver when one or more fingers associated with an event 
        move within a view or window. Specifically, this implementation 
        implements a handler for dragging tiles around the scene.
    
        :param: touches A set of UITouch instances that represent the touches 
            that are moving during the event represented by event.
        :param: event An object representing the event to which the touches 
            belong.
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
            
            // Move the node accordingly
            position.x += deltaX
            position.y += deltaY
        }
    }
}
