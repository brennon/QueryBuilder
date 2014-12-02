//
//  MultiplePanGestureRecognizer.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 12/1/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import UIKit

/**
    MultiplePanGestureRecognizer

    This class allows for multiple pans to be tracked.
*/
class MultiplePanGestureRecognizer: UIGestureRecognizer {
    
    var currentTouches: Array<UITouch> = []
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        
//        println("touchesBegan:withEvent:")
        
        super.touchesBegan(touches, withEvent: event)
        
        /*
        // Are we already tracking some touches?
        if currentTouches.count > 0 {
            
            // Create an array of new touches
            var newTouches: Array<UITouch> = []
            
            println("currentTouches: \(currentTouches)")
            
            for touch in touches {
                println("checking currentTouches for \(touch as UITouch)")
                
                let index = find(currentTouches, touch as UITouch)
                
                println("find result: \(index)")
                
                if index == nil {
                    println("appending to newTouches")
                    newTouches.append(touch as UITouch)
                }
            }
            
            // Were there any new touches
            if newTouches.count > 0 {
                
                // Combine currentTouches and newTouches
                for touch in currentTouches {
                    newTouches.append(touch)
                }
                
                // Reset the gesture recognizer
                println("setting state to .Ended")
                state = .Ended
                reset()
                
                // Call touchesBegan:withEvent: again with all of the touches
                touchesBegan(NSSet(array: newTouches), withEvent: event)
                
            } else {
                println("there were no new touches")
            }
        }
*/
        
        // Add the touches we received to current touches
        for touch in touches {
            currentTouches.append(touch as UITouch)
        }
        
//        println("setting state to .Began")
        state = .Began
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
        
//        println("touchesMoved:withEvent:")
        
        super.touchesMoved(touches, withEvent: event)
        
//        if (touches.count != currentTouches.count) {
//            state = .Ended
//        } else {
//            state = .Changed
//        }
        state = .Changed
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        
        super.touchesEnded(touches, withEvent: event)
        
        removeCancelledOrEndedTouches(touches)
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        
        super.touchesCancelled(touches, withEvent: event)
        
        removeCancelledOrEndedTouches(touches)
    }
    
    func addUntrackedTouchesFromSet(touches: NSSet!) {
        
        for touch in touches {
            
            let index = find(currentTouches, touch as UITouch)
            
            if index == nil {
                println("appending to newTouches")
                currentTouches.append(touch as UITouch)
            }
        }
    }
    
    // Remove received touches from currentTouches array
    func removeCancelledOrEndedTouches(touches: NSSet!) {
        
        for touch in touches {
            if let index = find(currentTouches, touch as UITouch) {
                currentTouches.removeAtIndex(index)
            }
        }
        
        // End the gesture if there are no touches remaining in currentTouches
        if currentTouches.count == 0 {
            state = .Ended
        }
    }
    
    override func reset() {
        
        super.reset()
        
        println("reset")
        
        // Clear current touches array
        currentTouches = []
    }
}
