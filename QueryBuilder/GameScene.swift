//
//  GameScene.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 11/17/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import SpriteKit

// MARK: GameScene

let BoxWidth : CGFloat = 200
let BoxHeight : CGFloat = 50
let BoxCornerRadius : CGFloat = 10
let BoxBorderWidth : CGFloat = 2

class GameScene: SKScene, UIGestureRecognizerDelegate {
    
    var rectangleA: SKShapeNode!
    var rectangleB: SKShapeNode!
    
    var panRecognizer: MultiplePanGestureRecognizer!
    var currentlyPanningTouches: Array<UITouch> = []
    var touchNodeMap = TouchNodeMap()
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        rectangleA = SKShapeNode(rectOfSize: CGSizeMake(BoxWidth, BoxHeight), cornerRadius: BoxCornerRadius)
        rectangleA.position = CGPoint(x: CGRectGetMidX(frame) / 2, y:CGRectGetMidY(frame))
        rectangleA.fillColor = SKColor.yellowColor()
        rectangleA.strokeColor = SKColor.blackColor()
        rectangleA.lineWidth = BoxBorderWidth
        addChild(rectangleA)
        
        rectangleB = SKShapeNode(rectOfSize: CGSizeMake(BoxWidth, BoxHeight), cornerRadius: BoxCornerRadius)
        rectangleB.position = CGPoint(x: (CGRectGetMidX(frame) / 2) * 3, y:CGRectGetMidY(frame))
        rectangleB.fillColor = SKColor.yellowColor()
        rectangleB.strokeColor = SKColor.blackColor()
        rectangleB.lineWidth = BoxBorderWidth
        addChild(rectangleB)
        
        // Add pan gesture recognizer to the view
        panRecognizer = MultiplePanGestureRecognizer(target: self, action: "handleMultiplePan:")
        panRecognizer.delegate = self
        view.addGestureRecognizer(panRecognizer)
        
//        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
//        myLabel.text = "Hello, World!";
//        myLabel.fontSize = 65;
        
//        self.addChild(myLabel)
    }
    
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
            
            // Iterate over currentlyPanningTouches and move nodes accordingly
            for (touch, node) in touchNodeMap {
                
                let location = touch.locationInNode(self)
                let previousLocation = touch.previousLocationInNode(self)
                let deltaX = location.x - previousLocation.x
                let deltaY = location.y - previousLocation.y
                node.position = CGPointMake(node.position.x + deltaX, node.position.y + deltaY)
            }
            
            // Get node for most recent touch
            let (_, mostRecentNode) = touchNodeMap.mostRecentTouchAndNode()
            
            // Remove and re-add it to the scene
            if mostRecentNode != nil {
                mostRecentNode!.removeFromParent()
                addChild(mostRecentNode!)
            }
            
        default:
            break
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
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        super.update(currentTime)
    }
}
