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
        
        // Name the node
        name = PropertyTrayNodeName
        
        // Position the main node
        position = CGPointZero
        
        // Add container node
        addContainerNode()
        
//        let newMaskNode = containerNode.copy() as SKSpriteNode
//        maskNode = newMaskNode
        
        // Build PropertyTrayTileNodes from dictionary in collection
        buildTilesFromDictionary(
            collection.fields,
            forField: "",
            withParentTile: nil
        )
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
                $0 < $1
            }

            // Iterate over keys
            for (index, key) in enumerate(allKeys) {
                
                var actualParentTile = parentTile
                
                let keyString = key as String

                let subdictionary =
                    dictionary.objectForKey(key)! as NSMutableDictionary
                
                // If there is no parent tile, this is a top-level tile
                if parentTile == nil {
                    
                    actualParentTile = PropertyTrayTileNode(label: keyString, propertyTrayNode: self, rootTileNode: nil)
                    addPropertyNode(actualParentTile!)
                    
                } else {
                    
                    let newParentTile = PropertyTrayTileNode(label: keyString, propertyTrayNode: self, rootTileNode: nil)
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
    
    func updateLayout(staticTile: PropertyTrayTileNode?) {
        layoutTray()
        
//        // Copy the container node
//        let newMaskNode = containerNode.copy() as SKSpriteNode
//        maskNode = newMaskNode
        
        layoutTileNodes(staticTile)
    }
    
    func addContainerNode() {
        
        // Build and add container
        containerNode = SKSpriteNode(
            color: PropertyTrayContainerColor,
            size: CGSizeMake(TileWidth + (2 * TileMarginWidth), TileWidth)
        )
        containerNode.anchorPoint = CGPointMake(0, 0.5)
        containerNode.alpha = 0
        containerNode.zPosition = SceneLayer.PropertyTrayContainer.rawValue
        containerNode.name = PropertyTrayContainerNodeName
        addChild(containerNode)
        
        // Animate in container, then add handle node
        let fadeInAction = SKAction.fadeInWithDuration(1)
        let groupAction = SKAction.group([fadeInAction])
        groupAction.timingMode = .EaseOut
        containerNode.runAction(groupAction) {
            self.addHandleNode()
        }
    }
    
    func addHandleNode() {
        
        // Build and add handle
        let handleNode = SKSpriteNode(color: UIColor.greenColor(), size: CGSizeMake(20, 60))
        handleNode.anchorPoint = CGPointMake(0, 0.5)
        handleNode.position = CGPointMake(containerNode.size.width, 0)
        handleNode.zPosition = SceneLayer.PropertyTrayHandle.rawValue
        addChild(handleNode)
        
//        // Slide handle to right
//        let alphaAction = SKAction.fadeInWithDuration(0)
//        let moveAction = SKAction.moveTo(CGPointMake(containerNode.size.width, 0), duration: 0.5)
//        moveAction.timingMode = .EaseOut
//        let sequenceAction = SKAction.sequence([alphaAction, moveAction])
//        handleNode.runAction(sequenceAction)
    }
    
    func addPropertyNode(propertyNode: PropertyTrayTileNode) {
        
        propertyNodes.append(propertyNode)
        
        // Configure position
        let totalTiles = propertyNodes.count
        if totalTiles == 1 {
            propertyNode.position = CGPointMake(TileWidth / 2 + TileMarginWidth, 0)
        } else {
            let previousTile = propertyNodes[totalTiles - 2]
            propertyNode.position = CGPointMake(TileWidth / 2 + TileMarginWidth, 0)
        }
        
        addChild(propertyNode)
        
        updateLayout(nil)
    }
    
//    func addTileConstraints() {
//        
//        let xConstraint = SKConstraint.positionX(SKRange(constantValue: containerNode.size.width / 2))
//        xConstraint.referenceNode = containerNode
//        
//        propertyNodes[0].constraints?.append(xConstraint)
//        
//        for i in 1 ..< propertyNodes.count {
//            
//            // Calculate rectangle of upper tile
//            let upperNodeRect = propertyNodes[i - 1].calculateAccumulatedFrame()
//            println("upperNodeRect \(upperNodeRect)")
//            
//            let lowerConstraint = SKConstraint.positionY(SKRange(constantValue: propertyNodes[0].position.y - TileHeight - TileMarginWidth))
//            lowerConstraint.referenceNode = propertyNodes[i - 1]
//
//            let upperConstraint = SKConstraint.positionY(SKRange(constantValue: propertyNodes[1].position.y + TileHeight + TileMarginWidth))
//            upperConstraint.referenceNode = propertyNodes[i]
//
//            propertyNodes[i - 1].constraints?.append(upperConstraint)
//            propertyNodes[i].constraints?.append(lowerConstraint)
//            propertyNodes[i].constraints?.append(xConstraint)
//        }
//    }
    
    func removeAllTileConstraints() {
        for node in propertyNodes {
            node.constraints = []
        }
    }
    
    func layoutTray() {
        
        // Calculate height of current tiles
        var propertiesHeight: CGFloat = 0
        
        propertiesHeight += TileHeight * CGFloat(propertyNodes.count)
        
        // Add padding between each tile, above top tile, and below bottom tile
        propertiesHeight += TileMarginWidth * CGFloat(propertyNodes.count + 1)
        
        // Create new rect for border
        containerNode.runAction(SKAction.resizeToHeight(propertiesHeight, duration: 1))
        
//        // Reposition scrolling indicators
//        topScrollingIndicator.runAction(SKAction.moveToY(propertiesHeight / 2 - TileHeight / 4, duration: 5))
//        bottomScrollingIndicator.runAction(SKAction.moveToY(-(propertiesHeight / 2) - (TileHeight / 4), duration: 5))
    }
    
    func layoutTileNodes(staticTile: PropertyTrayTileNode?) {
        if propertyNodes.count % 2 == 0 {
            layoutEvenNumberOfTileNodes(staticTile, nodeCount: propertyNodes.count)
        } else {
            layoutOddNumberOfTileNodes(staticTile, nodeCount: propertyNodes.count)
        }
    }
    
    private func layoutEvenNumberOfTileNodes(staticTile: PropertyTrayTileNode?, nodeCount: Int) {
        let halfNodes = nodeCount / 2
        
        // If we're keeping one tile in place
        if staticTile != nil {
            
            // Get index of static tile
            if let index = find(propertyNodes, staticTile!) {
                
                // Iterate over nodes *above* static tile, moving upward
                for var i = index - 1; i >= 0; i-- {
                    
                    let thisNode = propertyNodes[i]
                    let nodeBelow = propertyNodes[i + 1]
                    
                    // Get the size of this node
                    let thisNodeSize = thisNode.calculateAccumulatedFrame()
                    
                    // Get the size and position of the node below
                    let nodeBelowSize = nodeBelow.calculateAccumulatedFrame()
                    let nodeBelowPosition = nodeBelow.position
                    
                    let thisNodeX = TileMarginWidth + (TileWidth / CGFloat(2))
                    var thisNodeY = nodeBelowPosition.y
                    thisNodeY += (TileHeight / CGFloat(2))
                    thisNodeY += TileMarginWidth
                    thisNodeY += (thisNodeSize.height / CGFloat(2))
                    
                    thisNode.position = CGPointMake(thisNodeX, thisNodeY)
                }
                
                // Iterate over nodes *below* static tile, moving downward
                for var i = index + 1; i < propertyNodes.count; i++ {
                    
                    let thisNode = propertyNodes[i]
                    let nodeAbove = propertyNodes[i - 1]
                    
                    // Get the size of this node
                    let thisNodeSize = thisNode.calculateAccumulatedFrame()
                    
                    // Get the size and position of the node below
                    let nodeAboveSize = nodeAbove.calculateAccumulatedFrame()
                    let nodeAbovePosition = nodeAbove.position
                    
                    let thisNodeX = TileMarginWidth + (TileWidth / CGFloat(2))
                    var thisNodeY = nodeAbovePosition.y
                    thisNodeY -= nodeAboveSize.height - (TileHeight / CGFloat(2))
                    thisNodeY -= TileMarginWidth
                    thisNodeY -= (thisNodeSize.height / CGFloat(2))
                    
                    thisNode.position = CGPointMake(thisNodeX, thisNodeY)
                }
            }
        
        // Otherwise, layout all tiles centered around the middle of the screen
        } else {
            for (index, node) in enumerate(propertyNodes) {
                
                let x = TileMarginWidth + (node.size.width / 2)
                var y: CGFloat
                
                if index < halfNodes {
                    let spaces = CGFloat(halfNodes - index - 1) * TileMarginWidth
                    let halfSpace = TileMarginWidth * 0.5
                    let tiles = CGFloat(halfNodes - index) * TileHeight
                    y = spaces + halfSpace + tiles - (CGFloat(TileHeight) / 2)
                } else {
                    let spaces = CGFloat(index - halfNodes) * TileMarginWidth
                    let halfSpace = TileMarginWidth * 0.5
                    let tiles = CGFloat(index - halfNodes + 1) * TileHeight
                    y = -(spaces + halfSpace + tiles) + (CGFloat(TileHeight) / 2)
                }
                
                node.removeAllActions()
                node.runAction(SKAction.moveTo(CGPointMake(x, y), duration: 1))
            }
        }
    }
    
    private func layoutOddNumberOfTileNodes(staticTile: PropertyTrayTileNode?, nodeCount: Int) {
//        let halfNodes = nodeCount / 2
//        
//        for (index, node) in enumerate(propertyNodes) {
//            
//            let x = TileMarginWidth + (node.size.width / 2)
//            let spaces = CGFloat(halfNodes - index - 1) * TileMarginWidth
//            let halfSpace = TileMarginWidth * 0.5
//            let tiles = CGFloat(halfNodes - index) * TileHeight
//            var y: CGFloat
//            
//            if index < halfNodes {
//                y = spaces + halfSpace + tiles
//            } else {
//                y = -(spaces + halfSpace + tiles)
//            }
//            
//            node.removeAllActions()
//            node.runAction(SKAction.moveTo(CGPointMake(x, y), duration: 1))
//        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
