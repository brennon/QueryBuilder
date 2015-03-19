//
//  GameScene.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 11/17/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import SpriteKit

/*!
    The `GameScene` is the main scene in the application. It coordinates the 
    main actors in the scene: the sandbox (general work area), the 
    `PropertyTrayNode` that holds `PropertyTile`s for use in building queries, 
    and the `CompletedQueryNode` where query predicates are placed for use in 
    the constructed query.
*/
class GameScene: SKScene {
    
    // MARK: Instance Variables
    
//    var panRecognizer: MultiplePanGestureRecognizer!
    var touchNodeMap = TouchNodeMap()
//    var propertyTiles = Array<PredicateTileNode>()
    var propertyTrayNode: PropertyTrayNode?
    var collection: Collection?
//    var statusNode: SKLabelNode!
    var propertyTrayNeedsUpdate = false
    
    // MARK: Initializers
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
//        addTestPredicateNodes()
        
        // Add a node for displaying status messages
//        addStatusNode()
        
        // Add pan gesture recognizer to the view
//        panRecognizer = MultiplePanGestureRecognizer(
//            target: self,
//            action: "handleMultiplePan:"
//        )
//        view.addGestureRecognizer(panRecognizer)
        
        // Add the property tray
        addPropertyTray(collection!)
        
        addRunQueryButton()
        
        // Setup physics
        physicsWorld.gravity = CGVectorMake(0, 0)
    }
    
    func addRunQueryButton() {
        let buttonNode = SKShapeNode(circleOfRadius: 25)
        buttonNode.fillColor = RunQueryButtonColor
        buttonNode.position = CGPointMake(size.width / 2, 45)
        buttonNode.userInteractionEnabled = true
        buttonNode.alpha = 0
        
        let tapRecognizer = BBTapGestureRecognizer(target: self, action: GameScene.runQuery)
        buttonNode.addGestureRecognizer(tapRecognizer)
        
        addChild(buttonNode)
        
        let buttonIcon = SKSpriteNode(imageNamed: "RunIcon")
        buttonIcon.size = CGSizeMake(30, 30)
        buttonNode.addChild(buttonIcon)
        
        buttonNode.runAction(SKAction.sequence([
            SKAction.waitForDuration(1),
            SKAction.fadeInWithDuration(0.5)
        ]))
    }
    
    func runQuery(tapRecognizer: BBGestureRecognizer?) {
        var subPredicates = [MongoPredicate]()
        
        enumerateChildNodesWithName(PredicateTileNodeName, usingBlock: { (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            
            if let predicateNode = node as? PredicateTileNode {
                if predicateNode.predicateGroup == nil {
                    if let predicate = predicateNode.generatePredicateForTile() {
                        subPredicates.append(predicate)
                    }
                }
            }
        })
        
        enumerateChildNodesWithName(PredicateGroupNodeName, usingBlock: { (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            
            if let predicateGroupNode = node as? PredicateGroupNode {
                subPredicates.append(predicateGroupNode.generatePredicateForGroup())
            }
        })
        
        if subPredicates.count > 0 {
        
            dispatch_async(QueueManager.sharedInstance.getDatabaseQueue()) {
                let mainPredicate = MongoPredicate.andPredicateWithArray(subPredicates)
                let collectionName = self.collection!.collectionName
                let databaseName = self.collection!.databaseName
                let qualifiedName = "\(databaseName).\(collectionName)"
                let dbHelper = DatabaseHelper()
                dbHelper.authenticateToDatabase()
                
                println("Query: \(mainPredicate)")
                
                let connection = dbHelper.connection
                let liveCollection: MongoDBCollection = connection!.collectionWithName(qualifiedName)
                
                var error : NSError? = nil
                error = nil
                let result = liveCollection.findWithPredicate(mainPredicate, error: &error)
                
                var displayString: String
                if error == nil && result.count > 0 {
                    displayString = "\(result.count) matching documents"
                } else {
                    displayString = "No matching documents"
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.showStatusString(displayString)
                }
            }
        } else {
            showStatusString("No matching documents")
        }
    }
    
    func showStatusString(text: String) {
        let statusNode = SKLabelNode(text: text)
        statusNode.fontSize = 48
        statusNode.fontColor = QBColorComplementDarkest
        statusNode.alpha = 0
        statusNode.position = CGPointMake(size.width / 2, 100)
        self.addChild(statusNode)
        
        let fadeIn = SKAction.fadeInWithDuration(0.5)
        let wait = SKAction.waitForDuration(2.0)
        let fadeOut = SKAction.fadeOutWithDuration(0.5)
        let remove = SKAction.removeFromParent()
        statusNode.runAction(SKAction.sequence([fadeIn, wait, fadeOut, remove]))
    }
    
    func addPropertyTray(collection: Collection) {
        
        // Remove the current PropetyTrayNode, if it exists
        propertyTrayNode?.removeFromParent()
        
        // Create a new PropertyTrayNode
        propertyTrayNode = PropertyTrayNode(collection: collection)
        propertyTrayNode!.position = CGPointMake(0, size.height / 2)
        
        addChild(propertyTrayNode!)
    }
    
    // MARK: Node Manipulation
    
    /*!
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
    
    /*!
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
        
        if let tray = propertyTrayNode {
            if tray.needsLayout {
                tray.updateLayout(tray.propertyNodes[0], animated: false, completion: {})
                tray.needsLayout = false
            }
        }
        
        enumerateChildNodesWithName("//list-chooser", usingBlock: { (node: SKNode!, pointer: UnsafeMutablePointer<ObjCBool>) -> Void in
            if let listChooserNode = node as? ListChooser {
                listChooserNode.update()
            }
        })
        
        enumerateChildNodesWithName("//\(PredicateTileNodeName)", usingBlock: { (node: SKNode!, pointer: UnsafeMutablePointer<ObjCBool>) -> Void in
            if let predicateTileNode = node as? PredicateTileNode {
                predicateTileNode.update()
            }
        })
        
        enumerateChildNodesWithName("//\(PredicateGroupNodeName)", usingBlock: { (node: SKNode!, pointer: UnsafeMutablePointer<ObjCBool>) -> Void in
            if let predicateGroupNode = node as? PredicateGroupNode {
                predicateGroupNode.update()
            }
        })
    }
}
