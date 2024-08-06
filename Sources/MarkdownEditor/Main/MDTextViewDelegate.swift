//
//  File.swift
//
//
//  Created by Dave Coleman on 5/8/2024.
//

import SwiftUI

class MDTextViewDelegate: NSObject, NSTextViewDelegate {
    
    var textDidChange:      ((NSTextView) -> ())?
    var selectionDidChange: ((NSTextView) -> ())?
    
    func textView(
        _ textView: NSTextView,
        willChangeSelectionFromCharacterRanges oldSelectedCharRanges: [NSValue],
        toCharacterRanges newSelectedCharRanges: [NSValue]
    ) -> [NSValue] {
        
        guard let markdownTextStorageDelegate = textView.textStorage?.delegate as? MDTextStorageDelegate
        else { return newSelectedCharRanges }
        
        if let selectionRange = newSelectedCharRanges.first as? NSRange, selectionRange.length == 0 {
            
            return [NSRange(location: selectionRange.location, length: 0) as NSValue]
            
        } else { return newSelectedCharRanges }
    }
    
    func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView else { return }
        
        textDidChange?(textView)
    }
    
    func textViewDidChangeSelection(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView else { return }
        
        selectionDidChange?(textView)
    }
}

/// Custom view for background highlights.
///
final class BackgroundHighlightView: NSBox {
    
    /// The background colour displayed by this view.
    ///
    var color: NSColor {
        get { fillColor }
        set { fillColor = newValue }
    }
    
    init(color: NSColor) {
        super.init(frame: .zero)
        self.color  = color
        boxType     = .custom
        borderWidth = 0
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
