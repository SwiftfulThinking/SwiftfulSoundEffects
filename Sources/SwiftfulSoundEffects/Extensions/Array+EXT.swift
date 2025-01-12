//
//  Array+EXT.swift
//  SwiftfulSoundEffects
//
//  Created by Nick Sarno on 1/12/25.
//

extension Array {
    
    /// Find next item that meets condition starting at index and looping back to 0 if needed.
    func findNext(startingAt currentIndex: Int, where condition: (Element) -> Bool) -> (element: Element, index: Int)? {
        let count = self.count
        
        // First, loop from currentIndex to end of the array and try to find an element that matches condition
        for index in currentIndex..<count where condition(self[index]) {
            return (self[index], index)
        }
        
        // Otherwise, loop from start of the array to currentIndex and try to find an element that matches condition
        for index in 0..<currentIndex where condition(self[index]) {
            return (self[index], index)
        }
        
        // There is no element found in the array that matches the condition
        return nil
    }
    
}
