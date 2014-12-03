//
//  GameScene.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 11/17/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: Constants
    
    let BoxWidth : CGFloat = 200
    let BoxHeight : CGFloat = 50
    let BoxCornerRadius : CGFloat = 10
    let BoxBorderWidth : CGFloat = 2
    
    // MARK: Instance Variables
    
    var panRecognizer: MultiplePanGestureRecognizer!
    var touchNodeMap = TouchNodeMap()
    
    // MARK: Initializers
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        addTestPredicateNodes()
        
        // Add pan gesture recognizer to the view
        panRecognizer = MultiplePanGestureRecognizer(
            target: self,
            action: "handleMultiplePan:"
        )
        view.addGestureRecognizer(panRecognizer)
        
        // Setup physics
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        // Enabled debugging display
        debuggingDisplay(true)
    }
    
    // MARK: SKPhysicsContactDelegate
    
    func didBeginContact(contact: SKPhysicsContact!) {
        println("didBeginContact:")
    }
    
    func didEndContact(contact: SKPhysicsContact!) {
        println("didEndContact:")
    }
    
    // MARK: Testing/Debugging
    
    /**
        Enables/disables the display of all stock debugging information.

        :param: enabled If `true`, diplay of debugging information is enabled. 
            If `false`, it is hidden.
    */
    func debuggingDisplay(enabled: Bool) {
        
        view?.showsDrawCount = enabled
        view?.showsFields = enabled
        view?.showsFPS = enabled
        view?.showsNodeCount = enabled
        view?.showsPhysics = enabled
        view?.showsQuadCount = enabled
    }
    
    /**
        Adds several test `PredicateTileNode`s to the scene.
    */
    func addTestPredicateNodes() {
        var rectangleA = PredicateTileNode()
        rectangleA.position = CGPoint(
            x: CGRectGetMidX(frame) / 2,
            y: CGRectGetMidY(frame)
        )
        addChild(rectangleA)
        
        var rectangleB = PredicateTileNode()
        rectangleB.position = CGPoint(
            x: (CGRectGetMidX(frame) / 2) * 3,
            y:CGRectGetMidY(frame)
        )
        addChild(rectangleB)
        
        var rectangleC = PredicateTileNode()
        rectangleC.position = CGPoint(
            x: CGRectGetMidX(frame),
            y: CGRectGetMidY(frame) + (CGRectGetHeight(frame) / 4)
        )
        addChild(rectangleC)
    }
    
    // MARK: Pan Gesture Handling
    
    /**
        Track multiple pan gestures in the scene.
    
        There is no way to add a `UIGestureRecognizer` to individual `SKNode`s, 
        so the only way to use a `UIGestureRecognizer` in an `SKScene` is to add 
        one to the `view` of the `SKScene`. Because of this, tracking multiple
        pan gestures at once, thereby allowing the user to move multiple nodes
        simultaneously, is difficult. `handleMultiplePan:`, in conjunction with 
        a `TouchNodeMap` and `MultiplePanGestureRecognizer` allows this 
        functionality.
    
        :param: recognizer The `MultiplePanGestureRecognizer` for this 
            `SKScene`'s `view`.
    */
    func handleMultiplePan(recognizer: MultiplePanGestureRecognizer) {
        
        switch recognizer.state {
        case .Began, .Changed:
            
            // Remove those touches from tracking that are no longer being
            // recognized
            touchNodeMap.prune(recognizer.currentTouches)
            
            // Iterate over the recognizer's currentTouches
            for touch in recognizer.currentTouches {
                
                // Is it over a child node of the scene?
                if let node = getChildNodeForTouch(touch) {
                    
                    // If so, add it to the touchNodeMap
                    touchNodeMap.add(touch, withNode: node)
                }
            }
            
            // Move all predicate tile nodes to Tile layer
            moveNodesWithName(PredicateTileNodeName, toLayer: .PredicateTiles)
            
            // Get node for most recent touch
            let (_, mostRecentNode) = touchNodeMap.mostRecentTouchAndNode()
            
            // Move it to the Foreground layer
            if mostRecentNode != nil {
                mostRecentNode!.zPosition = SceneLayer.Foreground.rawValue
            }
            
            // Iterate over currentlyPanningTouches and move nodes accordingly
            for (touch, node) in touchNodeMap {
                
                let location = touch.locationInNode(self)
                let previousLocation = touch.previousLocationInNode(self)
                let deltaX = location.x - previousLocation.x
                let deltaY = location.y - previousLocation.y
                node.position = CGPointMake(
                    node.position.x + deltaX,
                    node.position.y + deltaY
                )
            }
            
        default:
            break
        }
    }
    
    // MARK: Node Manipulation
    
    /**
        Moves all nodes with a given name to a new layer (z-position).
    
        :param: name The name of the nodes to move.
        :param: toLayer The `SceneLayer` to which to move the nodes.
    */
    func moveNodesWithName(name: String, toLayer layer: SceneLayer) {
        
        enumerateChildNodesWithName(name) {
            (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                node.zPosition = layer.rawValue
        }
    }
    
    /**
        Get a child `SKNode` in the scene that is under a touch.

        This method will return only a child node in the scene, not the scene
        node itself.

        :param: touch The `UITouch` for which this method should hit test.

        :returns: If a child node was found under the touch, the method returns
            that node object. Otherwise, it returns `nil`.
    */
    func getChildNodeForTouch(touch: UITouch) -> SKNode? {
        
        let node = nodeAtPoint(touch.locationInNode(self))
        
        return node == self ? nil : node
    }
   
    // MARK: Update
    
    override func update(currentTime: CFTimeInterval) {
        
        /* Called before each frame is rendered */
        
        super.update(currentTime)
    }
}
