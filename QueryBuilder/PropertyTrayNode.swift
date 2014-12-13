//
//  PropertyTrayNode.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 12/8/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import SpriteKit

class PropertyTrayNode: SKNode {
    
    var borderNode: SKShapeNode!
    var propertyNodes = [PredicateTileNode]()
    let propertyNodePadding: CGFloat = 10
    
    convenience init(collection: Collection) {
        
        self.init()
        
        // Iterate over Collection fields and add PredicateTileNodes for each
        for field in collection.fields.keys {
            println("field: \(field)")
            
            if let dict = collection.fields[field] {
             
                var newNode = PredicateTileNode(field: field, collection: collection.collectionName, fieldDict: dict)
                
                addPropertyNode(newNode)
            }
        }
    }
    
    override init() {
        
        super.init()
        
//        let headerTexture = SKTexture(imageNamed: "Predicate Tile Header (Flat)")
        
//        super.init(texture: headerTexture, color: UIColor.clearColor(), size: headerTileSize)
        
//        centerRect = CGRectMake(0.0, 24.0/50.0, 1.0, 2.0/50.0)
//        position = CGPointZero
//        name = PredicateTileNodeName
//        zPosition = SceneLayer.PredicateTiles.rawValue
        
//        physicsBody = SKPhysicsBody(rectangleOfSize: size, center: CGPointZero)
//        physicsBody?.affectedByGravity = false
//        physicsBody?.dynamic = true
//        physicsBody?.categoryBitMask = SceneNodeCategories.PredicateTile.rawValue
//        physicsBody?.collisionBitMask = SceneNodeCategories.None.rawValue
//        physicsBody?.contactTestBitMask = SceneNodeCategories.PredicateTile.rawValue
        
        // Add border node
        addBorderNode()
    }
    
    func addBorderNode() {
        
        let borderTexture = SKTexture(imageNamed: "Border")
        
        // Calculate rect for border
        borderNode = SKShapeNode()
        borderNode.position = CGPointMake(0, 0)
        borderNode.strokeColor = UIColor.trayBorderColor()
        addChild(borderNode)
    }
    
    func addPropertyNode(propertyNode: PredicateTileNode) {
        
        propertyNodes.append(propertyNode)
        
        growBorder()
        
        borderNode.addChild(propertyNode)
        
        positionPropertyNodes()
    }
    
    func growBorder() {
        
        // Calculate height of current properties
        var propertiesHeight: CGFloat = 0
        
        for node in propertyNodes {
            
            propertiesHeight += node.size.height
        }
        
        // Add padding between each tile, above top tile, and below bottom tile
        propertiesHeight += propertyNodePadding * CGFloat(propertyNodes.count + 1)
        
        // Create new rect for border
        let borderRect = CGRectMake(0, 0, propertyNodes[0].size.width + (2 * propertyNodePadding), propertiesHeight)
        borderNode.path = CGPathCreateWithRoundedRect(borderRect, 10, 10, nil)
    }
    
    func positionPropertyNodes() {
        
        for (index, node) in enumerate(propertyNodes) {
            
            let x = propertyNodePadding + (node.size.width / 2)
            
            let y = (CGFloat(index) * (node.size.height + propertyNodePadding)) + (node.size.height / 2) + propertyNodePadding
            node.position = CGPointMake(x, y)
            
            println("x: \(x), y: \(y)")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
