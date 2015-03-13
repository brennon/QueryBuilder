//
//  DialChooser.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 1/19/15.
//  Copyright (c) 2015 Brennon Bortz. All rights reserved.
//

import SpriteKit

protocol DialChooserDelegate {
    func valueChanged(value: Double, valueChooser: DialChooser)
}

class DialChooser: SKNode, RelativeDialNodeDelegate {
    
    var headerNode: SKSpriteNode!
    var title: String!
    var dialContainerNode: SKSpriteNode!
    var headerChoiceGap: CGFloat = 5
    var headerTileSize = CGSizeMake(150, 50)
    var headerTileColor = PredicateTileChooserHeaderColor
    var headerFontColor = TileLabelFontColor
    var dialContainerColor = PredicateTileChooserChoicePrimaryColor
    var tileLabelFontName = TileLabelFontName
    var headerFontSize: CGFloat = 18
    var delegate: DialChooserDelegate?
    
    init(max: Double, min: Double, dialType: RelativeDialNodeType, andTitle title: String) {
        super.init()
        
        self.title = title
        
        userInteractionEnabled = true
        
        addHeaderNode()
        addDialContainerNode()
        addDialNode(max, min: min, dialType: dialType)
    }
    
    func addHeaderNode() {
        headerNode = SKSpriteNode(color: headerTileColor, size: headerTileSize)

        let labelNode = SKLabelNode(text: title)
        labelNode.fontColor = headerFontColor
        labelNode.fontSize = headerFontSize
        labelNode.fontName = tileLabelFontName
        labelNode.position = CGPointMake(0, -labelNode.fontSize / 2)
        headerNode.addChild(labelNode)

        // Create, configure, and add RadialMenu as child node
        let trashMenuItem = RadialMenuItem(target: self, andAction: DialChooser.menuTrashSelected, withIconImageName: "TrashIcon")

        let menu = RadialMenu(menuItems: [trashMenuItem])
        menu.position = CGPointMake(headerNode.size.width / 2, headerNode.size.height / 2)
        addChild(menu)

        addChild(headerNode)
    }

    func menuTrashSelected(radialMenu: RadialMenu) {
        self.removeFromParent()
    }

    func addDialContainerNode() {
        dialContainerNode = SKSpriteNode(color: dialContainerColor, size: CGSizeMake(150, 150))
        dialContainerNode.position = CGPointMake(0, -(headerChoiceGap + 75 + (headerTileSize.height / 2)))
        addChild(dialContainerNode)
    }
    
    func addDialNode(max: Double, min: Double, dialType: RelativeDialNodeType) {
        let dialNode = RelativeDialNode(min: min, max: max)
        dialNode.dialType = dialType
        dialNode.position = CGPointMake(0, -(headerChoiceGap + 75 + (headerTileSize.height / 2)))
        dialNode.delegate = self
        addChild(dialNode)
    }

    func dialValueChanged(dial: RelativeDialNode) {
        if let actualDelegate = delegate {
            actualDelegate.valueChanged(dial.currentValue, valueChooser: self)
        }
    }

//    func addChoiceNodes() {
//        
//        for (index, choice) in enumerate(values) {
//            
//            let choiceTile = SKSpriteNode(color: choiceDeselectedTileColor, size: choiceTileSize)
//            let choiceLabel = SKLabelNode(text: choice)
//            choiceLabel.fontSize = calculateFontSize(choice)
//            choiceLabel.fontColor = choiceFontColor
//            choiceLabel.fontName = tileLabelFontName
//            choiceLabel.position = CGPointMake(0, -choiceLabel.fontSize / 2)
//            choiceTile.addChild(choiceLabel)
//            
//            var tileY = -headerTileSize.height / 2
//            tileY -= headerChoiceGap
//            tileY -= CGFloat(index) * interChoiceGap
//            tileY -= CGFloat(index) * (choiceTileSize.height)
//            tileY -= choiceTileSize.height / 2
//            
//            choiceTile.position = CGPointMake(0, tileY)
//            
//            choiceTile.userInteractionEnabled = true
//            
//            choiceTile.userData = NSMutableDictionary(objects: [choice, false], forKeys: [dictKeyValue, dictKeySelected])
//            
//            let panRecognizer = BBPanGestureRecognizer(target: self, action: ListChooser.scrollChoices)
//            choiceTile.addGestureRecognizer(panRecognizer)
//            
//            let tapRecognizer = BBTapGestureRecognizer(target: self, action: ListChooser.choiceTapped)
//            choiceTile.addGestureRecognizer(tapRecognizer)
//            
//            choiceContainerNode.addChild(choiceTile)
//            choiceNodes.append(choiceTile)
//        }
//    }
//    
//    func selectChoice(choiceNode: SKSpriteNode) {
//        choiceNode.userData!.setValue(true, forKey: dictKeySelected)
//        selectedValues.append(choiceNode.userData!.valueForKey(dictKeyValue) as String)
//        choiceNode.color = choiceSelectedTileColor
//        
//        if delegate != nil {
//            delegate!.choicesChanged(selectedValues, listChooser: self)
//        }
//    }
//    
//    func deselectChoice(choiceNode: SKSpriteNode) {
//        choiceNode.userData!.setValue(false, forKey: dictKeySelected)
//        let value = choiceNode.userData!.valueForKey(dictKeyValue) as String
//        if let index = find(selectedValues, value) {
//            selectedValues.removeAtIndex(index)
//        }
//        choiceNode.color = choiceDeselectedTileColor
//        
//        if delegate != nil {
//            delegate!.choicesChanged(selectedValues, listChooser: self)
//        }
//    }
//    
//    func moveChooser(panRecognizer: BBGestureRecognizer?) {
//        
//        if let recognizer = panRecognizer as? BBPanGestureRecognizer {
//            
//            if recognizer.state == .Changed {
//                
//                let translation = recognizer.translationInNode(self.scene!)
//                recognizer.setTranslation(CGPointZero, inNode: self.scene!)
//                position = CGPointMake(position.x + translation.x, position.y + translation.y)
//            }
//        }
//    }
//    
//    func scrollChoices(panRecognizer: BBGestureRecognizer?) {
//        
//        if let recognizer = panRecognizer as? BBPanGestureRecognizer {
//            
//            if recognizer.state == .Changed {
//                
//                let translation = recognizer.translationInNode(self.scene!)
//                recognizer.setTranslation(CGPointZero, inNode: self.scene!)
//                
//                for choiceNode in choiceNodes {
//                    choiceNode.position = CGPointMake(0, choiceNode.position.y + translation.y)
//                }
//            }
//        }
//    }
//    
//    func choiceTapped(tapRecognizer: BBGestureRecognizer?) {
//        
//        if let recognizer = tapRecognizer as? BBTapGestureRecognizer {
//            if recognizer.state == .Recognized {
//                let node = recognizer.node! as SKSpriteNode
//                
//                let selected = node.userData?.valueForKey(dictKeySelected) as? Bool
//                
//                if selected != nil {
//                    if selected == true {
//                        deselectChoice(node)
//                    } else {
//                        selectChoice(node)
//                    }
//                }
//            }
//        }
//    }
//    
//    func calculateFontSize(text: String) -> CGFloat {
//        
//        var scaledFontSize: CGFloat = 18
//        let targetWidth = TileWidth - 10
//        
//        while true {
//            
//            // Add a hidden label to the tile
//            let labelNode = SKLabelNode(text: text)
//            labelNode.position = CGPointZero
//            labelNode.fontName = "HelveticaNeue-CondensedBold"
//            labelNode.fontSize = scaledFontSize
//            labelNode.alpha = 0
//            labelNode.verticalAlignmentMode = .Center
//            addChild(labelNode)
//            
//            // Calculate the size of the label
//            let width = labelNode.calculateAccumulatedFrame().size.width
//            
//            // If it is too wide
//            if width > targetWidth {
//                scaledFontSize -= 2
//                labelNode.removeFromParent()
//                
//                // Otherwise, return the current size
//            } else {
//                
//                labelNode.removeFromParent()
//                return scaledFontSize
//            }
//        }
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
