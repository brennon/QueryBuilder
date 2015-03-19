//
//  RelativeDialNode.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 1/14/15.
//  Copyright (c) 2015 Brennon Bortz. All rights reserved.
//

import SpriteKit

enum RelativeDialNodeType {
    case Integral
    case FloatingPoint
}

protocol RelativeDialNodeDelegate: class {
    func dialValueChanged(dial: RelativeDialNode)
}

class RelativeDialNode: SKNode {
    
    var innerThumbNode: SKShapeNode!
    
    var innerThumbRadius: CGFloat = 65 {
        didSet {
            addInnerThumbNode(innerThumbRadius)
        }
    }
    
    var innerThumbStrokeColor: SKColor = SKColor.whiteColor() {
        didSet {
            addInnerThumbNode(innerThumbRadius)
        }
    }
    
    var innerThumbFillColor: SKColor = SKColor.darkGrayColor() {
        didSet {
            addInnerThumbNode(innerThumbRadius)
        }
    }
    
    var outerThumbStrokeColor = SKColor.darkGrayColor()
    var outerThumbFillColor = SKColor.blackColor()
    var outerRingStrokeColor = SKColor.blackColor()
    
    var labelFontColor: SKColor = SKColor.lightTextColor() {
        didSet {
            addValueLabelNode()
        }
    }
    
    var labelFontName: String = "HelveticaNeue-CondensedBold" {
        didSet {
            addValueLabelNode()
        }
    }
    
    var labelFontSize: CGFloat = 16 {
        didSet {
            addValueLabelNode()
        }
    }
    
    var valueLabelNode: SKLabelNode!
    
    var maximumValue: Double! {
        didSet {
            currentValue = _currentValue
        }
    }
    
    var minimumValue: Double! {
        didSet {
            currentValue = _currentValue
        }
    }
    
    var dialType: RelativeDialNodeType = .Integral
    
    var lastLocation: CGPoint? = nil
    var rayNode: SKShapeNode?
    var perimeterNode: SKShapeNode?
    var outerThumbNode: SKShapeNode?
    
    var _currentValue: Double!
    var currentValue: Double {
        set {
            if newValue > maximumValue {
                _currentValue = maximumValue
            } else if newValue < minimumValue {
                _currentValue = minimumValue
            } else {
                _currentValue = newValue
                
                if let actualDelegate = delegate {
                    actualDelegate.dialValueChanged(self)
                }
            }
            
            if let label = valueLabelNode {
                switch dialType {
                case .Integral:
                    label.text = String(format: "%.0f", _currentValue)
                case .FloatingPoint:
                    label.text = String(format: "%.3f", _currentValue)
                }
            }
        }
        get {
            switch dialType {
            case .Integral:
                return Double(Int(_currentValue))
            case .FloatingPoint:
                return _currentValue
            }
        }
    }
    
    weak var delegate: RelativeDialNodeDelegate?
    
    init(min: Double, max: Double, type: RelativeDialNodeType) {
        
        // Are we using integral or floating-point numbers?
        dialType = type
        
        // Set current value to midpoint of min and max.
        maximumValue = max
        minimumValue = min
        
        super.init()
        
        // Set currentValue to midpoint of range.
        currentValue = ((max - min) / 2) + min
        
        // Create and add background node.
        addInnerThumbNode(innerThumbRadius)
        
        // Add value label node to dial node.
        addValueLabelNode()
    }
    
    func addInnerThumbNode(radius: CGFloat) {
    
        if innerThumbNode?.parent != nil {
            innerThumbNode.removeFromParent()
        }
        
        innerThumbNode = SKShapeNode(circleOfRadius: radius)
        innerThumbNode.fillColor = innerThumbFillColor
        innerThumbNode.strokeColor = innerThumbStrokeColor
        innerThumbNode.userInteractionEnabled = true
        
        // Add a pan gesture recognizer.
        let panRecognizer = BBPanGestureRecognizer(target: self, action: RelativeDialNode.handlePan)
        innerThumbNode.addGestureRecognizer(panRecognizer)
        
        addChild(innerThumbNode)
    }
    
    func addValueLabelNode() {
        
        if valueLabelNode?.parent != nil {
            valueLabelNode.removeFromParent()
        }
        
        // Create valueLabelNode with currentValue as text.
        valueLabelNode = SKLabelNode(text: String(format: "%.0f", currentValue))
        valueLabelNode.fontSize = labelFontSize
        valueLabelNode.fontName = labelFontName
        valueLabelNode.fontColor = labelFontColor
        valueLabelNode.userInteractionEnabled = false
        valueLabelNode.position = CGPointMake(0, -labelFontSize / 2)
        
        addChild(valueLabelNode)
    }
    
    func handlePan(recognizer: BBGestureRecognizer?) {
        if let panRecognizer = recognizer as? BBPanGestureRecognizer {
            switch panRecognizer.state {
            case .Began:
                beginRotating(panRecognizer)
            case .Changed:
                continueRotating(panRecognizer)
            case .Ended, .Cancelled:
                endRotating(panRecognizer)
            default:
                break
            }
        }
    }
    
    func beginRotating(recognizer: BBPanGestureRecognizer) {
        lastLocation = recognizer.locationInNode(self)
    }
    
    func continueRotating(recognizer: BBPanGestureRecognizer) {
        let p1 = CGPointZero
        
        if let p2 = lastLocation {
            if let p3 = recognizer.locationInNode(self) {
                
                let previousVector = CGVectorMake(p2.x, p2.y)
                let currentVector = CGVectorMake(p3.x, p3.y)
                let theta = CGVector.angle(fromVector: previousVector, toVector: currentVector)
                
                let portionOfCircle = theta / (2 * π)
                let range = maximumValue - minimumValue
                var portionOfRange = portionOfCircle * CGFloat(range)
                
                var newValue = Double(CGFloat(_currentValue) - portionOfRange)
                currentValue = newValue
                lastLocation = p3
                
                drawPerimeterNode(p3)
                drawOuterThumbNode(p3)
            }
        }
    }
    
    func drawPerimeterNode(touchLocation: CGPoint) {
        if perimeterNode?.parent != nil {
            perimeterNode?.removeFromParent()
        }
        
        let radius = CGPoint.distance(fromPoint: CGPointZero, toPoint: touchLocation)
        perimeterNode = SKShapeNode(circleOfRadius: radius)
        perimeterNode!.strokeColor = outerRingStrokeColor
        addChild(perimeterNode!)
    }
    
    func drawOuterThumbNode(touchLocation: CGPoint) {
        if outerThumbNode?.parent != nil {
            outerThumbNode?.removeFromParent()
        }
        
        outerThumbNode = SKShapeNode(circleOfRadius: 20)
        outerThumbNode?.strokeColor = outerThumbStrokeColor
        outerThumbNode?.fillColor = outerThumbFillColor
        outerThumbNode?.position = touchLocation
        addChild(outerThumbNode!)
    }
    
    func endRotating(recognizer: BBPanGestureRecognizer) {
        lastLocation = nil
        
        if let actualPerimeterNode = perimeterNode {
            let shrink = SKAction.scaleTo(0, duration: 0.4)
            let fadeOut = SKAction.fadeOutWithDuration(0.4)
            let shrinkFadeGroup = SKAction.group([shrink, fadeOut])
            let remove = SKAction.removeFromParent()
            actualPerimeterNode.runAction(SKAction.sequence([shrinkFadeGroup, remove])) {
                self.perimeterNode = nil
            }
        }
        
        if let actualThumbNode = outerThumbNode {
            let shrink = SKAction.scaleTo(0, duration: 0.4)
            let moveToZero = SKAction.moveTo(CGPointZero, duration: 0.4)
            let fadeOut = SKAction.fadeOutWithDuration(0.4)
            let shrinkFadeGroup = SKAction.group([shrink, moveToZero, fadeOut])
            let remove = SKAction.removeFromParent()
            actualThumbNode.runAction(SKAction.sequence([shrinkFadeGroup, remove])) {
                self.outerThumbNode = nil
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
