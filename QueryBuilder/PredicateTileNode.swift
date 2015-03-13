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
    
    var selectedChoices: [String]?
    
    var selectedValue: Double?
    
    var propertyType = PredicatePropertyType.Unknown
    
    var radialMenu: RadialMenu!
    
    var predicateType = PredicateType.Existence
    
    var predicateIsNotted = false
    
    var notNode: SKShapeNode!
    
    var descriptionTile: SKSpriteNode!
    var descriptionLabel: ASAttributedLabelNode!
    
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
        
        notNode = SKShapeNode(circleOfRadius: 10)
        notNode.fillColor = SKColor.lightGrayColor()
        notNode.position = CGPointMake(-size.width / 2, size.height / 2)
        let notNodeLabel = SKLabelNode(text: "¬")
        notNodeLabel.fontSize = 20
        notNodeLabel.fontName = TileLabelFontName
        notNodeLabel.position = CGPointMake(0, -6)
        notNode.addChild(notNodeLabel)
        
        descriptionTile = SKSpriteNode(color: PredicateTileDescriptionColor, size: TileSize)
        descriptionTile.position = CGPointMake(0, -TileSize.height - 2)
        addChild(descriptionTile)
        
        descriptionLabel = ASAttributedLabelNode(size: CGSizeMake(descriptionTile.size.width - 10, descriptionTile.size.height - 10))
        descriptionLabel.position = CGPointMake(0, 0)
        updateDescription()
        descriptionTile.addChild(descriptionLabel)
        
        // Create, configure, and add RadialMenu as child node
        let trashMenuItem = RadialMenuItem(target: self, andAction: PredicateTileNode.trashSelected, withIconImageName: "TrashIcon")
        let notMenuItem = RadialMenuItem(target: self, andAction: PredicateTileNode.notSelected, withIconImageName: "NotIcon")
        let equalMenuItem = RadialMenuItem(target: self, andAction: PredicateTileNode.equalSelected, withIconImageName: "EqualIcon")
        let existsMenuItem = RadialMenuItem(target: self, andAction: PredicateTileNode.existsSelected, withIconImageName: "ExistsIcon")
        
        let menu = RadialMenu(menuItems: [trashMenuItem, notMenuItem, equalMenuItem, existsMenuItem])
        menu.position = CGPointMake(size.width / 2, size.height / 2)
        addChild(menu)
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
    
    func choicesChanged(choices: [String], listChooser: ListChooser) {
        selectedChoices = choices
        updateDescription()
    }
    
    func valueChanged(value: Double, valueChooser: DialChooser) {
        selectedValue = value
        updateDescription()
    }
    
    func showValueChooser() {
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
    
    func showDialChooser() {
        if let min = propertyDict?.valueForKey("min") as? Double {
            if let max = propertyDict?.valueForKey("max") as? Double {
                if let numericType = propertyDict?.valueForKey("type") as? String {
                    var dialType = RelativeDialNodeType.Integral
                    
                    if numericType == "double" {
                        dialType = .FloatingPoint
                    }
                    
                    let dialChooser = DialChooser(max: max, min: min, dialType: dialType, andTitle: "Value for \(title)")
                    dialChooser.position = CGPointMake(0, -calculateAccumulatedFrame().height / 2)
                    dialChooser.delegate = self
                    addChild(dialChooser)
                }
            }
        }
    }
    
    func showListChooser() {
        if let values = propertyDict?.valueForKey("values") as? [String] {
            let listChooser = ListChooser(values: values, andTitle: "Choices for \(title)")
            listChooser.position = CGPointMake(0, -calculateAccumulatedFrame().height / 2)
            listChooser.delegate = self
            addChild(listChooser)
        }
    }
    
    func handlePan(panRecognizer: BBGestureRecognizer?) {
        if let recognizer = panRecognizer as? BBPanGestureRecognizer {
            if recognizer.state == .Changed {
                let translation = recognizer.translationInNode(scene!)
                recognizer.setTranslation(CGPointZero, inNode: scene!)
                position = CGPointMake(position.x + translation.x, position.y + translation.y)
            }
        }
    }
    
    func trashSelected(menu: RadialMenu) {
        removeFromParent()
    }
    
    func notSelected(menu: RadialMenu) {
        if predicateIsNotted {
            predicateIsNotted = false
            notNode.removeFromParent()
        } else {
            predicateIsNotted = true
            addChild(notNode)
        }
        updateDescription()
    }
    
    func equalSelected(menu: RadialMenu) {
        switch propertyType {
        case .Integer, .Double:
            predicateType = .Value
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
                return "\(title) = \(truncatedValue)"
            } else {
                return "\(title) = \(actualValue)"
            }
        } else {
            return "\(title) = ..."
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
    
    func generatePredicateForTile() -> MongoKeyedPredicate? {
        
        let predicate = MongoKeyedPredicate()
        
        switch predicateType {
        case .Value:
            if predicateIsNotted {
                predicate.keyPath(title, isNotEqualTo: selectedValue)
                return predicate
            } else {
                predicate.keyPath(title, isLessThanOrEqualTo: selectedValue)
                predicate.keyPath(title, isGreaterThanOrEqualTo: selectedValue)
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
}
