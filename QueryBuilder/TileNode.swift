//
//  TileNode.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 12/13/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import SpriteKit

/**
    Superclass for 'tile' nodes used to represent document properties,
    predicates, etc.
*/
class TileNode: SKSpriteNode {
    
    var labelNode: SKLabelNode?
    
    /**
        Convenience initializer that adds a label to the tile node.
    
        :param: label The string to use for the label for the tile node.
    */
    convenience init(label: String) {
        
        self.init()
        
        // Create and add label node
        labelNode = SKLabelNode(text: label)
        labelNode!.position = CGPointZero
        labelNode!.fontName = TileLabelFontName
        labelNode!.fontColor = TileLabelFontColor
        labelNode!.verticalAlignmentMode = .Center
        labelNode!.fontSize = calculateFontSize(label)
        addChild(labelNode!)
    }
    
    override init() {
        
        // Initialize properties
        let headerTexture =
            SKTexture(imageNamed: "Predicate Tile Header (Flat)")
        
        super.init(
            texture: headerTexture,
            color: UIColor.clearColor(),
            size: CGSizeMake(TileWidth, TileHeight)
        )
        
        centerRect = CGRectMake(0.0, 24.0/50.0, 1.0, 2.0/50.0)
        position = CGPointZero
        zPosition = SceneLayer.PredicateTiles.rawValue
        
//        physicsBody = SKPhysicsBody(
//            rectangleOfSize: size,
//            center: CGPointZero
//        )
//        
//        physicsBody?.categoryBitMask =
//            SceneNodeCategories.PredicateTile.rawValue
//        physicsBody?.collisionBitMask = SceneNodeCategories.None.rawValue
//        physicsBody?.contactTestBitMask =
//            SceneNodeCategories.PredicateTile.rawValue
        
        userInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func calculateFontSize(text: String) -> CGFloat {
        
        var scaledFontSize: CGFloat = 18
        let targetWidth = TileWidth - 10
        
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
