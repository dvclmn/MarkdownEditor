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
    
    private var lastStyledRanges: [NSRange] = []
    
//    private var styler: MarkdownStyler
    
    var searchText: String
    
//    private var syntaxList: [MarkdownSyntax] = [
//        .bold, .boldItalic, .italic, .codeBlock, .inlineCode
//    ]
    
    init(
        viewWidth: CGFloat,
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
        
//        self.styler = MarkdownStyler(textContentStorage: textContentStorage)
        
    }
    

    /// The `required init?(coder: NSCoder)` is necessary for classes that inherit from `NSView`
    /// (which `NSTextView` does). This initializer is used when the view is loaded from a storyboard or XIB file.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func applyMarkdownStyling() {
            guard let textContentStorage = self.textContentStorage else { return }
            
            textContentStorage.performEditingTransaction {
                // Apply your markdown styling here
                // For example:
                
                let visibleTextRange = self.visibleRange()
                
                let fullRange = NSRange(location: 0, length: textContentStorage.attributedString()?.length)
                textContentStorage.addAttribute(.foregroundColor, value: NSColor.black, range: fullRange)
                
                let bufferLength = 100
                
                let extendedRange = NSRange(
                            location: max(0, visibleRange.location - bufferLength),
                            length: min(textStorage.length - max(0, visibleRange.location - bufferLength),
                                        visibleRange.length + 2 * bufferLength)
                        )
                
                
                // Apply bold styling
                let boldPattern = "\\*\\*(.*?)\\*\\*"
                if let regex = try? NSRegularExpression(pattern: boldPattern, options: []) {
                    let text = textContentStorage.attributedString().string
                    let matches = regex.matches(in: text, options: [], range: fullRange)
                    
                    for match in matches {
                        let boldRange = match.range(at: 1)
                        textContentStorage.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: 14), range: boldRange)
                    }
                }
            } // END performEditingTransaction
        }
    

    
//    public func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
//        if editedMask.contains(.editedCharacters) {
//            
//            //            os_log("Applied styles. Executed from within `func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int)`")
//            let extendedRange = NSUnionRange(editedRange, textStorage.editedRange)
//            
//            applyStyles(to: extendedRange)
//            
//        }
//    }
    


}






extension MarkdownEditor {

    public override func didChangeText() {
        super.didChangeText()
        invalidateIntrinsicContentSize()
        self.editorHeight = intrinsicContentSize.height
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
}

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


