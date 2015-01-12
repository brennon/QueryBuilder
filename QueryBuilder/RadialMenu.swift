//
//  RadialMenu.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 1/10/15.
//  Copyright (c) 2015 Brennon Bortz. All rights reserved.
//

import SpriteKit

/**
Types that conform to the `RadialMenuTargetAction` protocol can be assigned to the `targetAction` property of a `RadialMenuItem`.
*/
protocol RadialMenuTargetAction {
    func performAction(radialMenu: RadialMenu)
}

/**
A `BBGestureRecognizerTargetActionWrapper` wraps both a target instance of any class and a method to be called on that instance. `BBGestureRecognizerTargetActionWrapper` conforms to the `BBGestureRecognizerTargetAction` protocol, and an instance of a `BBGestureRecognizerTargetActionWrapper` is meant to be used as the `registeredAction` on a `BBGestureRecognizer`.
*/
struct RadialMenuTargetActionWrapper<T: AnyObject>: RadialMenuTargetAction {
    
    // MARK: Properties
    
    /// The target instance of some class.
    weak var target: T?
    
    /// The method to be called on `target`.
    let action: (T) -> (RadialMenu) -> ()
    
    // MARK: RadialMenu TargetAction Protocol
    
    func performAction(radialMenu: RadialMenu) -> () {
        if let t = target {
            action(t)(radialMenu)
        }
    }
}

class RadialMenuItem {
    var action: RadialMenuTargetAction!
    var iconImageName: String!
    
    init<T: AnyObject>(target: T, andAction action: (T) -> (RadialMenu) -> (), withIconImageName imageName: String) {
        self.action = RadialMenuTargetActionWrapper(target: target, action: action)
        self.iconImageName = imageName
    }
}

class RadialMenu: SKNode {
    
    // Nodes
    var knob: SKShapeNode!
    var ring: SKShapeNode!
    var sectorNodes = [SKShapeNode]()
    var iconNodes = [SKSpriteNode]()
    
    // Colors
    var normalIconColor = UIColor.whiteColor()
    var highlightedIconColor = UIColor.blueColor()
    var sectorDeselectedAlpha: CGFloat = 0.7
    var sectorSelectedAlpha: CGFloat = 0.9
    var handleColor = UIColor.lightGrayColor()
    
    // Sizes and Distances
    var ringRadius: CGFloat = 100
    var knobRadius: CGFloat = 10
    var iconDistanceFromEdge: CGFloat = 20
    var iconWidth: CGFloat = 25
    var iconHeight: CGFloat = 25
    
    // Angles
    var angleOfFirstIcon: CGFloat = π / 2
    
    // Menu Items
    var menuItems: [RadialMenuItem]!
    
    // Circle Sectors
    var circleSectors = [CircleSector]()
    var numberOfSectors: Int!
    var sectorAngle: CGFloat {
        get {
            return (2 * π) / CGFloat(numberOfSectors)
        }
    }
    
    // State
    var expanded = false
    
    // dispatch_once Token
    var onceToken: dispatch_once_t = 0
    
    init(menuItems: [RadialMenuItem]) {
        super.init()
        
        userInteractionEnabled = true
        
        addHandle()
        numberOfSectors = menuItems.count
        self.menuItems = menuItems
        
        for (index, menuItem) in enumerate(menuItems) {
            let sector = circleSector(atIndex: index)
            circleSectors.append(sector)
            let sectorNode = circleSectorNode(atIndex: index)
            sectorNodes.append(sectorNode)
            let icon = iconNode(forMenuItem: menuItem)
            iconNodes.append(icon)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addHandle() {
        knob = SKShapeNode(circleOfRadius: knobRadius)
        knob.fillColor = handleColor
        knob.zPosition = SceneLayer.MenuKnob.rawValue
        addChild(knob)
    }
    
    func circleSectorNode(atIndex index: Int) -> SKShapeNode {
        var path = CGPathCreateMutable()
        
        let circleSector = circleSectors[index]
        
        CGPathMoveToPoint(path, nil, 0, 0)
        CGPathAddLineToPoint(path, nil, circleSector.startVector.dx, circleSector.startVector.dy)
        CGPathAddArc(path, nil, 0, 0, circleSector.radius, circleSector.startTheta, circleSector.endTheta, false)
        CGPathCloseSubpath(path)
        
        var sectorNode = SKShapeNode()
        sectorNode.path = path
        sectorNode.strokeColor = UIColor.whiteColor()
        sectorNode.fillColor = UIColor.darkGrayColor()
        return sectorNode
    }
    
    func iconNode(forMenuItem menuItem: RadialMenuItem) -> SKSpriteNode {
        let texture = SKTexture(imageNamed: menuItem.iconImageName)
        let node = SKSpriteNode(texture: texture, color: normalIconColor, size: CGSizeMake(25, 25))
        node.colorBlendFactor = 1
        return node
    }
    
    // In radians
    func angleForIcon(atIndex index: Int) -> CGFloat {
        let offsetInRadians: CGFloat = CGFloat(index) * sectorAngle
        let startAngleInRadians = angleOfFirstIcon
        return offsetInRadians + startAngleInRadians
    }
    
    func circleSector(atIndex index: Int) -> CircleSector {
        let iconAngle = angleForIcon(atIndex: index)
        let halfSectorAngle = sectorAngle / 2
        let v1Angle = iconAngle + halfSectorAngle
        let v2Angle = iconAngle - halfSectorAngle
        return CircleSector(startTheta: v2Angle, endTheta: v1Angle, radius: ringRadius)
    }
    
    func vectorsForSector(atIndex index: Int) -> (v1: CGVector, v2: CGVector) {
        let iconAngle = angleForIcon(atIndex: index)
        let halfSectorAngle = sectorAngle / 2
        
        let v1Angle = iconAngle + halfSectorAngle
        let z = ringRadius
        let v1dx = cos(v1Angle) * z
        let v1dy = sin(v1Angle) * z
        let v1 = CGVectorMake(v1dx, v1dy)
        
        let v2Angle = iconAngle - halfSectorAngle
        let v2dx = cos(v2Angle) * z
        let v2dy = sin(v2Angle) * z
        let v2 = CGVectorMake(v2dx, v2dy)
        
        return (v1: v1, v2: v2)
    }
    
    func positionForIcon(atIndex index: Int) -> CGPoint {
        var z = ringRadius - (iconWidth / 2) - iconDistanceFromEdge
        var y = sin(angleForIcon(atIndex: index)) * z
        var x = cos(angleForIcon(atIndex: index)) * z
        return CGPointMake(x, y)
    }
    
    func expandMenu() {
        
        if !expanded {
            expanded = true
            
            for sectorNode in sectorNodes {
                sectorNode.alpha = 0
                let zeroScale = SKAction.scaleTo(0.01, duration: 0)
                
                let fadeIn = SKAction.fadeAlphaTo(sectorDeselectedAlpha, duration: 0.15)
                let fullScale = SKAction.scaleTo(1, duration: 0.15)
                let enterGroup = SKAction.group([fadeIn, fullScale])
                enterGroup.timingMode = SKActionTimingMode.EaseInEaseOut
                
                let sequence = SKAction.sequence([zeroScale, enterGroup])
                addChild(sectorNode)
                sectorNode.removeAllActions()
                sectorNode.runAction(sequence)
            }
            
            for (index, iconNode) in enumerate(iconNodes) {
                iconNode.alpha = 1
                iconNode.alpha = 0
                iconNode.position = CGPointZero
                let zeroScale = SKAction.scaleTo(0, duration: 0)
                
                let fadeIn = SKAction.fadeInWithDuration(0.15)
                let fullScale = SKAction.scaleTo(1, duration: 0.15)
                let finalPosition = positionForIcon(atIndex: index)
                let moveOut = SKAction.moveTo(finalPosition, duration: 0.15)
                let enterGroup = SKAction.group([fadeIn, fullScale, moveOut])
                enterGroup.timingMode = SKActionTimingMode.EaseInEaseOut
                
                let sequence = SKAction.sequence([zeroScale, enterGroup])
                iconNode.removeAllActions()
                addChild(iconNode)
                iconNode.runAction(sequence)
            }
        }
    }
    
    func contractMenu() {
        
        if expanded {
            
            for sectorNode in sectorNodes {
                let zeroScale = SKAction.scaleTo(0.01, duration: 0.15)
                let fadeOut = SKAction.fadeOutWithDuration(0.15)
                let exitGroup = SKAction.group([zeroScale, fadeOut])
                exitGroup.timingMode = SKActionTimingMode.EaseInEaseOut
                
                let remove = SKAction.removeFromParent()
                
                let sequence = SKAction.sequence([exitGroup, remove])
                sectorNode.removeAllActions()
                sectorNode.runAction(sequence)
            }
            
            for iconNode in iconNodes {
                let zeroScale = SKAction.scaleTo(0, duration: 0.15)
                let fadeOut = SKAction.fadeOutWithDuration(0.15)
                let moveIn = SKAction.moveTo(CGPointZero, duration: 0.15)
                let exitGroup = SKAction.group([zeroScale, fadeOut, moveIn])
                exitGroup.timingMode = SKActionTimingMode.EaseInEaseOut
                
                let remove = SKAction.removeFromParent()
                
                let sequence = SKAction.sequence([exitGroup, remove])
                iconNode.removeAllActions()
                iconNode.runAction(sequence) {
                    iconNode.color = self.normalIconColor
                }
            }
            
            self.runAction(SKAction.waitForDuration(0.15)) {
                self.expanded = false
                self.onceToken = 0
            }
        }
    }
    
    func highlightSector(atIndex index: Int) {
        let iconNode = iconNodes[index]
        iconNode.color = highlightedIconColor
        
        let sectorNode = sectorNodes[index]
        sectorNode.runAction(SKAction.fadeAlphaTo(sectorSelectedAlpha, duration: 0.2))
    }
    
    func unhighlightSector(atIndex index: Int) {
        let iconNode = iconNodes[index]
        iconNode.color = normalIconColor
        
        let sectorNode = sectorNodes[index]
        sectorNode.runAction(SKAction.fadeAlphaTo(sectorDeselectedAlpha, duration: 0.2))
    }
    
    func callNodeHandler(forNodeAtIndex index: Int) {
        dispatch_once(&onceToken) {
            let menuItem = self.menuItems[index]
            menuItem.action.performAction(self)
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        expandMenu()
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        let firstTouch = touches.allObjects.first as UITouch
        let touchLocation = firstTouch.locationInNode(self)
        let pointDistance = pointDistanceFromCenter(touchLocation)
        
        if expanded {
            if pointDistance > knobRadius && pointDistance <= ringRadius {
                for (index, circleSector) in enumerate(circleSectors) {
                    if circleSector.pointIsInSector(touchLocation) {
                        highlightSector(atIndex: index)
                    } else {
                        unhighlightSector(atIndex: index)
                    }
                }
            } else if pointDistance <= knobRadius {
                for (index, sectorNode) in enumerate(sectorNodes) {
                    unhighlightSector(atIndex: index)
                }
            } else if pointDistance > ringRadius {
                for (index, circleSector) in enumerate(circleSectors) {
                    if circleSector.pointIsInSector(touchLocation) {
                        callNodeHandler(forNodeAtIndex: index)
                        break
                    }
                }
                
                contractMenu()
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        let firstTouch = touches.allObjects.first as UITouch
        let touchLocation = firstTouch.locationInNode(self)
        let pointDistance = pointDistanceFromCenter(touchLocation)
        
        if expanded {
            if pointDistance > knobRadius && pointDistance <= ringRadius {
                for (index, circleSector) in enumerate(circleSectors) {
                    if circleSector.pointIsInSector(touchLocation) {
                        callNodeHandler(forNodeAtIndex: index)
                        break
                    }
                }
            }
            
            contractMenu()
        }
    }
    
    func pointDistanceFromCenter(point: CGPoint) -> CGFloat {
        return sqrt(point.x * point.x + point.y * point.y)
    }
}

extension UIColor {
    class func randomColor() -> UIColor {
        return UIColor(red: CGFloat.random(0, upper: 1), green: CGFloat.random(0, upper: 1), blue: CGFloat.random(0, upper: 1), alpha: 1)
    }
}

extension CGVector: Printable {
    public var description: String {
        return "CGVector; dx: \(dx), dy: \(dy)"
    }
    
    func isClockwise(fromOtherVector otherVector: CGVector) -> Bool {
        let thisVectorNormalCounterclockwise = CGVectorMake(-self.dy, self.dx)
        let projectionOfOtherOntoNormal =
        (thisVectorNormalCounterclockwise.dx * otherVector.dx) +
            (thisVectorNormalCounterclockwise.dy * otherVector.dy)
        return projectionOfOtherOntoNormal > 0
    }
}

struct CircleSector {
    var startTheta, endTheta: CGFloat!
    var theta: CGFloat {
        get {
            return endTheta - startTheta
        }
    }
    var startVector, endVector: CGVector!
    var radius: CGFloat!
    
    init(startTheta: CGFloat, endTheta: CGFloat, radius: CGFloat) {
        self.radius = radius
        self.startTheta = startTheta
        self.endTheta = endTheta
        
        let v1dx = cos(startTheta) * radius
        let v1dy = sin(startTheta) * radius
        self.startVector = CGVectorMake(v1dx, v1dy)
        
        let v2dx = cos(endTheta) * radius
        let v2dy = sin(endTheta) * radius
        self.endVector = CGVectorMake(v2dx, v2dy)
    }
    
    func pointIsInSector(point: CGPoint) -> Bool {
        let vectorToPoint = CGVectorMake(point.x, point.y)
        let inSector = vectorToPoint.isClockwise(fromOtherVector: endVector) && !vectorToPoint.isClockwise(fromOtherVector: startVector)
        return inSector || ((endTheta - startTheta) % π) < 0.01
    }
}
