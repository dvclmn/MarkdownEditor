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

/// ⚠️ In macOS 12 and later, if you explicitly call the layoutManager property on a text view or text container,
/// the framework reverts to a compatibility mode that uses NSLayoutManager. The text view also switches
/// to this compatibility mode when it encounters text content that’s not yet supported, such as NSTextTable.
/// Read more: https://developer.apple.com/documentation/appkit/nstextview
///
/// Either one of these statements makes text view switch to TextKit 1
/// `let layoutManager = textView. layoutManager`
/// `let containerLayoutManager = textView.textContainer. layoutManager`

@MainActor
public class MarkdownEditor: NSTextView {
    
    var editorHeight: CGFloat
    
    var configuration: MarkdownEditorConfiguration?
    
    var isShowingFrames: Bool
    var isShowingSyntax: Bool
    
    let highlightr = Highlightr()
    
    var editorMetrics: String = ""
    
    
    private var lastStyledRanges: [NSTextRange] = []
    

    //    private var styler: MarkdownStyler
    
    var searchText: String
    
    //    private var syntaxList: [MarkdownSyntax] = [
    //        .bold, .boldItalic, .italic, .codeBlock, .inlineCode
    //    ]
    
    init(
        frame: NSSize,
        editorHeight: CGFloat = .zero,
        configuration: MarkdownEditorConfiguration? = nil,
        isShowingFrames: Bool,
        isShowingSyntax: Bool,
        searchText: String,
        textContainer: NSTextContainer?
    ) {
        
        self.editorHeight = editorHeight
        self.configuration = configuration
        self.isShowingFrames = isShowingFrames
        self.isShowingSyntax = isShowingSyntax
        self.searchText = searchText
        
        super.init(frame: .zero, textContainer: textContainer)
        //        self.styler = MarkdownStyler(textContentStorage: textContentStorage)
        
    }
    
    
    /// The `required init?(coder: NSCoder)` is necessary for classes that inherit from `NSView`
    /// (which `NSTextView` does). This initializer is used when the view is loaded from a storyboard or XIB file.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func updateMarkdownStyling() {
        
        guard let textContentStorage = self.textContentStorage,
              let textLayoutManager = self.textLayoutManager,
              let viewportRange = textLayoutManager.textViewportLayoutController.viewportRange else { return }
        
//        self.updateMetrics(with: "Viewport range: \(viewportRange.description)")
        
        // Check if we need to update styling
//        let needsUpdate: Bool = lastStyledRanges.contains { range in
//            
//            range.intersects(viewportRange)
//        }
        
//        guard needsUpdate || lastStyledRanges.isEmpty else {
//            self.updateMetrics(with: "No update needed")
//            return
//        }
        
        
        
        textContentStorage.performEditingTransaction {
            
            // Reset styling in visible range
            //            textContentStorage.textStorage?.removeAttribute(.font, range: visibleRange)
            //            textContentStorage.addAttribute(.font, value: NSFont.systemFont(ofSize: NSFont.systemFontSize), range: visibleRange)
            
            // Apply markdown styling
            for pattern in MarkdownSyntax.allCases {
                applyStyleForPattern(pattern, in: viewportRange)
                
//                self.updateMetrics(with: "Applied: \(pattern.name)")
            }
            
            // Update last styled ranges
            lastStyledRanges = [viewportRange]
            
        } // END performEditingTransaction
        
    }
    
    public func updateMetrics(with message: String) {
        
        if !self.editorMetrics.contains(message) {
            editorMetrics += message
        }
    }
    
    private func applyStyleForPattern(_ syntax: MarkdownSyntax, in range: NSTextRange) {
        
        guard let textContentStorage = self.textContentStorage else { return }
        //              let range = textContentStorage.range(for: range) else { return }
        
        guard let textStorage = textContentStorage.textStorage else { return }
        
        
        
        guard let regex = syntax.regex else { return }
        
        let string = textStorage.string
        let range = NSRange(location: 0, length: textStorage.length)
        //        let searchRange = NSIntersectionRange(range, NSRange(location: 0, length: textStorage.length))
        
        regex.enumerateMatches(in: string, options: [], range: range) { match, _, _ in
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
            
            // Apply attributes
            textStorage.setAttributes(syntax.syntaxAttributes, range: startSyntaxRange)
//            textStorage.addAttributes(syntax.syntaxAttributes, range: startSyntaxRange)
            textStorage.setAttributes(syntax.syntaxAttributes, range: endSyntaxRange)
            
            //            textStorage.removeAttribute(.backgroundColor, range: contentRange)
            textStorage.setAttributes(syntax.contentAttributes, range: contentRange)
            
            
        }
    }
    
    //        // Iterate through markdown patterns and apply styling
    //            for pattern in markdownPatterns {
    //                // Use NSTextContentManager to get the content in the range
    //                if let content = textContentStorage.textStorage?.attributedSubstring(from: range.location..<range.endLocation).string {
    //                    // Find matches in the content
    //                    let matches = pattern.regex.matches(in: content, range: NSRange(location: 0, length: content.utf16.count))
    //
    //                    for match in matches {
    //                        let matchRange = NSTextRange(location: range.location + match.range.location, length: match.range.length)
    //
    //                        // Apply attributes using performEditingTransaction
    //                        textContentStorage.performEditingTransaction {
    //                            textContentStorage.textStorage?.addAttributes(pattern.attributes, range: matchRange)
    //                        }
    //                    }
    //                }
    //            }
    //
    //
    //        let regex = try? NSRegularExpression(pattern: pattern, options: [])
    //        let text = textContentStorage.attributedString().string as NSString
    //
    //        regex?.enumerateMatches(in: text as String, options: [], range: nsRange) { match, _, _ in
    //            guard let match = match else { return }
    //            let matchRange = match.range(at: 1)
    //            if let textRange = textContentStorage.textRange(for: matchRange) {
    //                textContentStorage.addAttributes(attributes, range: textRange)
    //            }
    //        }
    //    }
    
    
    //    func applyMarkdownStyling() {
    //            guard let textContentStorage = self.textContentStorage else { return }
    //
    //            textContentStorage.performEditingTransaction {
    //                // Apply your markdown styling here
    //                // For example:
    //
    //                let visibleTextRange = self.visibleRange()
    //
    //                let fullRange = NSRange(location: 0, length: textContentStorage.attributedString()?.length)
    //                textContentStorage.addAttribute(.foregroundColor, value: NSColor.black, range: fullRange)
    //
    //                let bufferLength = 100
    //
    //                let extendedRange = NSRange(
    //                            location: max(0, visibleRange.location - bufferLength),
    //                            length: min(textStorage.length - max(0, visibleRange.location - bufferLength),
    //                                        visibleRange.length + 2 * bufferLength)
    //                        )
    //
    //
    //                // Apply bold styling
    //                let boldPattern = "\\*\\*(.*?)\\*\\*"
    //                if let regex = try? NSRegularExpression(pattern: boldPattern, options: []) {
    //                    let text = textContentStorage.attributedString().string
    //                    let matches = regex.matches(in: text, options: [], range: fullRange)
    //
    //                    for match in matches {
    //                        let boldRange = match.range(at: 1)
    //                        textContentStorage.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: 14), range: boldRange)
    //                    }
    //                }
    //            } // END performEditingTransaction
    //        }
    
    public override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        updateMarkdownStyling()
    }
    
    
}






extension MarkdownEditor {
    
    
    
    public override func didChangeText() {
        super.didChangeText()
        
        //        invalidateIntrinsicContentSize()
        
        self.editorHeight = self.textStorage?.size().height ?? .zero
        self.updateMarkdownStyling()
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





//import Cocoa

//extension MarkdownEditor {


//
//    func applyMarkdownStyling(in range: NSRange) {
//            guard let textContentManager = textLayoutManager?.textContentManager,
//                  let textRange = textContentManager.textRange(for: range) else { return }
//
//            // Example regex for bold markdown
//            let boldPattern = "\\*\\*(.*?)\\*\\*"
//
//            do {
//                let regex = try NSRegularExpression(pattern: boldPattern, options: [])
//                let text = textContentManager.attributedString().string as NSString
//
//                // Find matches in the specified range
//                let matches = regex.matches(in: text as String, options: [], range: range)
//
//                for match in matches {
//                    let boldRange = match.range(at: 1)
//
//                    // Apply bold attribute
//                    textContentManager.performEditingTransaction {
//                        if let boldTextRange = textContentManager.textRange(for: boldRange) {
//                            textContentManager.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: 14), range: boldTextRange)
//                        }
//                    }
//                }
//            } catch {
//                print("Error creating regex: \(error)")
//            }
//        }



//    func visibleRange() -> NSTextRange {
//        guard let textLayoutManager = self.textLayoutManager else { return }
//
//            let visibleRect = self.visibleRect
//            var visibleTextRange = NSTextRange(location: 0)
//
//            textLayoutManager.enumerateTextLayoutFragments(from: textLayoutManager.documentRange.location, options: [], using: { fragment in
//                if fragment.layoutFragmentFrame.intersects(visibleRect) {
//                    if let fragmentRange = fragment.textElement?.elementRange {
//                        visibleTextRange = visibleTextRange.union(fragmentRange)
//                    }
//                }
//                return fragment.layoutFragmentFrame.maxY > visibleRect.maxY
//            })
//
//            return visibleTextRange
//        }
//} // END extension

//extension NSTextContentManager {
//  func range(for textRange: NSTextRange) -> NSRange? {
//    let location = offset(from: documentRange.location, to: textRange.location)
//    let length = offset(from: textRange.location, to: textRange.endLocation)
//    if location == NSNotFound || length == NSNotFound { return nil }
//    return NSRange(location: location, length: length)
//  }
//
//  func textRange(for range: NSRange) -> NSTextRange? {
//    guard let textRangeLocation = location(documentRange.location, offsetBy: range.location),
//          let endLocation = location(textRangeLocation, offsetBy: range.length) else { return nil }
//    return NSTextRange(location: textRangeLocation, end: endLocation)
//  }
//}


/// To listen for a notificaiton when Text 2 has to switch to TextKit 1
//extension MarkdownEditor {
//    public class let willSwitchToNSLayoutManagerNotification: NSNotification.Name
//    public class let didSwitchToNSLayoutManagerNotification: NSNotification.Name
//}


#endif
