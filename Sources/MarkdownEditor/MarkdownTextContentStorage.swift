//
//  File.swift
//  
//
//  Created by Dave Coleman on 5/8/2024.
//

import SwiftUI


// MARK: -
// MARK: Text content storage

class MDTextContentStorage: NSTextContentStorage {
    
    override func processEditing(for textStorage: NSTextStorage,
                                 edited editMask: EditActions,
                                 range newCharRange: NSRange,
                                 changeInLength delta: Int,
                                 invalidatedRange invalidatedCharRange: NSRange)
    {
        

        super.processEditing(for: textStorage,
                             edited: editMask,
                             range: newCharRange,
                             changeInLength: delta,
                             invalidatedRange: invalidatedCharRange)
        
        // If only attributes change, there is no need to adjust rendering attributes. (In fact, we may get here due to
        // forcing redrawing of changed rendering attributes and then we would run into a loop if we don't bail out at this
        // point!)
        guard editMask.contains(.editedCharacters) else { return }
        
        // NB: We need to wait until after the content storage has processed the edit before text locations (and ranges)
        //     match characters counts in the backing store again. Hence, the placement after the super call.
        if let markdownTextStorageDelegate = textStorage.delegate as? MDTextStorageDelegate,
           let invalidationRange = markdownTextStorageDelegate.tokenInvalidationRange,
           let invalidationLines = markdownTextStorageDelegate.tokenInvalidationLines
        {
            let additionalInvalidationRange = if invalidatedCharRange.location == invalidationRange.location {
                NSRange(location: invalidatedCharRange.max, length: invalidationRange.length - invalidatedCharRange.length)
            } else { invalidationRange }
            
            if additionalInvalidationRange.length > 0 && invalidationLines > 1,
               let additionalInvalidationTextRange = textRange(for: additionalInvalidationRange)
            {
                for textLayoutManager in textLayoutManagers {
                    
                    // NB: We do not want to call `NSTextLayoutManager.invalidateRenderingAttributes(for:)` as that removes all
                    //     rendering attributes *without* calling the rendnering attribute validator to set the new attributes.
                    
                    textLayoutManager.redisplayRenderingAttributes(for: additionalInvalidationTextRange)
                }
            }
        }
    }
}
