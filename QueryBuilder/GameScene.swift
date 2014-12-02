//
//  GameScene.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 11/17/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import SpriteKit

// MARK: TouchNodeMap

/**
    `TouchNodeMap` is a class that associates touches with nodes. This is useful,
    for instance, when tracking multiple touches and maintaining a relationship
    between each touch and a particular node.
*/
class TouchNodeMap: Printable, SequenceType {
    
    /// Dictionary to hold mappings
    private var touchNodeMap = Dictionary<UITouch, Dictionary<String, AnyObject>>()
    private let touchKey = "touch"
    private let nodeKey = "node"
    
    var description: String {
        return "TouchNodeMap: \(touchNodeMap)"
    }
    
    /**
        Add a `UITouch`/`SKNode` pair to the map
    
        :param: touch The `UITouch` to add to the map
        :param: withNode The `SKNode` to associate with the `UITouch` in `touch`
    */
    func add(touch: UITouch, withNode node: SKNode) {
        
        // Check for touch in map
        let index = touchNodeMap.indexForKey(touch)
        
        if index == nil {
            var subdictionary = Dictionary<String, AnyObject>()
            subdictionary[touchKey] = touch
            subdictionary[nodeKey] = node
            touchNodeMap[touch] = subdictionary
        }
    }
    
    /**
        Remove a `UITouch` and its associated node from the map
    
        :param: touch The `UITouch` to be removed from the map
    */
    func remove(touch: UITouch) {
        
        // Check for touch in map
        let index = touchNodeMap.indexForKey(touch)
        
        if index != nil {
            touchNodeMap.removeAtIndex(index!)
        }
    }

    /**
        Retrieve the `SKNode` associated with a particular touch in the map

        :param: touch The `UITouch` for which an `SKNode` should be returned

        :returns: An `SKNode?`. `nil` is returned when no matching `UITouch` was
            found in the map.
    */
    func nodeForTouch(touch: UITouch) -> SKNode? {
        
        // Check for touch in map
        let index = touchNodeMap.indexForKey(touch)
        
        if index != nil {
            
            let mapEntry = touchNodeMap[touch]!
            let nodeEntry: AnyObject? = mapEntry[nodeKey]
            
            // If we found a node
            return nodeEntry! as? SKNode
        }
        
        return nil
    }
    
    /**
        Determine if a touch is already stored in the map
    
        :param: touch The `UITouch` for which to check the map
    
        :returns: Returns `true` if the `UITouch` was found in the map, `false`
            otherwise.
    */
    func touchExistsInMap(touch: UITouch) -> Bool {
        
        if (touchNodeMap.indexForKey(touch) != nil) {
            return true
        } else {
            return false
        }
    }
    
    /**
        Remove all entries from the map
    */
    func empty() {
        touchNodeMap = Dictionary<UITouch, Dictionary<String, AnyObject>>()
    }
    
    func generate() -> GeneratorOf<UITouch> {
        var index = 0
        
        return GeneratorOf<UITouch> {
            if index < self.touchNodeMap.keys.array.count {
                let key = self.touchNodeMap.keys.array[index++]
                let subdictionary = self.touchNodeMap[key]!
                let touchValue: UITouch = subdictionary[self.touchKey]
//                let nodeValue = subdictionary[self.nodeKey]
//                return (touchValue, nodeValue)
//                let key = self.touchNodeMap.keys.array[index]
//                index++
//                let entry = self.touchNodeMap[key][touchKey]
//                let node = entry[nodeKey]
//                return (touch, node)
            } else {
                return nil
            }
        }
    }
}

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
    
    func handleMultiplePan(recognizer: MultiplePanGestureRecognizer) {
        
//        println("numberOfTouches: \(recognizer.numberOfTouches())")
//
//        for i in recognizer.
//        
        switch recognizer.state {
        case .Began, .Changed:
            
            // Empty currentlyPanningTouches
            currentlyPanningTouches = []
            
            // Iterate over the recognizer's currentTouches
            for touch in recognizer.currentTouches {
                
                // Is it over a child node of the scene?
                if let node = getChildNodeForTouch(touch) {
                    
                    // If so, add it to the touchNodeMap
                    
//                    if find(currentlyPanningTouches, touch) == nil {
//                        currentlyPanningTouches.append(touch)
//                    }
                    
                    touchNodeMap.add(touch, withNode: node)
                }
            }
            
            // Iterate over currentlyPanningTouches and move nodes accordingly
            for touch in touchNodeMap {
                
                println("touch: \(touch)")
                
//                let hash = touch.hash
//                let hashValue = touch.hashValue
//                
//                let node = getChildNodeForTouch(touch)!
//                
//                let location = touch.locationInNode(self)
//                let previousLocation = touch.previousLocationInNode(self)
//                let deltaX = location.x - previousLocation.x
//                let deltaY = location.y - previousLocation.y
//                node.position = CGPointMake(node.position.x + deltaX, node.position.y + deltaY)
//                println("delta: \(CGPointMake(deltaX, deltaY))")
            }
            
        default:
            touchNodeMap.empty()
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
    
    func getChildNodeForTouch(touch: UITouch) -> SKNode? {
        let node = nodeAtPoint(touch.locationInNode(self))
        
        return node == self ? nil : node
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        super.update(currentTime)
    }
}
