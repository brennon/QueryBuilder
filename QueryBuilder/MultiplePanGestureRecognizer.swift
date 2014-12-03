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
        
        super.touchesBegan(touches, withEvent: event)
        
        for touch in touches {
            currentTouches.append(touch as UITouch)
        }
        
        state = .Began
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
        
        super.touchesMoved(touches, withEvent: event)

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

    // Add new touches to currentTouches
    func addUntrackedTouchesFromSet(touches: NSSet!) {
        
        for touch in touches {
            
            let index = find(currentTouches, touch as UITouch)
            
            if index == nil {

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
        
        currentTouches = []
    }
}
