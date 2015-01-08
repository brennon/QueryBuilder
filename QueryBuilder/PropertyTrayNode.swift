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
    var needsLayout = false
    
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
                withParentTile: nil,
                andDepthCounter: 0
            )
            
            // Add tiles that were just built
            self.addPropertyNodes()
        }
    }
    
    // Adds tiles to propertyNodes based on the information available in the provided dictionary
    func buildTilesFromDictionary(
        dictionary: NSMutableDictionary,
        forField field: String,
        withParentTile parentTile: PropertyTrayTileNode?,
        andDepthCounter depthCounter: Int) {
            
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
                var actualParentTile = parentTile
                
                let keyString = key as String

                let subdictionary =
                    dictionary.objectForKey(key)! as NSMutableDictionary
                
                // If there is no parent tile, this is a top-level tile
                if parentTile == nil {
                    
                    actualParentTile = PropertyTrayTileNode(label: keyString, propertyTrayNode: self, rootTileNode: nil, depth: depthCounter)
                    propertyNodes.append(actualParentTile!)
                    
                } else {
                    
                    let newParentTile = PropertyTrayTileNode(label: keyString, propertyTrayNode: self, rootTileNode: nil, depth: depthCounter)
                    actualParentTile!.childTiles.append(newParentTile)
                    actualParentTile = newParentTile
                }

                buildTilesFromDictionary(
                    subdictionary,
                    forField: keyString,
                    withParentTile: actualParentTile!,
                    andDepthCounter: depthCounter + 1
                )
            }
        }
    }
    
    // Removes all tile constraints, lays out the tray and then the tray tiles, and then replaces constraints
    func updateLayout(staticTile: PropertyTrayTileNode?, animated: Bool, completion: (() -> ())?) {

        removeAllTileConstraints()
        layoutTileNodes(staticTile, animated: animated) {
            if let callableCompletion = completion {
                callableCompletion()
            }
        }
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
    
    // Lays out the tray, then the nodes, then adds all tile nodes in propertyNodes
    func addPropertyNodes() {
        
        removeAllTileConstraints()
        
        layoutTileNodes(nil, animated: false) {
        
            for tileNode in self.propertyNodes {
                self.addChild(tileNode)
            }
            
            self.addTileConstraints()
        }
    }
    
    // Adds a horizontal position constraint to each tile
    func addTileConstraints() {

        let xConstraint = SKConstraint.positionX(SKRange(constantValue: containerNode.size.width / 2))
        xConstraint.referenceNode = containerNode

        for tile in propertyNodes {

            tile.constraints = [xConstraint]
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
    
    func determineAndPositionReferenceTile() -> PropertyTrayTileNode {
        
        var referenceTile: PropertyTrayTileNode
        
        // If there are an even number of tiles, use the tile just above the middle.
        if propertyNodes.count % 2 == 0 {
            
            referenceTile = propertyNodes[(propertyNodes.count / 2) - 1]
            
            // Tile should be one half a tile height plus one half a spacer above center.
            referenceTile.position = CGPointMake(TileMarginWidth + (TileWidth / CGFloat(2)), (TileMarginWidth + TileHeight) / CGFloat(2))
            
            // Otherwise, use the middle tile.
        } else {
            
            referenceTile = propertyNodes[propertyNodes.count / 2]
            
            // Tile should be vertically and horizontally centered in container.
            referenceTile.position = CGPointMake(TileMarginWidth + (TileWidth / CGFloat(2)), 0)
        }
        
        return referenceTile
    }
    
    func layoutTileNodes(referenceTile: PropertyTrayTileNode?, animated: Bool, completion: (() -> ())?) {
        
        // If there isn't a static tile, find one, set its posiiton, and use it as
        // the reference tile.
        
        var actualReferenceTile: PropertyTrayTileNode
        
        if referenceTile != nil {
            actualReferenceTile = referenceTile!
        } else {
            actualReferenceTile = determineAndPositionReferenceTile()
        }
        
        // Get index of static tile
        if let index = find(propertyNodes, actualReferenceTile) {
            
            // Iterate over nodes *above* static tile, moving upward
            for var i = index - 1; i >= 0; i-- {
                layoutTileNode(atIndex: i, aboveReferenceTileAtIndex: index, animated: animated, completion: nil)
            }
            
            
            // Iterate over nodes *below* static tile, moving downward
            for var i = index + 1; i < propertyNodes.count; i++ {
                layoutTileNode(atIndex: i, belowReferenceTileAtIndex: index, animated: animated, completion: nil)
            }
        }
        
        if let callableCompletionC = completion {
            callableCompletionC()
        }
    }
    
    private func layoutTileNode(
        atIndex index: Int,
        aboveReferenceTileAtIndex referenceTileIndex: Int,
        animated: Bool,
        completion: (() -> ())?) {
            
            // Calculate vertical position of this tile based on heights of tiles below it.
            var currentTile = propertyNodes[referenceTileIndex]
            var y = currentTile.position.y + (TileHeight / CGFloat(2)) + TileMarginHeight
            for var i = referenceTileIndex - 1; i > index; i-- {
                currentTile = propertyNodes[i]
                y += currentTile.calculateAccumulatedFrame().height + TileMarginHeight
            }
            y += TileHeight / CGFloat(2)
            var tilePosition = CGPointMake(TileMarginWidth + (TileWidth / CGFloat(2)), y)
            
            // Move the tile into position.
            if animated {
                propertyNodes[index].runAction(SKAction.moveTo(tilePosition, duration: PropertyTrayTileExpandDuration))
            } else {
                propertyNodes[index].position = tilePosition
            }
    }
    
    private func layoutTileNode(
        atIndex index: Int,
        belowReferenceTileAtIndex referenceTileIndex: Int,
        animated: Bool,
        completion: (() -> ())?) {
        
        // Calculate vertical position of this tile based on heights of tiles above it.
        var currentTile = propertyNodes[referenceTileIndex]
        var y = currentTile.position.y - currentTile.calculateAccumulatedFrame().height + (TileHeight / CGFloat(2)) - TileMarginHeight
        for var i = referenceTileIndex + 1; i < index; i++ {
            currentTile = propertyNodes[i]
            y -= currentTile.calculateAccumulatedFrame().height + TileMarginHeight
        }
        y -= TileHeight / CGFloat(2)
        var tilePosition = CGPointMake(TileMarginWidth + (TileWidth / CGFloat(2)), y)
        
        // Move the tile into position.
        if animated {
            propertyNodes[index].runAction(SKAction.moveTo(tilePosition, duration: PropertyTrayTileExpandDuration))
        } else {
            propertyNodes[index].position = tilePosition
        }
    }
    
    func scrollTiles(dy: CGFloat) {
        
        for tile in propertyNodes {
            tile.position = CGPointMake(tile.position.x, tile.position.y + dy)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
