//
//  PropertyTrayTileNode.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 12/13/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import SpriteKit

class PropertyTrayTileNode: SKSpriteNode {
    
    var propertyDict: NSMutableDictionary?
//    var label: String
    var childTiles = [PropertyTrayTileNode]()
    
    convenience init(label: String) {
        
        self.init()
        
//        self.label = label
        
        // Create and add label node
//        if let labelText = propertyDict?.valueForKey("label") as? String {
            println("creating label")
            let labelNode = SKLabelNode(text: label)
            labelNode.position = CGPointZero
            labelNode.fontName = "HelveticaNeue-CondensedBold"
            labelNode.fontColor = UIColor.whiteColor()
            labelNode.verticalAlignmentMode = .Center
            labelNode.fontSize = calculateFontSize(label)
            addChild(labelNode)
//        } else {
//            println("propertyDict: \(propertyDict)")
//        }
    }
    
    override init() {
        
        // Initialize properties
        propertyDict = NSMutableDictionary()
        
        let headerTexture = SKTexture(imageNamed: "Predicate Tile Header (Flat)")
        
        super.init(texture: headerTexture, color: UIColor.clearColor(), size: CGSizeMake(BoxWidth, BoxHeight))
        
        centerRect = CGRectMake(0.0, 24.0/50.0, 1.0, 2.0/50.0)
        position = CGPointZero
        name = PredicateTileNodeName
        zPosition = SceneLayer.PredicateTiles.rawValue
        
        physicsBody = SKPhysicsBody(rectangleOfSize: size, center: CGPointZero)
        physicsBody?.categoryBitMask = SceneNodeCategories.PredicateTile.rawValue
        physicsBody?.collisionBitMask = SceneNodeCategories.None.rawValue
        physicsBody?.contactTestBitMask = SceneNodeCategories.PredicateTile.rawValue
        
        userInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func calculateFontSize(text: String) -> CGFloat {
        
        var scaledFontSize: CGFloat = 32
        let targetWidth = BoxWidth - 10
        
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
}
