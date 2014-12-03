//
//  TouchNodeMap.swift
//  QueryBuilder
//
//  Created by Brennon Bortz on 12/2/14.
//  Copyright (c) 2014 Brennon Bortz. All rights reserved.
//

import SpriteKit

/**
`TouchNodeMap` is a class that associates touches with nodes. This is useful,
for instance, when tracking multiple touches and maintaining a relationship
between each touch and a particular node.
*/
class TouchNodeMap: Printable, SequenceType {
    
    /// Dictionary to hold mappings
    private var touchNodeMap = Dictionary<UITouch, SKNode>()
    private let touchKey = "touch"
    private let nodeKey = "node"
    
    var description: String {
        return "TouchNodeMap: \(touchNodeMap)"
    }
    
    /**
    Add a `UITouch`/`SKNode` pair to the map
    
    :param: touch The `UITouch` to add to the map
    :param: withNode The `SKNode` to associate with the `UITouch` in `touch`
    */
    func add(touch: UITouch, withNode node: SKNode) {
        
        // Check for touch in map
        let index = touchNodeMap.indexForKey(touch)
        
        if index == nil {
            touchNodeMap[touch] = node
        }
    }
    
    /**
    Remove a `UITouch` and its associated node from the map
    
    :param: touch The `UITouch` to be removed from the map
    */
    func remove(touch: UITouch) {
        
        // Check for touch in map
        if let index = touchNodeMap.indexForKey(touch) {
            touchNodeMap.removeAtIndex(index)
        }
    }
    
    /**
    Retrieve the `SKNode` associated with a particular touch in the map
    
    :param: touch The `UITouch` for which an `SKNode` should be returned
    
    :returns: An `SKNode?`. `nil` is returned when no matching `UITouch` was
    found in the map.
    */
    func nodeForTouch(touch: UITouch) -> SKNode? {
        
        // Check for touch in map
        if let index = touchNodeMap.indexForKey(touch) {
            
            return touchNodeMap[touch]
        }
        
        return nil
    }
    
    /**
    Determine if a touch is already stored in the map
    
    :param: touch The `UITouch` for which to check the map
    
    :returns: Returns `true` if the `UITouch` was found in the map, `false`
    otherwise.
    */
    func touchExistsInMap(touch: UITouch) -> Bool {
        
        return touchNodeMap.indexForKey(touch) != nil
    }
    
    /**
    Prunes all touches from the map unless they are present in the provided
    set of touches
    
    :param: touches The set of `UITouch`es to keep in the map
    */
    func prune(touches: Array<UITouch>) {
        
        for (touch, _) in self {
            
            let index = find(touches, touch)
            
            if index == nil {
                remove(touch)
            }
        }
    }
    
    /**
    Remove all entries from the map
    */
    func empty() {
        touchNodeMap = Dictionary<UITouch, SKNode>()
    }
    
    /**
    Find the most recent touch in the map, along with its associated node
    */
    func mostRecentTouchAndNode() -> (UITouch?, SKNode?) {
        
        // Sort UITouch keys in descending order by timestamp
        var keys = touchNodeMap.keys.array
        
        // If there are no entries in the map, return nil
        if keys.count == 0 {
            return (nil, nil)
        }
        
        sort(&keys) {
            let lhs = $0
            let rhs = $1
            return lhs.timestamp > rhs.timestamp
        }
        
        return (keys[0], touchNodeMap[keys[0]])
    }
    
    func generate() -> GeneratorOf<(UITouch, SKNode)> {
        var index = 0
        
        return GeneratorOf<(UITouch, SKNode)> {
            if index < self.touchNodeMap.keys.array.count {
                let key = self.touchNodeMap.keys.array[index++]
                let value = self.touchNodeMap[key]!
                return (key, value)
            } else {
                return nil
            }
        }
    }
}
