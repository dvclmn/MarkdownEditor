//
//  TextHighlighter.swift
//  
//
//  Created by Dave Coleman on 3/7/2024.
//

import Foundation
import SwiftUI

class TextHighlighter {
    private var originalAttributes: [NSRange: [NSAttributedString.Key: Any]] = [:]
    private weak var textStorage: NSTextStorage?

    init(textStorage: NSTextStorage) {
        self.textStorage = textStorage
    }

    func applyHighlights(forSearchTerm searchTerm: String) {
        guard let textStorage = textStorage else { return }
        let fullRange = NSRange(location: 0, length: textStorage.length)
        let highlightColour = NSColor.orange

        // Clear previous highlights and restore original attributes
        restoreOriginalAttributes()

        // Apply new highlights for the current search term
        if let searchRegex = try? Regex(searchTerm), searchTerm.count > 0 {
            let searchMatches = textStorage.string.matches(of: searchRegex)
            
            for match in searchMatches {
                let range = NSRange(match.range, in: textStorage.string)
                saveOriginalAttributes(in: range)
                let highlightAttribute: [NSAttributedString.Key: Any] = [.backgroundColor: highlightColour]
                textStorage.addAttributes(highlightAttribute, range: range)
            }
        }
    }

    func clearHighlights() {
        restoreOriginalAttributes()
    }

    private func saveOriginalAttributes(in range: NSRange) {
        guard let textStorage = textStorage else { return }
        if originalAttributes[range] == nil {
            // Save the original attributes before applying the highlight
            originalAttributes[range] = textStorage.attributes(at: range.location, longestEffectiveRange: nil, in: range)
        }
    }

    private func restoreOriginalAttributes() {
        guard let textStorage = textStorage else { return }
        for (range, attributes) in originalAttributes {
            textStorage.setAttributes(attributes, range: range)
        }
        originalAttributes.removeAll()
    }
}

// Usage
//let textHighlighter = TextHighlighter(textStorage: yourTextStorage)
//textHighlighter.applyHighlights(forSearchTerm: "searchTerm")
// ... when done with searching
//textHighlighter.clearHighlights()
