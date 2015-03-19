//
//  PredicateGroupNode.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 3/18/15.
//  Copyright (c) 2015 Brennon Bortz. All rights reserved.
//

import SpriteKit

class PredicateGroupNode: SKNode {
    
    // MARK: Properties
    
    var predicates: [PredicateTileNode]!
    var containerNode: SKSpriteNode? = nil

    // MARK: Initialization
    
    init?(predicates: [PredicateTileNode], scene: SKScene) {
        
        self.predicates = predicates
        super.init()
        self.name = PredicateGroupNodeName
        
        for predicate in predicates {
            if let group = predicate.predicateGroup {
                group.addPredicates(predicates)
                return nil
            }
        }
        
        for predicate in predicates {
            predicate.predicateGroup = self
        }
        
        scene.addChild(self)
        updateLayout()
        
        println("Created predicate group with \(self.predicates)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Visual Representation
    
    func updateLayout() {
        if predicates.count <= 1 {
            return
        }
        
        // Get bounding rectangle for centers of all tiles.
        var minX: CGFloat = CGFloat.max
        var minY: CGFloat = CGFloat.max
        var maxX: CGFloat = CGFloat.min
        var maxY: CGFloat = CGFloat.min
        
        for node in predicates {
            let convertedPoint = scene!.convertPoint(node.position, fromNode: node.parent!)
            minX = min(minX, convertedPoint.x)
            minY = min(minY, convertedPoint.y)
            maxX = max(maxX, convertedPoint.x)
            maxY = max(maxY, convertedPoint.y)
        }
        
        var width = maxX - minX
        var height = maxY - minY
        
        let centeredRect = CGRectMake(minX, minY, width, height)
        let center = CGPointMake(centeredRect.midX, centeredRect.midY)
        
        // Move tiles into new positions
        if predicates.count % 2 == 0 {
            let leftOfMiddleIndex = Int(predicates.count / 2) - 1
            for i in 0 ... leftOfMiddleIndex {
                let offset = CGFloat(leftOfMiddleIndex - i)
                let positionX = center.x - (offset * TileSize.width) - (TileSize.width / 2) - (offset * PredicateGroupTileMarginWidth) - (PredicateGroupTileMarginWidth / 2)
                let position = CGPointMake(positionX, center.y)
                let moveEffect = SKTMoveEffect(node: predicates[i], duration: 1, startPosition: predicates[i].position, endPosition: position)
                moveEffect.timingFunction = SKTTimingFunctionElasticEaseOut
                predicates[i].runAction(SKAction.actionWithEffect(moveEffect))
            }
            for i in (leftOfMiddleIndex + 1) ..< predicates.count {
                let offset = CGFloat(i - (leftOfMiddleIndex + 1))
                let positionX = center.x + (offset * TileSize.width) + (TileSize.width / 2) + (offset * PredicateGroupTileMarginWidth) + (PredicateGroupTileMarginWidth / 2)
                let position = CGPointMake(positionX, center.y)
                let moveEffect = SKTMoveEffect(node: predicates[i], duration: 1, startPosition: predicates[i].position, endPosition: position)
                moveEffect.timingFunction = SKTTimingFunctionElasticEaseOut
                predicates[i].runAction(SKAction.actionWithEffect(moveEffect))
            }
        } else {
            
            // For 5 predicates, lomi = 1
            
            let leftOfMiddleIndex = Int(predicates.count / 2) - 1
            
            // Counts 0, 1
            for i in 0 ... leftOfMiddleIndex {
                let offset = CGFloat(leftOfMiddleIndex + 1 - i)
                let positionX = center.x - (offset * TileSize.width) - (offset * PredicateGroupTileMarginWidth)
                let position = CGPointMake(positionX, center.y)
                let moveEffect = SKTMoveEffect(node: predicates[i], duration: 1, startPosition: predicates[i].position, endPosition: position)
                moveEffect.timingFunction = SKTTimingFunctionElasticEaseOut
                predicates[i].runAction(SKAction.actionWithEffect(moveEffect))
            }
            
            // Counts 3, 4
            for i in (leftOfMiddleIndex + 2) ..< predicates.count {
                let offset = CGFloat(i - leftOfMiddleIndex - 1)
                let positionX = center.x + (offset * TileSize.width) + (offset * PredicateGroupTileMarginWidth)
                let position = CGPointMake(positionX, center.y)
                let moveEffect = SKTMoveEffect(node: predicates[i], duration: 1, startPosition: predicates[i].position, endPosition: position)
                moveEffect.timingFunction = SKTTimingFunctionElasticEaseOut
                predicates[i].runAction(SKAction.actionWithEffect(moveEffect))
            }
            
            let moveEffect = SKTMoveEffect(node: predicates[leftOfMiddleIndex + 1], duration: 1, startPosition: predicates[leftOfMiddleIndex + 1].position, endPosition: center)
            moveEffect.timingFunction = SKTTimingFunctionElasticEaseOut
            predicates[leftOfMiddleIndex + 1].runAction(SKAction.actionWithEffect(moveEffect))
        }
    }
    
    func drawConnectorNode(afterDelay: CGFloat) {
        let height: CGFloat = 15
        let width = (TileSize.width * CGFloat(predicates.count)) + (PredicateGroupTileMarginWidth * CGFloat(predicates.count - 1))
        
        containerNode?.removeFromParent()
        containerNode = SKSpriteNode(color: SKColor.blackColor(), size: CGSizeMake(width, height))
        
        var centerPoint: CGPoint
        if predicates.count % 2 == 0 {
            let leftCenterTile = predicates[predicates.count / 2]
            let leftCenterPosition = scene!.convertPoint(leftCenterTile.position, fromNode: leftCenterTile.parent!)
            centerPoint = CGPointMake(leftCenterPosition.x - (TileSize.width / 2) - (CGFloat(PredicateGroupTileMarginWidth) / 2), leftCenterPosition.y)
        } else {
            let centerTile = predicates[predicates.count / 2]
            let centerPosition = scene!.convertPoint(centerTile.position, fromNode: centerTile.parent!)
            centerPoint = centerPosition
        }
        
        containerNode!.alpha = 0.1
        containerNode!.position = centerPoint
        scene!.addChild(containerNode!)
    }
    
    func translateAllTiles(dx: CGFloat, dy: CGFloat) {
        for predicate in predicates {
            predicate.runAction(SKAction.moveByX(dx, y: dy, duration: 0))
        }
    }
    
    func update() {
        drawConnectorNode(0)
    }
    
    // MARK: Predicate Management
    
    func addPredicate(predicate: PredicateTileNode) {
        let existingIndex = find(self.predicates, predicate)
        
        if existingIndex == nil {
            predicate.predicateGroup = self
            self.predicates.append(predicate)
        }
    }
    
    func addPredicates(predicates: [PredicateTileNode]) {
        for predicate in predicates {
            addPredicate(predicate)
        }
        updateLayout()
    }
    
    func removePredicate(predicate: PredicateTileNode) {
        if let existingIndex = find(self.predicates, predicate) {
            predicate.predicateGroup = nil
            self.predicates.removeAtIndex(existingIndex)
        }
        
        if predicates.count <= 1 {
            for predicate in predicates {
                predicate.predicateGroup = nil
            }
            
            predicates.removeAll(keepCapacity: false)
            
            containerNode?.removeFromParent()
            removeFromParent()
        }
    }
    
    func removePredicates(predicates: [PredicateTileNode]) {
        for predicate in predicates {
            removePredicate(predicate)
        }
    }
    
    func generatePredicateForGroup() -> MongoPredicate {
        var groupedPredicates = [MongoKeyedPredicate]()
        
        for predicate in predicates {
            if let generatedPredicate = predicate.generatePredicateForTile() {
                groupedPredicates.append(generatedPredicate)
            }
        }
        
        return MongoPredicate.orPredicateWithArray(groupedPredicates)
    }
}
