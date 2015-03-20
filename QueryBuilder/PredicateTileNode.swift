//
//  PredicateTileNode.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 12/3/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import SpriteKit

enum PredicatePropertyType {
    case Integer
    case BSONObjectID
    case Double
    case DateTime
    case String
    case Unknown
}

enum PredicateType {
    case Existence
    case Value
    case Choice
}

// FIXME: Notting a value predicate with menu does not actual predicate

/**
    A `PredicateTileNode` is a visual representation of a predicate in a
    MongoDB query.
 */
class PredicateTileNode: TileNode, ListChooserDelegate, DialChooserDelegate {
    
    // MARK: Properties
    
    /// The dictionary for the field that this node represents, as configured
    /// by a `Collection`
    var _propertyDict: NSMutableDictionary?
    var propertyDict: NSMutableDictionary? {
        get {
            return _propertyDict
        }
        set {
            if let validType = newValue?.valueForKey("type") as? String {
                switch validType {
                case "int":
                    propertyType = .Integer
                case "double":
                    propertyType = .Double
                case "datetime":
                    propertyType = .DateTime
                case "string":
                    propertyType = .String
                case "BSONObjectID":
                    propertyType = .BSONObjectID
                default:
                    propertyType = .Unknown
                    println("Unknown type: validType")
                }
            } else {
                println("No type: \(self)")
            }
            _propertyDict = newValue
        }
    }
    var title: String!
    
    var isHighlighted = false
    var highlightNode: SKShapeNode!
    
    var selectedChoices: [String]?
    
    var selectedValue: Double?
    
    var propertyType = PredicatePropertyType.Unknown
    
    var radialMenu: RadialMenu!
    
    var predicateType = PredicateType.Existence
    
    var predicateIsNotted = false
    
    var notMenu: RadialMenu!
    
    var selectedComparison: String?
    var comparisonMenu: RadialMenu!
    
    var descriptionTile: SKSpriteNode!
    var descriptionLabel: ASAttributedLabelNode!
    
    var predicateGroup: PredicateGroupNode? = nil
    
    var listChooser: ListChooser? = nil
    var dialChooser: DialChooser? = nil
    var chooserIsVisible = false
    
    // MARK: Initialization
    
    /**
        Assigns the node's sprite and name, and configures its physics.
        
        :param: label The string to use for the tile's label.
    */
    init(label: String) {
        
        super.init()
        
        // Add label to userData
        if userData == nil {
            userData = NSMutableDictionary()
        }
        userData?.setValue(label, forKey: "label")
        
        self.title = label
        self.name = PredicateTileNodeName
        
        // Create, configure, and add label node as child node
        labelNode = SKLabelNode(text: label)
        labelNode!.position = CGPointZero
        labelNode!.fontName = TileLabelFontName
        labelNode!.fontColor = TileLabelFontColor
        labelNode!.verticalAlignmentMode = .Center
        labelNode!.fontSize = calculateFontSize(label)
        addChild(labelNode!)
        
        let panRecognizer = BBPanGestureRecognizer(target: self, action: PredicateTileNode.handlePan)
        addGestureRecognizer(panRecognizer)
        
        descriptionTile = SKSpriteNode(color: PredicateTileDescriptionColor, size: TileSize)
        descriptionTile.position = CGPointMake(0, -TileSize.height - 2)
        addChild(descriptionTile)
        
        updateDescriptionLabel()
        
        // Create, configure, and add RadialMenu as child node
        let trashMenuItem = RadialMenuItem(target: self, andAction: PredicateTileNode.trashSelected, withIconImageName: "TrashIcon")
        let notMenuItem = RadialMenuItem(target: self, andAction: PredicateTileNode.notSelected, withIconImageName: "NotIcon")
        let equalMenuItem = RadialMenuItem(target: self, andAction: PredicateTileNode.comparisonSelected, withIconImageName: "EqualIcon")
        let existsMenuItem = RadialMenuItem(target: self, andAction: PredicateTileNode.existsSelected, withIconImageName: "ExistsIcon")
        
        let menu = RadialMenu(menuItems: [trashMenuItem, notMenuItem, equalMenuItem, existsMenuItem])
        menu.position = CGPointMake(size.width / 2, size.height / 2)
        addChild(menu)
        
        // Create, configure, and add a RadialMenu for removing `notMenu`.
        let notTrashMenuItem = RadialMenuItem(target: self, andAction: PredicateTileNode.notTrashSelected, withIconImageName: "TrashIcon")
        notMenu = RadialMenu(menuItems: [notTrashMenuItem])
        notMenu.position = CGPointMake(-size.width / 2, size.height / 2)
        notMenu.hidden = true
        addChild(notMenu)
        
        // Create, configure, and add a RadialMenu for updating `comparisonMenu`.
        let comparisonEqualsMenuItem = RadialMenuItem(target: self, andAction: PredicateTileNode.comparisonMenuEqualsSelected, withIconImageName: "EqualComparisonIcon")
        let comparisonLessThanMenuItem = RadialMenuItem(target: self, andAction: PredicateTileNode.comparisonMenuLessThanSelected, withIconImageName: "LessThanComparisonIcon")
        let comparisonLessThanOrEqualMenuItem = RadialMenuItem(target: self, andAction: PredicateTileNode.comparisonMenuLessThanOrEqualSelected, withIconImageName: "LessThanOrEqualComparisonIcon")
        let comparisonGreaterThanMenuItem = RadialMenuItem(target: self, andAction: PredicateTileNode.comparisonMenuGreaterThanSelected, withIconImageName: "GreaterThanComparisonIcon")
        let comparisonGreaterThanOrEqualMenuItem = RadialMenuItem(target: self, andAction: PredicateTileNode.comparisonMenuGreaterThanOrEqualSelected, withIconImageName: "GreaterThanOrEqualComparisonIcon")
        comparisonMenu = RadialMenu(menuItems: [comparisonEqualsMenuItem, comparisonLessThanMenuItem, comparisonLessThanOrEqualMenuItem, comparisonGreaterThanOrEqualMenuItem, comparisonGreaterThanMenuItem])
        comparisonMenu.position = CGPointMake(-descriptionTile.size.width / 2, 0)
        comparisonMenu.hidden = true
        descriptionTile.addChild(comparisonMenu)
    }
    
    convenience init?(propertyTile: PropertyTrayTileNode, andLabel label: String) {
        
        self.init(label: label)
        
        if let copiedDict = propertyTile.propertyDict {
            propertyDict = NSMutableDictionary(dictionary: copiedDict, copyItems: true)
        } else {
            return nil
        }
    }

    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: State Management
    
    func choicesChanged(choices: [String], listChooser: ListChooser) {
        selectedChoices = choices
        updateDescription()
    }
    
    func valueChanged(value: Double, valueChooser: DialChooser) {
        selectedValue = value
        updateDescription()
    }
    
    // MARK: Choosers
    
    func showValueChooser() {
        if !chooserIsVisible {
            chooserIsVisible = true
            
            switch propertyType {
            case .Integer, .Double:
                println(".Integer or .Double")
                showDialChooser()
            case .String, .DateTime, .BSONObjectID:
                showListChooser()
            case .Unknown:
                break
            }
        }
    }
    
    func showDialChooser() {
        if let min = propertyDict?.valueForKey("min") as? Double {
            if let max = propertyDict?.valueForKey("max") as? Double {
                if let numericType = propertyDict?.valueForKey("type") as? String {
                    var dialType = RelativeDialNodeType.Integral
                    
                    if numericType == "double" {
                        dialType = .FloatingPoint
                    }
                    
                    dialChooser = DialChooser(max: max, min: min, dialType: dialType, andTitle: "Value for \(title)")
                    dialChooser!.position = CGPointMake(0, -calculateAccumulatedFrame().height / 2)
                    dialChooser!.delegate = self
                    addChild(dialChooser!)
                    selectedValue = 0
                }
            }
        }
    }
    
    func hideDialChooser() {
        if let chooser = dialChooser {
            chooser.removeFromParent()
            dialChooser = nil
        }
    }
    
    func showListChooser() {
        if let values = propertyDict?.valueForKey("values") as? [String] {
            listChooser = ListChooser(values: values, andTitle: title)
            listChooser!.position = CGPointMake(0, -calculateAccumulatedFrame().height / 2)
            listChooser!.delegate = self
            addChild(listChooser!)
        }
    }
    
    func hideListChooser() {
        if let chooser = listChooser {
            chooser.removeFromParent()
            dialChooser = nil
        }
    }
    
    func hideAllChoosers() {
        chooserIsVisible = false
        hideDialChooser()
        hideListChooser()
    }
    
    // MARK: Gestures
    
    func handlePan(panRecognizer: BBGestureRecognizer?) {
        if let recognizer = panRecognizer as? BBPanGestureRecognizer {
            if recognizer.state == .Changed {
                
                let translation = recognizer.translationInNode(scene!)
                
                if let group = predicateGroup {
                    group.translateAllTiles(translation.x, dy: translation.y)
                } else {
                    position = CGPointMake(position.x + translation.x, position.y + translation.y)
                }
                
                recognizer.setTranslation(CGPointZero, inNode: scene!)
                
                unhighlightAllTiles()
                
                if let nearest = findNearestPredicateTile() {
                    let actualDistance = sqrt(pow((self.position.x - nearest.position.x), 2) + pow((self.position.y - nearest.position.y), 2))
                    
                    if actualDistance < 180 {
                        isHighlighted = true
                        nearest.isHighlighted = true
                    }
                }
            }
            
            if recognizer.state == .Ended {
                if let nearest = findNearestPredicateTile() {
                    unhighlightAllTiles()
                    
                    let actualDistance = sqrt(pow((self.position.x - nearest.position.x), 2) + pow((self.position.y - nearest.position.y), 2))
                    
                    if actualDistance < 180 {
                        combineWithPredicateTile(nearest)
                    }
                }
            }
        }
    }
    
    func findNearestPredicateTile() -> PredicateTileNode? {
        var predicateTileCount: Int = 0
        var closestDistance: CGFloat = CGFloat.max
        var closestTile: PredicateTileNode? = nil
        
        if let scene = self.scene {
            scene.enumerateChildNodesWithName(PredicateTileNodeName, usingBlock: { (node: SKNode!, pointer: UnsafeMutablePointer<ObjCBool>) -> Void in
                if node != self {
                    predicateTileCount = predicateTileCount + 1
                    var distance = pow((node.position.x - self.position.x), 2) + pow((node.position.y - self.position.y), 2)
                    if distance < closestDistance {
                        closestDistance = distance
                        closestTile = node as? PredicateTileNode
                    }
                }
            })
        }
        
        return closestTile
    }
    
    // MARK: Compound Predicates
    
    func combineWithPredicateTile(otherPredicate: PredicateTileNode) {
        if let scene = self.scene {
            hideAllChoosers()
            let group = PredicateGroupNode(predicates: [self, otherPredicate], scene: scene)
        }
    }
    
    // MARK: Highlighting
    
    func addHighlightBorder() {
        removeHighlightBorder()
        
        let accumulatedFrame = self.calculateAccumulatedFrame()
        let highlightNodeSize = CGSizeMake(accumulatedFrame.width + 30, accumulatedFrame.height + 30)
        highlightNode = SKShapeNode(rectOfSize: highlightNodeSize, cornerRadius: 5)
        highlightNode.zPosition = SceneLayer.Background.rawValue
        highlightNode.position = CGPointMake(0, -1 - TileSize.height / 2)
        highlightNode.strokeColor = PredicateTileHighlightColor
        addChild(highlightNode)
    }
    
    func removeHighlightBorder() {
        if let oldNode = highlightNode {
            oldNode.removeFromParent()
            highlightNode = nil
        }
    }
    
    func unhighlightAllTiles() {
        if let scene = self.scene {
            scene.enumerateChildNodesWithName(PredicateTileNodeName, usingBlock: { (node: SKNode!, pointer: UnsafeMutablePointer<ObjCBool>) -> Void in
                if let predicateNode = node as? PredicateTileNode {
                    predicateNode.isHighlighted = false
                }
            })
        }
    }
    
    // MARK: Main Radial Menu
    
    func trashSelected(menu: RadialMenu) {
        if let group = predicateGroup {
            group.removePredicate(self)
            group.updateLayout()
        }
        removeFromParent()
    }
    
    func notSelected(menu: RadialMenu) {
        if predicateIsNotted {
            predicateIsNotted = false
            notMenu.hidden = true
        } else {
            notMenu.setThumbText("~")
            predicateIsNotted = true
            notMenu.hidden = false
        }
        updateDescription()
    }
    
    func comparisonSelected(menu: RadialMenu) {
        switch propertyType {
        case .Integer, .Double:
            predicateType = .Value
            selectedComparison = "="
            comparisonMenu.setThumbText("=")
            showComparisonMenu()
        case .String, .DateTime, .BSONObjectID:
            predicateType = .Choice
        default:
            break
        }
        
        showValueChooser()
        updateDescription()
    }
    
    func existsSelected(menu: RadialMenu) {
        predicateType = .Existence
        updateDescription()
    }
    
    // MARK: Not Menu
    
    func notTrashSelected(menu: RadialMenu) {
        notSelected(notMenu)
    }
    
    // MARK: Comparison Menu
    
    func showComparisonMenu() {
        comparisonMenu.hidden = false
    }
    
    func hideComparisonMenu() {
        comparisonMenu.hidden = true
    }
    
    func comparisonMenuEqualsSelected(menu: RadialMenu) {
        comparisonMenu.setThumbText("=")
        selectedComparison = "="
    }
    
    func comparisonMenuLessThanSelected(menu: RadialMenu) {
        comparisonMenu.setThumbText("<")
        selectedComparison = "<"
    }
    
    func comparisonMenuLessThanOrEqualSelected(menu: RadialMenu) {
        comparisonMenu.setThumbText("≤")
        selectedComparison = "≤"
    }
    
    func comparisonMenuGreaterThanSelected(menu: RadialMenu) {
        comparisonMenu.setThumbText(">")
        selectedComparison = ">"
    }
    
    func comparisonMenuGreaterThanOrEqualSelected(menu: RadialMenu) {
        comparisonMenu.setThumbText("≥")
        selectedComparison = "≥"
    }
    
    // MARK: Predicate Description
    
    func updateDescription() {
        var newText = ""
        
        switch predicateType {
        case .Existence:
            newText = descriptionForExistencePredicate()
        case .Value:
            newText = descriptionForValuePredicate()
        case .Choice:
            newText = descriptionForChoicePredicate()
        }
        
        descriptionLabel.attributedString = attributedString(newText)
    }
    
    func updateDescriptionLabel() {
        descriptionLabel = ASAttributedLabelNode(size: CGSizeMake(descriptionTile.size.width - 10, descriptionTile.size.height - 10))
        descriptionLabel.position = CGPointMake(0, 0)
        updateDescription()
        descriptionTile.addChild(descriptionLabel)
    }
    
    func descriptionForChoicePredicate() -> String {
        if selectedChoices?.count > 1 {
            return "\(title) is in \(selectedChoices!)"
        } else if selectedChoices?.count == 1 {
            return "\(title) is \(selectedChoices![0])"
        } else {
            return "\(title) is ..."
        }
    }
    
    
    func descriptionForValuePredicate() -> String {
        if let actualValue = selectedValue {
            if propertyType == PredicatePropertyType.Integer {
                let truncatedValue = String(format: "%.0f", actualValue)
                return "\t\(truncatedValue)"
            } else {
                return "\t\(actualValue)"
            }
        } else {
            return "\t0"
        }
    }
    
    func descriptionForExistencePredicate() -> String {
        if predicateIsNotted {
            return "\(title) does not exist"
        } else {
            return "\(title) exists"
        }
    }
    
    func attributedString(text: String) -> NSAttributedString {
        var font = UIFont(name: "HelveticaNeue-CondensedBold", size: 12)
        var attributes = NSMutableDictionary()
        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Right
        paragraphStyle.lineBreakMode = .ByWordWrapping
        attributes.setValue(UIColor.whiteColor(), forKey: NSForegroundColorAttributeName)
        attributes.setValue(font, forKey: NSFontAttributeName)
        
        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: text, attributes: attributes)
        
        return attrString
    }
    
    // MARK: Predicate Generation
    
    func generatePredicateForTile() -> MongoKeyedPredicate? {
        
        let predicate = MongoKeyedPredicate()
        
        switch predicateType {
        case .Value:
            if predicateIsNotted {
                predicate.keyPath(title, isNotEqualTo: selectedValue)
                return predicate
            } else {
                if selectedComparison == "=" {
                    predicate.keyPath(title, isLessThanOrEqualTo: selectedValue)
                    predicate.keyPath(title, isGreaterThanOrEqualTo: selectedValue)
                } else if selectedComparison == "<" {
                    predicate.keyPath(title, isLessThan: selectedValue)
                } else if selectedComparison == "≤" {
                    predicate.keyPath(title, isLessThanOrEqualTo: selectedValue)
                } else if selectedComparison == ">" {
                    predicate.keyPath(title, isGreaterThan: selectedValue)
                } else if selectedComparison == "≥" {
                    predicate.keyPath(title, isGreaterThanOrEqualTo: selectedValue)
                }
                
                return predicate
            }
            
        case .Existence:
            if predicateIsNotted {
                predicate.valueDoesNotExistForKeyPath(title)
                return predicate
            } else {
                predicate.valueExistsForKeyPath(title)
                return predicate
            }
            
        case .Choice:
            switch propertyType {
            case .BSONObjectID:
                
                var selectedBSONObjectIDs = [BSONObjectID]()
                for (var i = 0; i < selectedChoices!.count; i++) {
                    selectedBSONObjectIDs.append(BSONObjectID(string: selectedChoices![i]))
                }
                
                if selectedChoices?.count > 1 {
                    if predicateIsNotted {
                        predicate.keyPath(title, doesNotMatchAnyFromArray: selectedBSONObjectIDs)
                        return predicate
                    } else {
                        predicate.keyPath(title, matchesAnyFromArray: selectedBSONObjectIDs)
                        return predicate
                    }
                } else if selectedChoices?.count == 1 {
                    if predicateIsNotted {
                        predicate.keyPath(title, isNotEqualTo: selectedBSONObjectIDs[0])
                        return predicate
                    } else {
                        predicate.keyPath(title, matches: selectedBSONObjectIDs[0])
                        return predicate
                    }
                }
            case .String:
                if selectedChoices?.count > 1 {
                    if predicateIsNotted {
                        predicate.keyPath(title, doesNotMatchAnyFromArray: selectedChoices!)
                        return predicate
                    } else {
                        predicate.keyPath(title, matchesAnyFromArray: selectedChoices!)
                        return predicate
                    }
                } else if selectedChoices?.count == 1 {
                    if predicateIsNotted {
                        predicate.keyPath(title, isNotEqualTo: selectedChoices![0])
                        return predicate
                    } else {
                        predicate.keyPath(title, matches: selectedChoices![0])
                        return predicate
                    }
                }
            default:
                break
            }
        }
        
        return nil
    }
    
    // MARK: Update
    
    func update() {
        if isHighlighted {
            addHighlightBorder()
        } else {
            removeHighlightBorder()
        }
    }
}
