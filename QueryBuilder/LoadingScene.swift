//
//  LoadingScene.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 1/5/15.
//  Copyright (c) 2015 Brennon Bortz. All rights reserved.
//

import SpriteKit

class LoadingScene: SKScene {
    
    // MARK: Instance Variables
    
    // MARK: Initializers
    
    var titleNode: SKLabelNode!
    var activityIndicator: UIActivityIndicatorView!
    var databaseQueue: dispatch_queue_t!
    var trials: Collection!
    
    override func didMoveToView(view: SKView) {
        
        // Display the title
        addTitleNode()
        
        // Add a node for displaying status messages
        addActivityIndicator()
        
        // Enabled debugging display
        debuggingDisplay(true)
        
        connectToDatabase()
    }
    
    func advanceToSandbox() {
        
        let sandboxScene = GameScene(size: CGSizeMake(1024, 768))
        sandboxScene.backgroundColor = SceneBackgroundColor
        sandboxScene.scaleMode = .AspectFill
        sandboxScene.collection = trials
        
        let sceneTransition = SKTransition.crossFadeWithDuration(1.0)
        self.view?.presentScene(sandboxScene, transition: sceneTransition)
    }
    
    func addTitleNode() {
        titleNode = SKLabelNode(text: "Monstructor")
        titleNode.position = CGPointMake(size.width / 2, size.height / 2)
        titleNode.fontColor = UIColor.blackColor()
        titleNode.fontSize = 64
        titleNode.fontName = "HelveticaNeue-CondensedBlack"
        titleNode.zPosition = SceneLayer.Foreground.rawValue
        addChild(titleNode)
    }
    
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.frame = CGRectMake((size.width / 2) - 50, size.height / 2, 100, 100)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.view?.addSubview(activityIndicator)
    }
    
    func connectToDatabase() {
        dispatch_async(QueueManager.sharedInstance.getDatabaseQueue()) {
            self.trials = Collection(name: "experiments", inDatabase: "eim")
            self.trials.enumerateFieldNames(5)
            self.trials.getDistinctValuesForAllFields()
            dispatch_async(dispatch_get_main_queue()) {
                self.activityIndicator.stopAnimating()
            }
            self.advanceToSandbox()
        }
    }
    
    // MARK: Testing/Debugging
    
    /*!
    Enables/disables the display of all stock debugging information.
    
    :param: enabled If `true`, diplay of debugging information is enabled.
    If `false`, it is hidden.
    */
    func debuggingDisplay(enabled: Bool) {
        
        view?.showsDrawCount = enabled
        view?.showsFields = enabled
        view?.showsFPS = enabled
        view?.showsNodeCount = enabled
        view?.showsPhysics = !enabled
        view?.showsQuadCount = enabled
    }
}
