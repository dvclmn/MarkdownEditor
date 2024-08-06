//
//  File.swift
//  
//
//  Created by Dave Coleman on 28/7/2024.
//

import SwiftUI

extension MDTextView {
    
    //    func applyStyles(to range: NSRange) {
    //        guard let textStorage = self.textStorage else { return }
    //
    //        textStorage.beginEditing()
    //
    //        for syntax in MarkdownSyntax.allCases {
    //            styleText(for: syntax, in: range)
    //        }
    //
    //        textStorage.endEditing()
    //    }
        
        
//    
//    @MainActor
//    public func styleText(
//        for syntax: MarkdownSyntax,
//        in range: NSRange
//    ) {
//        
//        guard let textStorage = self.textStorage else { return }
//        
//        guard let regex = syntax.regex else { return }
//        
//        let string = textStorage.string
//        let searchRange = NSIntersectionRange(range, NSRange(location: 0, length: textStorage.length))
//        
//        regex.enumerateMatches(in: string, options: [], range: searchRange) { match, _, _ in
//            guard let match = match else { return }
//            
//            let matchRange = match.range
//            let syntaxCharacterCount = syntax.syntaxCharacters.count
//            let isSyntaxSymmetrical = syntax.syntaxSymmetrical
//            
//            // Content range
//            let contentLocation = max(0, syntax == .codeBlock ? matchRange.location + syntaxCharacterCount + 1 : matchRange.location + syntaxCharacterCount)
//            let contentLength = min(matchRange.length - (isSyntaxSymmetrical ? 2 : 1) * syntaxCharacterCount, string.count - contentLocation)
//            let contentRange = NSRange(location: contentLocation, length: contentLength)
//            
//            // Opening syntax range
//            let startSyntaxLocation = matchRange.location
//            let startSyntaxLength = min(syntax == .codeBlock ? syntaxCharacterCount + 1 : syntaxCharacterCount, string.count - startSyntaxLocation)
//            let startSyntaxRange = NSRange(location: startSyntaxLocation, length: startSyntaxLength)
//            
//            // Closing syntax range
//            let endSyntaxLocation = max(0, matchRange.location + matchRange.length - syntaxCharacterCount)
//            let endSyntaxLength = min(syntax == .codeBlock ? syntaxCharacterCount + 1 : syntaxCharacterCount, string.count - endSyntaxLocation)
//            let endSyntaxRange = NSRange(location: endSyntaxLocation, length: endSyntaxLength)
//            
//            
//            
//            
//            //            textStorage.removeAttribute(.backgroundColor, range: contentRange)
//            // Remove all existing styles
//            textStorage.removeAttribute(.font, range: contentRange)
//            textStorage.removeAttribute(.foregroundColor, range: contentRange)
//            
//            // Should we apply any default styling before the syntax-based styles?
//            
//            
//            // Apply attributes
//            textStorage.addAttributes(syntax.syntaxAttributes, range: startSyntaxRange)
//            textStorage.addAttributes(syntax.syntaxAttributes, range: endSyntaxRange)
//            
//            textStorage.addAttributes(syntax.contentAttributes, range: contentRange)
//            
//            if syntax == .codeBlock {
//                
//                if let highlightr = highlightr {
//                    
//                    highlightr.setTheme(to: "xcode-dark")
//                    
//                    highlightr.theme.setCodeFont(.monospacedSystemFont(ofSize: 14, weight: .medium))
//                    
//                    // Extract the substring for the code block
//                    
//                    textStorage.addAttributes(syntax.syntaxAttributes, range: startSyntaxRange)
//                    
//                    
//                    let codeString = textStorage.attributedSubstring(from: contentRange).string
//                    
//                    // Highlight the extracted code string
//                    if let highlightedCode = highlightr.highlight(codeString, as: "swift") {
//                        
//                        textStorage.replaceCharacters(in: contentRange, with: highlightedCode)
//                        
//                        let codeBackground: [NSAttributedString.Key : Any] = [.backgroundColor: NSColor.black.withAlphaComponent(MarkdownDefaults.backgroundCodeBlock)]
//                        
//                        textStorage.addAttributes(codeBackground, range: contentRange)
//                        
//                    }
//                } // END highlighter check
//                
//            } // end code block check
//        } // END range enumeration
//        
//        
//        //    if self.searchText.count > 0 {
//        //        textHighlighter.applyHighlights(forSearchTerm: self.searchText)
//        //    } else {
//        //        textHighlighter.clearHighlights()
//        //    }
//        
//        
//        /// Re-applies codeBlock background
//        ///
//        //        if self.searchText.count > 0 {
//        //
//        //
//        //            let fullRange = NSRange(location: 0, length: attributedString.length)
//        //            let highlightColour = NSColor.orange
//        //            let escapedSearchTerm = NSRegularExpression.escapedPattern(for: self.searchText)
//        //
//        //            // Step 1: Store the original background colors before highlighting
//        //            var originalBackgroundColors: [NSRange: NSColor] = [:]
//        //
//        //            textStorage.enumerateAttribute(.backgroundColor, in: fullRange, options: []) { attributeValue, range, _ in
//        //                if let backgroundColor = attributeValue as? NSColor {
//        //                    originalBackgroundColors[range] = backgroundColor
//        //                }
//        //            }
//        //
//        //            // Step 2: Apply the search term highlights (as you've done in your existing code)
//        //            textStorage.addAttribute(.backgroundColor, value: NSColor.clear, range: fullRange)
//        //
//        //            if let searchRegex = try? Regex(escapedSearchTerm) {
//        //
//        //                let searchMatches = string.matches(of: searchRegex)
//        //
//        //                for match in searchMatches {
//        //                    let range = NSRange(match.range, in: string)
//        //
//        //                    let highlightAttribute: [NSAttributedString.Key: Any] = [.backgroundColor: highlightColour]
//        //
//        //                    //                    attributedString.addAttributes(highlightAttribute, range: range)
//        //                    textStorage.addAttributes(highlightAttribute, range: range)
//        //                }
//        //            } else {
//        //                print("Error highlighting search term")
//        //            }
//        //        } // END search check
//        
//        // ...
//        
//        //        // Step 3: Restore the original background colors when the search is cleared or changed
//        //        if self.searchText.count == 0 {
//        //            for (range, color) in originalBackgroundColors {
//        //                textStorage.addAttribute(.backgroundColor, value: color, range: range)
//        //            }
//        //        } else {
//        //            // Clear search highlights without affecting other attributes
//        //            for (range, _) in originalBackgroundColors {
//        //                if let originalColor = originalBackgroundColors[range] {
//        //                    textStorage.addAttribute(.backgroundColor, value: originalColor, range: range)
//        //                } else {
//        //                    textStorage.removeAttribute(.backgroundColor, range: range)
//        //                }
//        //            }
//        //
//        //            // Apply new search term highlights...
//        //            // ...
//        //        }
//
//        
//    } // END style text
//    
}
