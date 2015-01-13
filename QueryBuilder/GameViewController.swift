//
//  GameViewController.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 11/17/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    /// The `Collection` associated with this run of the app
    var trials: Collection!

    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = LoadingScene(size: CGSizeMake(1024, 768))
        scene.backgroundColor = SceneBackgroundColor
        
        // Configure the view.
        let skView = self.view as SKView
//        skView.showsFPS = true
//        skView.showsNodeCount = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
        
        /*
        let scene = GameScene(size: CGSizeMake(1024, 768))
        scene.backgroundColor = SceneBackgroundColor
        
        // Configure the view.
        let skView = self.view as SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
        
        // Setup Collection for Trial documents
        trials = Collection(name: "trials", inDatabase: "eim")
        trials.enumerateFieldNames(5)
        trials.getDistinctValuesForAllFields()
        
        // Add the Collection to the scene
        scene.useCollection(trials)
        */
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
