//
//  File.swift
//  
//
//  Created by Dave Coleman on 6/8/2024.
//

import SwiftUI


// MARK: Code container

final class MDTextContainer: NSTextContainer {
    
    // We adapt line fragment rects in two ways: (1) we leave `gutterWidth` space on the left hand side and (2) on every
    // line that contains a message, we leave `MessageView.minimumInlineWidth` space on the right hand side (but only for
    // the first line fragment of a layout fragment).
    @MainActor override func lineFragmentRect(forProposedRect proposedRect: CGRect,
                                   at characterIndex: Int,
                                   writingDirection baseWritingDirection: NSWritingDirection,
                                   remaining remainingRect: UnsafeMutablePointer<CGRect>?)
    -> CGRect
    {
        let superRect      = super.lineFragmentRect(forProposedRect: proposedRect,
                                                    at: characterIndex,
                                                    writingDirection: baseWritingDirection,
                                                    remaining: remainingRect),
            calculatedRect = CGRect(x: 0, y: superRect.minY, width: size.width, height: superRect.height)
        
        
        
        
        
        guard let textView    = textView as? MDTextView,
              let mdTextStorage = textView.textStorage,
              let delegate    = mdTextStorage.delegate as? MDTextStorageDelegate,
              let line        = delegate.lineMap.lineOf(index: characterIndex),
              let oneLine     = delegate.lineMap.lookup(line: line),
              characterIndex == oneLine.range.location     // do the following only for the first line fragment of a line
        else { return calculatedRect }
        
        return calculatedRect
    }
}
