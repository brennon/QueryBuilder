//
//  PropertyTrayNode.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 12/8/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import SpriteKit

class PropertyTrayNode: SKNode {
    
    var containerNode: SKSpriteNode!
    var propertyNodes = [PropertyTrayTileNode]()
    let propertyNodePadding: CGFloat = 10
    
    /**
        Designated initializer. Builds the `PropertyTrayNode` with 
        `PropertyTrayTileNodes` constructed from the collection of tiles 
        represented by the `fields` dictionary in a `Collection`.

        :param: collection The `Collection` to use to build the 
            `PropertyTrayTileNodes`.
    */
    init(collection: Collection) {
        
        super.init()
        
        // Position the main node
        position = CGPointZero
        
        // Add container node
        addContainerNode()
        
        // Build PropertyTrayTileNodes from dictionary in collection
//        buildTilesFromDictionary(
//            collection.fields,
//            forField: "",
//            withParentTile: nil
//        )
    }
    
    func buildTilesFromDictionary(
        dictionary: NSMutableDictionary,
        forField field: String,
        withParentTile parentTile: PropertyTrayTileNode?) {
        
        // If dictionary has a values key, add it to the parentTile
        if let values: AnyObject = dictionary.valueForKey("values") {
            
            parentTile?.propertyDict = dictionary
        
        // Otherwise, send the contained dictionary back to this method
        } else {
            
            // Get all keys from dicitonary and sort in reverse order
            var allKeys = dictionary.allKeys as [String]
            allKeys.sort {
                $1 < $0
            }

            // Iterate over keys
            for key in allKeys {
                
                var actualParentTile = parentTile
                
                let keyString = key as String

                let subdictionary =
                    dictionary.objectForKey(key)! as NSMutableDictionary
                
                // If there is no parent tile, this is a top-level tile
                if parentTile == nil {
                    
                    actualParentTile = PropertyTrayTileNode(label: keyString)
                    addPropertyNode(actualParentTile!)
                    
                } else {
                    
                    let newParentTile = PropertyTrayTileNode(label: keyString)
                    actualParentTile!.childTiles.append(newParentTile)
                    actualParentTile = newParentTile
                    
                }

                buildTilesFromDictionary(
                    subdictionary,
                    forField: keyString,
                    withParentTile: actualParentTile!
                )
            }
        }
    }
    
    func addContainerNode() {
        
        containerNode = SKSpriteNode(
            color: PropertyTrayContainerColor,
            size: CGSizeMake(100, 600)
        )
        containerNode.anchorPoint = CGPointMake(0, 0.5)
        addChild(containerNode)
        addHandleNode()
    }
    
    func addHandleNode() {
        
        let handleNode = SKSpriteNode(color: UIColor.greenColor(), size: CGSizeMake(20, 60))
        handleNode.anchorPoint = CGPointMake(0, 0.5)
        handleNode.position = CGPointMake(containerNode.size.width, 0)
        containerNode.addChild(handleNode)
        
        containerNode.runAction(SKAction.resizeToHeight(100, duration: 10))
    }
    
    func addPropertyNode(propertyNode: PropertyTrayTileNode) {
        
        propertyNodes.append(propertyNode)
        
        growBorder()
        
        containerNode.addChild(propertyNode)
        
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
//        borderNode.path = CGPathCreateWithRoundedRect(borderRect, 10, 10, nil)
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
