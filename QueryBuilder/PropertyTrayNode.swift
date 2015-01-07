//
//  PropertyTrayNode.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 12/8/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import SpriteKit

class PropertyTrayNode: SKCropNode {
    
    var containerNode: SKSpriteNode!
    /*
    var handleNode: SKSpriteNode!
    */
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
        addContainerNode() {
            
            // Build PropertyTrayTileNodes from dictionary in collection
            self.buildTilesFromDictionary(
                collection.fields,
                forField: "",
                withParentTile: nil
            )
            
            // Add tiles that were just built
            self.addPropertyNodes()
        }
        
        /*
        // Add handle node
        addHandleNode()
        */
    }
    
    // Adds tiles to propertyNodes based on the information available in the provided dictionary
    func buildTilesFromDictionary(
        dictionary: NSMutableDictionary,
        forField field: String,
        withParentTile parentTile: PropertyTrayTileNode?) {
            
        // If dictionary has a values key, add it to the parentTile
        if let values: AnyObject = dictionary.valueForKey("values") {
            
            parentTile?.propertyDict = dictionary
        
        // Otherwise, send the contained dictionary back to this method
        } else {
            
            // Get all keys from dictionary and sort in reverse order
            var allKeys = dictionary.allKeys as [String]
            allKeys.sort {
                $0 < $1
            }

            // Iterate over keys
            for (index, key) in enumerate(allKeys) {
//                if index < 7 {
                    var actualParentTile = parentTile
                    
                    let keyString = key as String

                    let subdictionary =
                        dictionary.objectForKey(key)! as NSMutableDictionary
                    
                    // If there is no parent tile, this is a top-level tile
                    if parentTile == nil {
                        
                        actualParentTile = PropertyTrayTileNode(label: keyString, propertyTrayNode: self, rootTileNode: nil)
                        propertyNodes.append(actualParentTile!)
                        
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
//                }
            }
        }
    }
    
    // Removes all tile constraings, lays out the tray and then the tray tiles, and then replaces constraints
    func updateLayout(staticTile: PropertyTrayTileNode?, completion: (() -> ())?) {
        
        println("updateLayout")
        
        removeAllTileConstraints()
//        resizeContainer {
            layoutTileNodes(staticTile, animated: true) {
                self.addTileConstraints()
                
                if let callableCompletion = completion {
                    callableCompletion()
                }
            }
//        }
    }
    
    // Adds and animates in the container node, and then calls handleNode
    func addContainerNode(completion: (() -> ())?) {
        
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
        containerNode.runAction(groupAction)
        
        let newMaskNode = containerNode.copy() as SKSpriteNode
        maskNode = newMaskNode
        
        resizeContainer() {
            if let callableCompletionA = completion {
                callableCompletionA()
            }
        }
    }
    
    /*
    // Adds the handlenode
    func addHandleNode() {
        
        // Build and add handle
        handleNode = SKSpriteNode(color: UIColor.greenColor(), size: CGSizeMake(20, 60))
        handleNode.anchorPoint = CGPointMake(0, 0.5)
        handleNode.position = CGPointMake(containerNode.size.width, 0)
        handleNode.zPosition = SceneLayer.PropertyTrayHandle.rawValue
        addChild(handleNode)
    }
    */
    
    // Lays out the tray, then the nodes, then adds all tile nodes in propertyNodes
    func addPropertyNodes() {
        
        layoutTileNodes(nil, animated: false) {
        
            for tileNode in self.propertyNodes {
                self.addChild(tileNode)
            }
        }
    }
    
    // Adds a horizontal position constraint to each tile
    func addTileConstraints() {

        let xConstraint = SKConstraint.positionX(SKRange(constantValue: containerNode.size.width / 2))
        xConstraint.referenceNode = containerNode

        propertyNodes[0].constraints?.append(xConstraint)

        for i in 1 ..< propertyNodes.count {

            // Calculate rectangle of upper tile
            let upperNodeRect = propertyNodes[i - 1].calculateAccumulatedFrame()

//            let lowerConstraint = SKConstraint.positionY(SKRange(constantValue: propertyNodes[0].position.y - TileHeight - TileMarginWidth))
//            lowerConstraint.referenceNode = propertyNodes[i - 1]
//
//            let upperConstraint = SKConstraint.positionY(SKRange(constantValue: propertyNodes[1].position.y + TileHeight + TileMarginWidth))
//            upperConstraint.referenceNode = propertyNodes[i]
//
//            propertyNodes[i - 1].constraints?.append(upperConstraint)
//            propertyNodes[i].constraints?.append(lowerConstraint)
            propertyNodes[i].constraints?.append(xConstraint)
        }
    }

    // Removes all constraints from all tiles
    func removeAllTileConstraints() {
        for node in propertyNodes {
            node.constraints = []
        }
    }
    
    // Adjusts the size of the tray and mask node to contain all tiles
    func resizeContainer(completion: (() -> ())?) {
        
        // Create new rect for border
        maskNode?.runAction(SKAction.resizeToWidth(containerNode.size.width, height: PropertyTrayMaximumHeight, duration: 1))
        containerNode.runAction(SKAction.resizeToHeight(PropertyTrayMaximumHeight, duration: 1)) {
            if let callableCompletionB = completion {
                callableCompletionB()
            }
        }
    }
    
    func layoutTileNodes(staticTile: PropertyTrayTileNode?, animated: Bool, completion: (() -> ())?) {
        
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
                    thisNodeY += TileMarginWidth
                    thisNodeY += thisNodeSize.height
                    
                    if animated {
                        thisNode.runAction(SKAction.moveTo(CGPointMake(thisNodeX, thisNodeY), duration: 1.0))
                    } else {
                        thisNode.position = CGPointMake(thisNodeX, thisNodeY)
                    }
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
                    thisNodeY -= nodeAboveSize.height// - (TileHeight / CGFloat(2))
                    thisNodeY -= TileMarginWidth
                    
//                    if animated {
//                        thisNode.runAction(SKAction.moveTo(CGPointMake(thisNodeX, thisNodeY), duration: 1.0))
//                    } else {
                        thisNode.position = CGPointMake(thisNodeX, thisNodeY)
//                    }
                }
                
                if let callableCompletionC = completion {
                    callableCompletionC()
                }
            }
        } else {
            if propertyNodes.count % 2 == 0 {
                layoutEvenNumberOfTileNodes(staticTile, nodeCount: propertyNodes.count, animated: animated) {
                    if let callableCompletionD = completion {
                        callableCompletionD()
                    }
                }
            } else {
                layoutOddNumberOfTileNodes(staticTile, nodeCount: propertyNodes.count, animated: animated)  {
                    if let callableCompletionE = completion {
                        callableCompletionE()
                    }
                }
            }
        }
    }
    
    private func layoutEvenNumberOfTileNodes(staticTile: PropertyTrayTileNode?, nodeCount: Int, animated: Bool, completion: (() -> ())?) {
        
        let halfNodes = nodeCount / 2
        
        let animationDuration: NSTimeInterval = 1.0
        
        // Layout all tiles centered around the middle of the screen
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
            
//            if animated {
//                node.runAction(SKAction.moveTo(CGPointMake(x, y), duration: animationDuration))
//            } else {
                node.position = CGPointMake(x, y)
//            }
        }
        
        // Call completion closure if we received one.
        if let callableCompletion = completion {
            
            // If the layout was animated, we need to wait animationDuration.
            if animated {
                self.runAction(SKAction.waitForDuration(animationDuration)) {
                    callableCompletion()
                }
            } else {
                callableCompletion()
            }
        }
    }
    
    private func layoutOddNumberOfTileNodes(staticTile: PropertyTrayTileNode?, nodeCount: Int, animated: Bool, completion: (() -> ())?) {
        
        let halfNodes = nodeCount / 2
        
        let animationDuration: NSTimeInterval = 1.0
        
        // Layout all tiles centered around the middle of the screen
        for (index, node) in enumerate(propertyNodes) {
            
            let x = TileMarginWidth + (node.size.width / 2)
            var y: CGFloat
            
            // If this node is in the top section
            if index < halfNodes {
                let spaces = CGFloat(halfNodes - index) * TileMarginWidth
                let tiles = CGFloat(halfNodes - index) * TileHeight
                y = spaces + tiles
                
            // If this node is in the bottom section
            } else if index > halfNodes {
                let spaces = CGFloat(index - halfNodes) * TileMarginWidth
                let tiles = CGFloat(index - halfNodes) * TileHeight
                y = -(spaces + tiles)
            
            // If this is the middle node
            } else {
                y = 0
            }
            
            node.removeAllActions()
            
            if animated {
                node.runAction(SKAction.moveTo(CGPointMake(x, y), duration: 1))
            } else {
                node.position = CGPointMake(x, y)
            }
        }
        
        // Call completion closure if we received one.
        if let callableCompletion = completion {
            
            // If the layout was animated, we need to wait animationDuration.
            if animated {
                self.runAction(SKAction.waitForDuration(animationDuration)) {
                    callableCompletion()
                }
            } else {
                callableCompletion()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
