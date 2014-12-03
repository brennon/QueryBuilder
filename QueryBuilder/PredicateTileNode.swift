//
//  PredicateTileNode.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 12/3/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import SpriteKit

class PredicateTileNode: SKSpriteNode {
    
    let headerTileSize = CGSizeMake(BoxWidth, BoxHeight)
    
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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
