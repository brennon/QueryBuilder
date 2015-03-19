//
//  ListChooser.swift
//  SpriteTests
//
//  Created by Brennon Bortz on 1/11/15.
//  Copyright (c) 2015 Brennon Bortz. All rights reserved.
//

import SpriteKit

protocol ListChooserDelegate {
    func choicesChanged(choices: [String], listChooser: ListChooser)
}

class ListChooser: SKNode {
    
    var values = [String]()
    
    var headerNode: SKSpriteNode!
    var choiceNodes = [SKSpriteNode]()
    var selectedValues = [String]()
    var title: String!
    var choiceContainerNode: SKCropNode!
    
    var choiceTileSize = CGSizeMake(150, 36)
    var headerChoiceGap: CGFloat = 5
    var interChoiceGap: CGFloat = 2
    var headerTileSize = CGSizeMake(150, 50)
    var visibleNumberOfChoices: CGFloat = 5.5
    
    var headerTileColor = PredicateTileChooserHeaderColor
    var headerFontColor = TileLabelFontColor
    var choiceDeselectedTileColor = PredicateTileChooserChoicePrimaryColor
    var choiceFontColor = TileLabelFontColor
    var choiceSelectedTileColor = PredicateTileChooserChoiceSecondaryColor
    
    var tileLabelFontName = TileLabelFontName
    
    var headerFontSize: CGFloat = 18
    var choiceFontSize: CGFloat = 18
    
    var delegate: ListChooserDelegate?
    
    let dictKeySelected = "selected"
    let dictKeyValue = "value"
    
    init(values: [String], andTitle title: String) {
        super.init()
        
        self.values = values
        self.title = title
        name = "list-chooser"
        
        userInteractionEnabled = true
        
        addHeaderNode()
        addChoiceContainerNode()
        addChoiceNodes()
        
        let panRecognizer = BBPanGestureRecognizer(target: self, action: ListChooser.moveChooser)
        addGestureRecognizer(panRecognizer)
    }
    
    func addHeaderNode() {
        headerNode = SKSpriteNode(color: headerTileColor, size: headerTileSize)
        
        let labelNode = SKLabelNode(text: title)
        labelNode.fontColor = headerFontColor
        labelNode.fontSize = headerFontSize
        labelNode.fontName = tileLabelFontName
        labelNode.position = CGPointMake(0, -labelNode.fontSize / 2)
        labelNode.userInteractionEnabled = false
        
        headerNode.addChild(labelNode)
        
        // Create, configure, and add RadialMenu as child node
        let trashMenuItem = RadialMenuItem(target: self, andAction: ListChooser.menuTrashSelected, withIconImageName: "TrashIcon")
        
        let menu = RadialMenu(menuItems: [trashMenuItem])
        menu.position = CGPointMake(headerNode.size.width / 2, headerNode.size.height / 2)
        addChild(menu)
        
        addChild(headerNode)
    }
    
//    ListChooser
//        Header
//        ChoiceContainer
//            Choices
    
    func menuTrashSelected(radialMenu: RadialMenu) {
        self.removeFromParent()
    }
    
    func addChoiceContainerNode() {
        choiceContainerNode = SKCropNode()
        let maskNodeHeight = (choiceTileSize.height + interChoiceGap) * visibleNumberOfChoices
        choiceContainerNode.maskNode = SKSpriteNode(color: SKColor.blackColor(), size: CGSizeMake(choiceTileSize.width, maskNodeHeight))
        choiceContainerNode.maskNode?.position = CGPointMake(0, -((maskNodeHeight / 2) + headerChoiceGap + (headerTileSize.height / 2)))
        addChild(choiceContainerNode)
    }
    
    func addChoiceNodes() {
        
        for (index, choice) in enumerate(values) {
            
            let choiceTile = SKSpriteNode(color: choiceDeselectedTileColor, size: choiceTileSize)
            let choiceLabel = SKLabelNode(text: choice)
            choiceLabel.fontSize = calculateFontSize(choice)
            choiceLabel.fontColor = choiceFontColor
            choiceLabel.fontName = tileLabelFontName
            choiceLabel.position = CGPointMake(0, -choiceLabel.fontSize / 2)
            choiceTile.addChild(choiceLabel)
            
            var tileY = -headerTileSize.height / 2
            tileY -= headerChoiceGap
            tileY -= CGFloat(index) * interChoiceGap
            tileY -= CGFloat(index) * (choiceTileSize.height)
            tileY -= choiceTileSize.height / 2
            
            choiceTile.position = CGPointMake(0, tileY)
            
            choiceLabel.userInteractionEnabled = false
            choiceTile.userInteractionEnabled = true
            
            choiceTile.userData = NSMutableDictionary(objects: [choice, false], forKeys: [dictKeyValue, dictKeySelected])
            
            let panRecognizer = BBPanGestureRecognizer(target: self, action: ListChooser.scrollChoices)
            choiceTile.addGestureRecognizer(panRecognizer)
            
            let tapRecognizer = BBTapGestureRecognizer(target: self, action: ListChooser.choiceTapped)
            choiceTile.addGestureRecognizer(tapRecognizer)
            
            // Add a physics body so that we can flick the choice list to scroll.
            choiceTile.physicsBody = SKPhysicsBody(rectangleOfSize: choiceTile.size)
            
            choiceContainerNode.addChild(choiceTile)
            choiceNodes.append(choiceTile)
        }
    }
    
    func layoutChoiceNodes() {

        // Check if the top tile is running the 'layout-action' action.
        if let topTile = choiceNodes.first {
        
            let layoutAction = topTile.actionForKey("layout-action")
            
            if layoutAction == nil {
                println("layoutChoiceNodes()")
                
                // If the top of the list has been moved down too far...
                if topTileIsTooLow() {
                    
                    // Stop all animation on tiles
                    for (index, node) in enumerate(choiceNodes) {
                        node.removeAllActions()
                        
                        node.physicsBody?.velocity = CGVectorMake(0, 0)
                        
                        var tileY = -headerTileSize.height / 2
                        tileY -= headerChoiceGap
                        tileY -= CGFloat(index) * interChoiceGap
                        tileY -= CGFloat(index) * (choiceTileSize.height)
                        tileY -= choiceTileSize.height / 2
                        
                        node.runAction(SKAction.moveTo(CGPointMake(0, tileY), duration: 0.2), withKey: "layout-action")
                    }
                
                // Or, if the bottom of the list has been moved up too high...
                } else if bottomTileIsTooHigh() {
                    
                    // Stop all animation on tiles
                    for (index, node) in enumerate(reverse(choiceNodes)) {
                        node.removeAllActions()
                        
                        node.physicsBody?.velocity = CGVectorMake(0, 0)
                        
                        var tileY = -headerTileSize.height / 2
                        tileY -= headerChoiceGap
                        tileY -= choiceContainerNode.maskNode!.frame.size.height
                        tileY += choiceTileSize.height / 2
                        
                        tileY += CGFloat(index) * interChoiceGap
                        tileY += CGFloat(index) * (choiceTileSize.height)
                        
                        node.runAction(SKAction.moveTo(CGPointMake(0, tileY), duration: 0.2), withKey: "layout-action")
                    }
                }
            }
        }
    }
    
    func selectChoice(choiceNode: SKSpriteNode) {
        choiceNode.userData!.setValue(true, forKey: dictKeySelected)
        selectedValues.append(choiceNode.userData!.valueForKey(dictKeyValue) as String)
        choiceNode.color = choiceSelectedTileColor
        
        if delegate != nil {
            delegate!.choicesChanged(selectedValues, listChooser: self)
        }
    }
    
    func deselectChoice(choiceNode: SKSpriteNode) {
        choiceNode.userData!.setValue(false, forKey: dictKeySelected)
        let value = choiceNode.userData!.valueForKey(dictKeyValue) as String
        if let index = find(selectedValues, value) {
            selectedValues.removeAtIndex(index)
        }
        choiceNode.color = choiceDeselectedTileColor
        
        if delegate != nil {
            delegate!.choicesChanged(selectedValues, listChooser: self)
        }
    }
    
    /**
        Handler for moving the entire choices list. Currently disabled.
        
        :param: panRecognizer The `BBGestureRecognizer` that recognized a pan gesture.
    */
    func moveChooser(panRecognizer: BBGestureRecognizer?) {
        
//        if let recognizer = panRecognizer as? BBPanGestureRecognizer {
//            
//            if recognizer.state == .Changed {
//                
//                let translation = recognizer.translationInNode(self.scene!)
//                recognizer.setTranslation(CGPointZero, inNode: self.scene!)
//                position = CGPointMake(position.x + translation.x, position.y + translation.y)
//            }
//        }
    }
    
    /**
        Handler for panning (scrolling) the choices list.
        
        :param: panRecognizer The `BBGestureRecognizer that recognized a pan gesture.
    */
    func scrollChoices(panRecognizer: BBGestureRecognizer?) {
        
        // Don't do anything if all choices can be displayed at once.
        if CGFloat(choiceNodes.count) <= self.visibleNumberOfChoices {
            return
        }
        
        if let recognizer = panRecognizer as? BBPanGestureRecognizer {
            
            // If we're currently panning and the node being panned is within
            // the container mask...
            if recognizer.state == .Changed {
                if let node = recognizer.node as? SKSpriteNode {
                    if nodeIntersectsContainerMask(node) {
                
                        let translation = recognizer.translationInNode(self.scene!)
                        let forceMultiplier: CGFloat = 2.0
                        let forceVector = CGVectorMake(0, translation.y * forceMultiplier)
                        
                        if choiceTilesAreInBounds(translation) {
                            recognizer.setTranslation(CGPointZero, inNode: self.scene!)
                            
                            for choiceNode in choiceNodes {
                                choiceNode.physicsBody?.velocity = CGVectorMake(0, 0)
                                choiceNode.position = CGPointMake(0, choiceNode.position.y + translation.y)
                            }
                        }
                    }
                }
            } else if recognizer.state == .Ended {
                if let node = recognizer.node as? SKSpriteNode {
                    if nodeIntersectsContainerMask(node) {
                        
                        let translation = recognizer.translationInNode(self.scene!)
                        let forceMultiplier: CGFloat = 2.0
                        let forceVector = CGVectorMake(0, translation.y * forceMultiplier)
                        
                        if choiceTilesAreInBounds(translation) {
                            recognizer.setTranslation(CGPointZero, inNode: self.scene!)
                            
                            for choiceNode in choiceNodes {
                                choiceNode.physicsBody?.velocity = CGVectorMake(0, 0)
                                choiceNode.physicsBody?.applyForce(forceVector)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func choiceTilesAreInBounds(translation: CGPoint) -> Bool {
        // We want to restrict the top of the top tile from moving below the top of the mask node,
        // and we want to restrict the bottom of the bottom tile from moving above the bottom of
        // the mask node.
        topTileIsTooLow()
        bottomTileIsTooHigh()
        return true
//        return (topTileIsTooLow() && bottomTileIsTooHigh())
    }
    
    func topTileIsTooLow() -> Bool {
        
        // We want to restrict the top of the top tile from moving below the top of the mask node.
        if let topTile = choiceNodes.first {
            if let maskNode = self.choiceContainerNode.maskNode {
                
                if let scene = self.scene {
                    
                    let maskNodeTop = maskNode.position.y + maskNode.frame.height / 2
                    let topTileTop = topTile.position.y + topTile.frame.height / 2
                    return (topTileTop - maskNodeTop < 0)
                }
            }
        }
        
        return false
    }
    
    func bottomTileIsTooHigh() -> Bool {
        
        // We want to restrict the top of the top tile from moving below the top of the mask node.
        if let bottomTile = choiceNodes.last {
            if let maskNode = self.choiceContainerNode.maskNode {
                
                if let scene = self.scene {
                    
                    let maskNodeBottom = maskNode.position.y - maskNode.frame.height / 2
                    let bottomTileBottom = bottomTile.position.y - bottomTile.frame.height / 2
                    return (maskNodeBottom - bottomTileBottom < 0)
                }
            }
        }
        
        return false
    }
    
    /**
        Handler for tapping choice tiles. Highlights the tile and marks it as selected in its
        `userData` dictionary.
        
        :param: tapRecognizer The `BBGestureRecognizer` that recognized a tap gesture.
    */
    func choiceTapped(tapRecognizer: BBGestureRecognizer?) {
        
        if let recognizer = tapRecognizer as? BBTapGestureRecognizer {
            
            // If the gesture recognizer completed recognition, and the tapped
            // node is within container mask...
            if recognizer.state == .Recognized {
                if let node = recognizer.node as? SKSpriteNode {
                    if nodeIntersectsContainerMask(node) {
                        
                        if let selected = node.userData?.valueForKey(dictKeySelected) as? Bool {
                            
                            // Flip the state of the node's 'selected' property using
                            // deselectChoice() or selectChoice()
                            if selected == true {
                                deselectChoice(node)
                            } else {
                                selectChoice(node)
                            }
                        }
                    }
                }
            }
        }
    }

    /**
        Checks if `node` is within the masked area of `choiceContainerNode` (an `SKCropNode`).
    
        :param: node The `SKSpriteNode that may or not be within the rect of the container node's
            `maskNode`.
    
        :returns: Returns `true` if `node` is within the mask of `choiceContainerNode` (i.e., is
            visible). Otherwise, it returns `false`.
    */
    func nodeIntersectsContainerMask(node: SKSpriteNode) -> Bool {
        if let maskNode = self.choiceContainerNode.maskNode {
            return node.intersectsNode(maskNode)
        }
        
        return false
    }
    
    func calculateFontSize(text: String) -> CGFloat {
        
        var scaledFontSize: CGFloat = 18
        let targetWidth = TileWidth - 10
        
        while true {
            
            // Add a hidden label to the tile
            let labelNode = SKLabelNode(text: text)
            labelNode.position = CGPointZero
            labelNode.fontName = "HelveticaNeue-CondensedBold"
            labelNode.fontSize = scaledFontSize
            labelNode.alpha = 0
            labelNode.verticalAlignmentMode = .Center
            addChild(labelNode)
            
            // Calculate the size of the label
            let width = labelNode.calculateAccumulatedFrame().size.width
            
            // If it is too wide
            if width > targetWidth {
                scaledFontSize -= 2
                labelNode.removeFromParent()
                
                // Otherwise, return the current size
            } else {
                
                labelNode.removeFromParent()
                return scaledFontSize
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        if topTileIsTooLow() || bottomTileIsTooHigh() {
            layoutChoiceNodes()
        }
    }
}
