//
//  MarkdownEditor.swift
//  Banksia
//
//  Created by Dave Coleman on 19/4/2024.
//

#if os(macOS)

import Foundation
import SwiftUI
import Highlightr
import OSLog

/// Help with NSTextViews:
/// https://developer.apple.com/library/archive/documentation/TextFonts/Conceptual/CocoaTextArchitecture/TextEditing/TextEditing.html#//apple_ref/doc/uid/TP40009459-CH3-SW16
/// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/TextLayout/TextLayout.html#//apple_ref/doc/uid/10000158i


// TextKit 2 Explanation

// 1. NSTextContentStorage vs NSTextStorage
// NSTextContentStorage doesn't directly replace NSTextStorage. Instead, it's a new class that works alongside NSTextStorage in TextKit 2.
// - NSTextStorage is still used and remains the core storage for attributed strings.
// - NSTextContentStorage is a higher-level abstraction that can manage multiple NSTextStorages.

// 2. NSTextLayoutManager vs NSLayoutManager
// NSTextLayoutManager is indeed the TextKit 2 replacement for NSLayoutManager.
// It provides more efficient layout and rendering, especially for large documents.


// NSTextStorage's edited(_:range:changeInLength:)

@MainActor
public class MarkdownEditor: NSTextView, NSTextContentManagerDelegate, NSTextContentStorageDelegate {
    
    var editorHeight: CGFloat
    
    var configuration: MarkdownEditorConfiguration?
    
    var isShowingFrames: Bool
    
    let highlightr = Highlightr()
    
//    private var lastStyledRanges: [NSRange] = []
    
    private var styler: MarkdownStyler
    
    var searchText: String
    
//    private var syntaxList: [MarkdownSyntax] = [
//        .bold, .boldItalic, .italic, .codeBlock, .inlineCode
//    ]
    
    init(
        viewWidth: CGFloat,
        editorHeight: CGFloat = .zero,
        configuration: MarkdownEditorConfiguration? = nil,
        isShowingFrames: Bool,
        searchText: String,
        textContainer: NSTextContainer
    ) {
        
        self.editorHeight = editorHeight
        self.configuration = configuration
        self.isShowingFrames = isShowingFrames
        self.searchText = searchText
        
        // Create TextKit 2 stack
        
//        let textContentStorage = NSTextContentStorage()
        
//        let textContainer = NSTextContainer(size: CGSize(width: frameRect.width, height: .greatestFiniteMagnitude))
        
//        textContentStorage.addTextLayoutManager(textLayoutManager)
        
        self.styler = MarkdownStyler(textContentStorage: textContentStorage)
        
        super.init(frame: frameRect, textContainer: textContainer)
        
        // Set up the text view
        isRichText = false
        font = NSFont.systemFont(ofSize: 14)
        
        // Set up markdown styling
        setupMarkdownStyling()
    }
    

    /// The `required init?(coder: NSCoder)` is necessary for classes that inherit from `NSView`
    /// (which `NSTextView` does). This initializer is used when the view is loaded from a storyboard or XIB file.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func setupMarkdownStyling() {
        // Here you would implement your markdown styling logic
        // This could involve setting up NSTextViewDelegate methods
        // and using regular expressions to apply attributes
    }
    
    
    
    
    
    //
    //    // Override textDidChange to update styling
    //    override func textDidChange(_ notification: Notification) {
    //        super.textDidChange(notification)
    //        // Update markdown styling here
    //    }
    //
    
    public func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        if editedMask.contains(.editedCharacters) {
            
            //            os_log("Applied styles. Executed from within `func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int)`")
            let extendedRange = NSUnionRange(editedRange, textStorage.editedRange)
            
            applyStyles(to: extendedRange)
            
        }
    }
    
    func applyStyles(to range: NSRange) {
        guard let textStorage = self.textStorage else { return }
        
        textStorage.beginEditing()
        
        for syntax in syntaxList {
            styleText(for: syntax, in: range)
        }
        
        textStorage.endEditing()
    }
    
    
    @MainActor
    public func styleText(
        for syntax: MarkdownSyntax,
        in range: NSRange
    ) {
        
        guard let textStorage = self.textStorage else { return }
        
        guard let regex = syntax.regex else { return }
        
        let string = textStorage.string
        let searchRange = NSIntersectionRange(range, NSRange(location: 0, length: textStorage.length))
        
        regex.enumerateMatches(in: string, options: [], range: searchRange) { match, _, _ in
            guard let match = match else { return }
            
            let matchRange = match.range
            let syntaxCharacterCount = syntax.syntaxCharacters.count
            let isSyntaxSymmetrical = syntax.syntaxSymmetrical
            
            // Content range
            let contentLocation = max(0, syntax == .codeBlock ? matchRange.location + syntaxCharacterCount + 1 : matchRange.location + syntaxCharacterCount)
            let contentLength = min(matchRange.length - (isSyntaxSymmetrical ? 2 : 1) * syntaxCharacterCount, string.count - contentLocation)
            let contentRange = NSRange(location: contentLocation, length: contentLength)
            
            // Opening syntax range
            let startSyntaxLocation = matchRange.location
            let startSyntaxLength = min(syntax == .codeBlock ? syntaxCharacterCount + 1 : syntaxCharacterCount, string.count - startSyntaxLocation)
            let startSyntaxRange = NSRange(location: startSyntaxLocation, length: startSyntaxLength)
            
            // Closing syntax range
            let endSyntaxLocation = max(0, matchRange.location + matchRange.length - syntaxCharacterCount)
            let endSyntaxLength = min(syntax == .codeBlock ? syntaxCharacterCount + 1 : syntaxCharacterCount, string.count - endSyntaxLocation)
            let endSyntaxRange = NSRange(location: endSyntaxLocation, length: endSyntaxLength)
            
            
            
            
            //            textStorage.removeAttribute(.backgroundColor, range: contentRange)
            // Remove all existing styles
            textStorage.removeAttribute(.font, range: contentRange)
            textStorage.removeAttribute(.foregroundColor, range: contentRange)
            
            // Should we apply any default styling before the syntax-based styles?
            
            
            // Apply attributes
            textStorage.addAttributes(syntax.syntaxAttributes, range: startSyntaxRange)
            textStorage.addAttributes(syntax.syntaxAttributes, range: endSyntaxRange)
            
            textStorage.addAttributes(syntax.contentAttributes, range: contentRange)
            
            if syntax == .codeBlock {
                
                if let highlightr = highlightr {
                    
                    highlightr.setTheme(to: "xcode-dark")
                    
                    highlightr.theme.setCodeFont(.monospacedSystemFont(ofSize: 14, weight: .medium))
                    
                    // Extract the substring for the code block
                    
                    textStorage.addAttributes(syntax.syntaxAttributes, range: startSyntaxRange)
                    
                    
                    let codeString = textStorage.attributedSubstring(from: contentRange).string
                    
                    // Highlight the extracted code string
                    if let highlightedCode = highlightr.highlight(codeString, as: "swift") {
                        
                        textStorage.replaceCharacters(in: contentRange, with: highlightedCode)
                        
                        let codeBackground: [NSAttributedString.Key : Any] = [.backgroundColor: NSColor.black.withAlphaComponent(MarkdownDefaults.backgroundCodeBlock)]
                        
                        textStorage.addAttributes(codeBackground, range: contentRange)
                        
                    }
                } // END highlighter check
                
            } // end code block check
        } // END range enumeration
        
        
        //    if self.searchText.count > 0 {
        //        textHighlighter.applyHighlights(forSearchTerm: self.searchText)
        //    } else {
        //        textHighlighter.clearHighlights()
        //    }
        
        
        /// Re-applies codeBlock background
        ///
        //        if self.searchText.count > 0 {
        //
        //
        //            let fullRange = NSRange(location: 0, length: attributedString.length)
        //            let highlightColour = NSColor.orange
        //            let escapedSearchTerm = NSRegularExpression.escapedPattern(for: self.searchText)
        //
        //            // Step 1: Store the original background colors before highlighting
        //            var originalBackgroundColors: [NSRange: NSColor] = [:]
        //
        //            textStorage.enumerateAttribute(.backgroundColor, in: fullRange, options: []) { attributeValue, range, _ in
        //                if let backgroundColor = attributeValue as? NSColor {
        //                    originalBackgroundColors[range] = backgroundColor
        //                }
        //            }
        //
        //            // Step 2: Apply the search term highlights (as you've done in your existing code)
        //            textStorage.addAttribute(.backgroundColor, value: NSColor.clear, range: fullRange)
        //
        //            if let searchRegex = try? Regex(escapedSearchTerm) {
        //
        //                let searchMatches = string.matches(of: searchRegex)
        //
        //                for match in searchMatches {
        //                    let range = NSRange(match.range, in: string)
        //
        //                    let highlightAttribute: [NSAttributedString.Key: Any] = [.backgroundColor: highlightColour]
        //
        //                    //                    attributedString.addAttributes(highlightAttribute, range: range)
        //                    textStorage.addAttributes(highlightAttribute, range: range)
        //                }
        //            } else {
        //                print("Error highlighting search term")
        //            }
        //        } // END search check
        
        // ...
        
        //        // Step 3: Restore the original background colors when the search is cleared or changed
        //        if self.searchText.count == 0 {
        //            for (range, color) in originalBackgroundColors {
        //                textStorage.addAttribute(.backgroundColor, value: color, range: range)
        //            }
        //        } else {
        //            // Clear search highlights without affecting other attributes
        //            for (range, _) in originalBackgroundColors {
        //                if let originalColor = originalBackgroundColors[range] {
        //                    textStorage.addAttribute(.backgroundColor, value: originalColor, range: range)
        //                } else {
        //                    textStorage.removeAttribute(.backgroundColor, range: range)
        //                }
        //            }
        //
        //            // Apply new search term highlights...
        //            // ...
        //        }

        
    } // END style text
    
    
    //
    //
    //    public override var intrinsicContentSize: NSSize {
    //        guard let textLayoutManager = self.textLayoutManager else {
    //            return super.intrinsicContentSize
    //        }
    //
    //        let usedRect = textLayoutManager.usedRect(for: textContainer)
    //        let contentSize = NSSize(width: NSView.noIntrinsicMetric, height: usedRect.height)
    //
    //        self.editorHeight = contentSize.height
    //
    //        return contentSize
    //    }
    //
    
    public override var intrinsicContentSize: NSSize {
        
        guard let textLayoutManager = self.textLayoutManager, let container = self.textContainer else {
            return super.intrinsicContentSize
        }
        container.containerSize = NSSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        layoutManager.ensureLayout(for: container)
        
        let rect = layoutManager.usedRect(for: container).size
        
        let contentSize = NSSize(width: NSView.noIntrinsicMetric, height: rect.height)
        
        self.editorHeight = contentSize.height
        
        return contentSize
    }
}






extension MarkdownEditor {

    public override func didChangeText() {
        super.didChangeText()
        invalidateIntrinsicContentSize()
        // Clear the cached styled ranges when text changes
                    lastStyledRanges = []
                    updateStyling()
    }
    
    public override func draw(_ rect: NSRect) {
        super.draw(rect)
        
        if isShowingFrames {
            let border:NSBezierPath = NSBezierPath(rect: bounds)
            let borderColor = NSColor.red.withAlphaComponent(0.3)
            borderColor.set()
            border.lineWidth = 1.0
            border.stroke()
        }
    }
}

#endif



//import Cocoa

extension MarkdownEditor {

    func updateStyling() {
//        guard let layoutManager = self.textLayoutManager else { return }
        guard let textContentStorage = self.textContentStorage else { return }
        guard let textStorage = self.textStorage else { return }
        
        
        guard let textLayoutManager = self.textLayoutManager,
              let textContentManager = textLayoutManager.textContentManager else { return }
        
        let visibleTextRange = self.visibleRange()
        guard let visibleRange = textContentManager.range(for: visibleTextRange) else { return }
        
        
        
        // Add a buffer to the visible range (e.g., 100 characters on either side)
        let bufferLength = 100
        
        let extendedRange = NSRange(
                    location: max(0, visibleRange.location - bufferLength),
                    length: min(textStorage.length - max(0, visibleRange.location - bufferLength),
                                visibleRange.length + 2 * bufferLength)
                )
        
        
        
        // Check if the visible range intersects with any of the last styled ranges
        let needsUpdate = lastStyledRanges.contains { NSIntersectionRange($0, visibleRange).length > 0 }
        
        if needsUpdate {
            applyMarkdownStyling(in: visibleRange)
            lastStyledRanges = [visibleRange]
        }

    }
    
    func applyMarkdownStyling(in range: NSRange) {
            guard let textContentManager = textLayoutManager?.textContentManager,
                  let textRange = textContentManager.textRange(for: range) else { return }
            
            // Example regex for bold markdown
            let boldPattern = "\\*\\*(.*?)\\*\\*"
            
            do {
                let regex = try NSRegularExpression(pattern: boldPattern, options: [])
                let text = textContentManager.attributedString().string as NSString
                
                // Find matches in the specified range
                let matches = regex.matches(in: text as String, options: [], range: range)
                
                for match in matches {
                    let boldRange = match.range(at: 1)
                    
                    // Apply bold attribute
                    textContentManager.performEditingTransaction {
                        if let boldTextRange = textContentManager.textRange(for: boldRange) {
                            textContentManager.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: 14), range: boldTextRange)
                        }
                    }
                }
            } catch {
                print("Error creating regex: \(error)")
            }
        }
    
    
    
    func visibleRange() -> NSTextRange {
        guard let textLayoutManager = self.textLayoutManager else { return }
            
            let visibleRect = self.visibleRect
            var visibleTextRange = NSTextRange(location: 0)
            
            textLayoutManager.enumerateTextLayoutFragments(from: textLayoutManager.documentRange.location, options: [], using: { fragment in
                if fragment.layoutFragmentFrame.intersects(visibleRect) {
                    if let fragmentRange = fragment.textElement?.elementRange {
                        visibleTextRange = visibleTextRange.union(fragmentRange)
                    }
                }
                return fragment.layoutFragmentFrame.maxY > visibleRect.maxY
            })
            
            return visibleTextRange
        }
}

extension NSTextContentManager {
  func range(for textRange: NSTextRange) -> NSRange? {
    let location = offset(from: documentRange.location, to: textRange.location)
    let length = offset(from: textRange.location, to: textRange.endLocation)
    if location == NSNotFound || length == NSNotFound { return nil }
    return NSRange(location: location, length: length)
  }

  func textRange(for range: NSRange) -> NSTextRange? {
    guard let textRangeLocation = location(documentRange.location, offsetBy: range.location),
          let endLocation = location(textRangeLocation, offsetBy: range.length) else { return nil }
    return NSTextRange(location: textRangeLocation, end: endLocation)
  }
}
