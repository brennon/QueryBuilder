//
//  PredicateTileNode.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 12/3/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import SpriteKit

let BoxWidth : CGFloat = 100
let BoxHeight : CGFloat = 50
let BoxCornerRadius : CGFloat = 10
let BoxBorderWidth : CGFloat = 2

/**
    A `PredicateTileNode` is a visual representation of a predicate in a
    MongoDB query. A `PredicateTileNode` can also be used to represent 
    properties of MongoDB documents.
 */
class PredicateTileNode: SKSpriteNode {
    
    /**
        The size of the `PredicateTileNode`.
    */
    let headerTileSize = CGSizeMake(BoxWidth, BoxHeight)
    
    /**
        Assigns the node's sprite and name, and
        configures its physics.
    */
    convenience init(label: String) {
        
        self.init()
        
        // Add label to userData
        userData = NSMutableDictionary()
        userData?.setValue(label, forKey: "label")
        
        println("\(userData)")
        
        // Create and add label node
        if let labelText = userData?.valueForKey("label") as? String {
            println("creating label")
            let labelNode = SKLabelNode(text: labelText)
            labelNode.position = CGPointZero
            labelNode.fontName = "HelveticaNeue-CondensedBold"
            labelNode.fontColor = UIColor.whiteColor()
            labelNode.verticalAlignmentMode = .Center
            labelNode.fontSize = calculateFontSize(labelText)
            addChild(labelNode)
        }
    }
    
    /**
        Assigns the node's sprite, name, and userData given the provided field,
        and configures its physics.
    */
    convenience init(field: String,
        collection: String,
        fieldDict: [String: AnyObject]) {
        
        self.init()
            
        userData = NSMutableDictionary()
        
        // Add field as a property of userData
        userData?.setValue(fieldDict, forKey: "field")
            
        // Add label to userData
        userData?.setValue(collection, forKey: "collection")
        
        // Add label to userData
        userData?.setValue(field, forKey: "label")
            
        // Create and add label node
        if let labelText = userData?.valueForKey("label") as? String {
            println("creating label")
            let labelNode = SKLabelNode(text: labelText)
            labelNode.position = CGPointZero
            labelNode.fontName = "HelveticaNeue-CondensedBold"
            labelNode.fontColor = UIColor.whiteColor()
            labelNode.verticalAlignmentMode = .Center
            labelNode.fontSize = calculateFontSize(labelText)
            addChild(labelNode)
        }
    }
    
    func calculateFontSize(text: String) -> CGFloat {
        
        var scaledFontSize: CGFloat = 32
        let targetWidth = headerTileSize.width - 10
        
        while true {
            
            // Add a hidden label to the tile
            let labelNode = SKLabelNode(text: text)
            labelNode.position = CGPointZero
            labelNode.fontName = "HelveticaNeue-CondensedBold"
            labelNode.fontSize = scaledFontSize
            labelNode.alpha = 0
            labelNode.verticalAlignmentMode = .Center
            addChild(labelNode)
            
            // Calculate the size of the label
            let width = labelNode.calculateAccumulatedFrame().size.width
            
            // If it is too wide
            if width > targetWidth {
                scaledFontSize -= 2
                labelNode.removeFromParent()
            
            // Otherwise, return the current size
            } else {
                
                labelNode.removeFromParent()
                return scaledFontSize
            }
        }
    }
    
    override init() {
        
        let headerTexture = SKTexture(imageNamed: "Predicate Tile Header (Flat)")
        
        super.init(texture: headerTexture, color: UIColor.clearColor(), size: headerTileSize)
        
        centerRect = CGRectMake(0.0, 24.0/50.0, 1.0, 2.0/50.0)
        position = CGPointZero
        name = PredicateTileNodeName
        zPosition = SceneLayer.PredicateTiles.rawValue
        
        physicsBody = SKPhysicsBody(rectangleOfSize: size, center: CGPointZero)
        physicsBody?.affectedByGravity = false
        physicsBody?.dynamic = true
        physicsBody?.categoryBitMask = SceneNodeCategories.PredicateTile.rawValue
        physicsBody?.collisionBitMask = SceneNodeCategories.None.rawValue
        physicsBody?.contactTestBitMask = SceneNodeCategories.PredicateTile.rawValue
        
        userInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        super.touchesBegan(touches, withEvent: event)
        println("touches began")
    }
    
    /**
        Implements a handler for moving tiles around the scene.
    */
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        super.touchesMoved(touches, withEvent: event)
        println("touches moved")
        
        // Get the touch
        if let touch = touches.anyObject() as? UITouch {
            
            // Get the location delta of the touch
            let previousLocation = touch.previousLocationInNode(scene)
            let currentLocation = touch.locationInNode(scene)
            let deltaX = currentLocation.x - previousLocation.x
            let deltaY = currentLocation.y - previousLocation.y
            
            position.x += deltaX
            position.y += deltaY
            
            println("moving node by (\(deltaX), \(deltaY))")
        } else {
            println("no touch")
        }
    }
}
