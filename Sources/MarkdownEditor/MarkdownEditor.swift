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
    var configuration: MarkdownEditorConfiguration
    var isShowingFrames: Bool
    var isShowingSyntax: Bool
    let highlightr = Highlightr()
    let styler = MarkdownStyleManager()
    var editorMetrics: String = ""
    var searchText: String
    
    init(
        frame: NSSize,
        editorHeight: CGFloat = .zero,
        configuration: MarkdownEditorConfiguration,
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
    }
    
    
    /// The `required init?(coder: NSCoder)` is necessary for classes that inherit from `NSView`
    /// (which `NSTextView` does). This initializer is used when the view is loaded from a storyboard or XIB file.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func updateMarkdownStyling() {
        
        guard let textContentStorage = self.textContentStorage,
              let textLayoutManager = self.textLayoutManager,
              let textContentManager = textLayoutManager.textContentManager,
              let textStorage = textContentStorage.textStorage,
              let visible = self.visibleRange()
        else { return }
        
        //        textContentStorage.performEditingTransaction {
        
        for syntax in MarkdownSyntax.allCases {
            
//            styler.applyStyleForPattern(syntax, in: textContentStorage.documentRange, textContentManager: textContentManager, textStorage: textStorage)
            applyStyleForPattern(syntax, in: visible)
        }
        
        // Update last styled ranges
        //            lastStyledRanges = [viewportRange]
        
        //        } // END performEditingTransaction
    }
    
    
    private func applyStyleForPattern(_ syntax: MarkdownSyntax, in range: NSTextRange) {
        
        guard let textLayoutManager = self.textLayoutManager else { return }
        guard let textContentManager = textLayoutManager.textContentManager else { return }
        guard let textContentStorage = self.textContentStorage else { return }
        guard let textStorage = textContentStorage.textStorage else { return }
        
        guard let nsRange = textContentManager.range(for: range) else { return }
        
        guard let regex = syntax.regex else { return }
        
        guard let documentRange: NSRange = textContentStorage.range(for: textContentManager.documentRange) else { return }
        

        
        
        
        regex.enumerateMatches(in: string, options: [], range: nsRange) { match, _, _ in
            
            guard let match = match else { return }
            
            let matchRange = match.range
            
            let contentRange = calculateRange(for: syntax, matchRange: matchRange, component: .content, in: string)
            
            let startSyntaxRange = calculateRange(for: syntax, matchRange: matchRange, component: .open, in: string)
            
            let endSyntaxRange = calculateRange(for: syntax, matchRange: matchRange, component: .close, in: string)
            
            
            
            textContentStorage.performEditingTransaction {
                
//                textLayoutManager.addRenderingAttribute(.foregroundColor, value: NSColor.green, for: range)
                
                //                textStorage.removeAttribute(.backgroundColor, range: documentRange)
                
                // Apply attributes
//                                textStorage.setAttributes(syntax.syntaxAttributes, range: startSyntaxRange)
                //            textStorage.addAttributes(syntax.syntaxAttributes, range: startSyntaxRange)
                //                textStorage.setAttributes(syntax.syntaxAttributes, range: endSyntaxRange)
                
                //            textStorage.removeAttribute(.backgroundColor, range: contentRange)
                                textStorage.setAttributes(syntax.contentAttributes, range: contentRange)
            }
            
        }
    } // END main styling thing

    
    public override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        self.updateMetrics(with: "`viewDidEndLiveResize`")
        updateMarkdownStyling()
    }
    
    private func calculateRange(
        for syntax: MarkdownSyntax,
        matchRange: NSRange,
        component: SyntaxComponent,
        in string: String
    ) -> NSRange {
        let syntaxCharacterCount = syntax.syntaxCharacterCount
        let isSyntaxSymmetrical = syntax.isSyntaxSymmetrical
        let isCodeBlock = syntax == .codeBlock
        
        let location: Int
        let length: Int
        
        switch component {
        case .open:
            location = matchRange.location
            length = isCodeBlock ? syntaxCharacterCount + 1 : syntaxCharacterCount
            
            
        case .content:
            location = isCodeBlock ? matchRange.location + syntaxCharacterCount + 1 : matchRange.location + syntaxCharacterCount
            length = matchRange.length - (isSyntaxSymmetrical ? 2 : 1) * syntaxCharacterCount
            
        case .close:
            location = matchRange.location + matchRange.length - syntaxCharacterCount
            length = isCodeBlock ? syntaxCharacterCount + 1 : syntaxCharacterCount
        }
        
        
        return NSRange(location: max(location, 0), length: min(length, string.count - location))
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



extension MarkdownEditor {
    
    public override func didChangeText() {
        super.didChangeText()
        
        //        invalidateIntrinsicContentSize()
        
        self.editorHeight = calculateEditorHeight()
        self.updateMarkdownStyling()
    }
    
    
    public func updateMetrics(with message: String) {
        
        if !self.editorMetrics.contains(message) {
            editorMetrics += message
        }
    }
    
    func calculateEditorHeight() -> CGFloat {
        
        let textStorageHeight: CGFloat = self.textStorage?.size().height ?? .zero
        let paddingHeight: CGFloat = self.configuration.paddingY * 2
        let extraForGoodMeasure: CGFloat = 40
        
        return textStorageHeight + paddingHeight + extraForGoodMeasure
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

} // END Markdown editor extension





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



    
//} // END extension




#endif

