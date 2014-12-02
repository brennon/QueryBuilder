//
//  GameScene.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 11/17/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import SpriteKit

let BoxWidth : CGFloat = 200
let BoxHeight : CGFloat = 50
let BoxCornerRadius : CGFloat = 10
let BoxBorderWidth : CGFloat = 2

class GameScene: SKScene, UIGestureRecognizerDelegate {
    
    var rectangleA: SKShapeNode!
    var rectangleB: SKShapeNode!
    
    var panRecognizer: MultiplePanGestureRecognizer!
    
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
    
    func handleMultiplePan(recognizer: MultiplePanGestureRecognizer) {
        
//        println("numberOfTouches: \(recognizer.numberOfTouches())")
//
//        for i in recognizer.
//        
        switch recognizer.state {
        case .Began:
            println(".Began")
            
        case .Changed:
//            println(".Changed")
            // Iterate over recognizer's currentTouches
            for (i, _) in enumerate(recognizer.currentTouches) {
                
                let touch = recognizer.currentTouches[i] as UITouch
//                println("touch: \(touch)")
            }
            
//        case .Ended:
//            println(".Ended")
        default:
            break
        }
        
//        if recognizer.state == .Began {
//
//        } else if recognizer.state == .Changed {
//            let touchLocation = recognizer.locationInView(view)
//            println("\(touchLocation)")
//        } else if recognizer.state == .Ended {
//            
//        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
