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
    var textHighlighter = TextHighlighter()
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
        
        self.textHighlighter.textStorage = textContentStorage?.textStorage
        
    }
    
    
    /// The `required init?(coder: NSCoder)` is necessary for classes that inherit from `NSView`
    /// (which `NSTextView` does). This initializer is used when the view is loaded from a storyboard or XIB file.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyParagraphStyles(range: NSRange) {
        
        guard let textStorage = self.textContentStorage?.textStorage else { return }
        
        let globalParagraphStyle = NSMutableParagraphStyle()
        globalParagraphStyle.lineSpacing = MarkdownDefaults.lineSpacing
        globalParagraphStyle.paragraphSpacing = MarkdownDefaults.paragraphSpacing
        
        //        let attributedString = NSMutableAttributedString(string: textStorage.string, attributes: baseStyles)
        
    }
    
    
    func updateMarkdownStyling() {
        
        guard let textContentStorage = self.textContentStorage,
              let textLayoutManager = self.textLayoutManager,
              let textContentManager = textLayoutManager.textContentManager,
              let textStorage = textContentStorage.textStorage,
              let documentRange: NSRange = textContentStorage.range(for: textContentManager.documentRange)
        else { return }
        
        textContentStorage.performEditingTransaction {
            
            let currentSelectedRange = self.selectedRange()
            
            let globalParagraphStyles = NSMutableParagraphStyle()
                    globalParagraphStyles.lineSpacing = MarkdownDefaults.lineSpacing
                    globalParagraphStyles.paragraphSpacing = MarkdownDefaults.paragraphSpacing
                    
                    let baseStyles: [NSAttributedString.Key : Any] = [
                        .font: NSFont.systemFont(ofSize: MarkdownDefaults.fontSize, weight: MarkdownDefaults.fontWeight),
                        .foregroundColor: NSColor.textColor.withAlphaComponent(MarkdownDefaults.fontOpacity),
                        .paragraphStyle: globalParagraphStyles
                    ]
            
            
            let attributedString = NSMutableAttributedString(string: textStorage.string, attributes: baseStyles)
            
            
            
            
            for syntax in MarkdownSyntax.allCases {
                
                //            styler.applyStyleForPattern(syntax, in: textContentStorage.documentRange, textContentManager: textContentManager, textStorage: textStorage)
                applyStyleForPattern(
                    syntax,
                    in: textContentManager.documentRange,
                    withString: attributedString
                )
            }
            
            self.setSelectedRange(currentSelectedRange)
            
            // Update last styled ranges
            //            lastStyledRanges = [viewportRange]
            
        } // END performEditingTransaction
    }
    
    
    private func applyStyleForPattern(
        _ syntax: MarkdownSyntax,
        in nsTextRange: NSTextRange,
        withString attributedString: NSMutableAttributedString
    ) {
        
        guard let textLayoutManager = self.textLayoutManager else { return }
        guard let textContentManager = textLayoutManager.textContentManager else { return }
        guard let textContentStorage = self.textContentStorage else { return }
        guard let textStorage = textContentStorage.textStorage else { return }
        
        guard let range = textContentManager.range(for: nsTextRange) else { return }
        
        guard let regex = syntax.regex else { return }
        
        guard let documentRange: NSRange = textContentStorage.range(for: textContentManager.documentRange) else { return }
        
        
        let syntaxCharacterCount: Int = syntax.syntaxCharacters.count
                let isSyntaxSymmetrical: Bool = syntax.isSyntaxSymmetrical
        
        regex.enumerateMatches(in: string, options: [], range: range) { match, _, _ in
            
            guard let match = match else { return }
            
            let matchRange = match.range
            
                        
                        
                        /// Content range
            let contentLocation: Int = max(range.location ,syntax == .codeBlock ?  range.location + syntaxCharacterCount + 1 : range.location + syntaxCharacterCount)
                        let contentLength = min(range.length - (isSyntaxSymmetrical ? 2 : 1) * syntaxCharacterCount, attributedString.length - contentLocation)
                        let contentRange = NSRange(location: contentLocation, length: contentLength)
                        
                        /// Opening syntax range
                        let startSyntaxLocation = range.location
                        let startSyntaxLength = min(syntax == .codeBlock ? syntaxCharacterCount + 1 : syntaxCharacterCount, attributedString.length - startSyntaxLocation)
                        let startSyntaxRange = NSRange(location: startSyntaxLocation, length: startSyntaxLength)
                        
                        /// Closing syntax range
                        let endSyntaxLocation = max(0, range.location + range.length - syntaxCharacterCount)
                        let endSyntaxLength = min(syntax == .codeBlock ? syntaxCharacterCount + 1 : syntaxCharacterCount, attributedString.length - endSyntaxLocation)
                        let endSyntaxRange = NSRange(location: endSyntaxLocation, length: endSyntaxLength)
                        
            
            
            textContentStorage.performEditingTransaction {
                
                
                
                        /// Apply attributes to opening and closing syntax
                        if attributedString.length >= startSyntaxRange.upperBound {

                            attributedString.addAttributes(syntax.syntaxAttributes, range: startSyntaxRange)
                        }
                        
                        if attributedString.length >= endSyntaxRange.upperBound {
                            attributedString.addAttributes(syntax.syntaxAttributes, range: endSyntaxRange)
                        }
                        
                        /// Apply attributes to content
                        if attributedString.length >= contentRange.upperBound {
                            attributedString.addAttributes(syntax.contentAttributes, range: contentRange)
                            
                            if syntax == .inlineCode {
                                
                                let userCodeColour: [NSAttributedString.Key : Any] = [
                                    .foregroundColor: NSColor(configuration.codeColour).withAlphaComponent(0.8),
                                ]
                                

                                
                                attributedString.addAttributes(userCodeColour, range: contentRange)
                            }
                        }
                        
                        if syntax == .codeBlock {
                            
                            if let highlightr = highlightr {
                                
                                highlightr.setTheme(to: "xcode-dark")
                                
                                highlightr.theme.setCodeFont(.monospacedSystemFont(ofSize: 14, weight: .medium))
                                
                                // Extract the substring for the code block
                                let codeString = attributedString.attributedSubstring(from: contentRange).string
                                
                                // Highlight the extracted code string
                                if let highlightedCode = highlightr.highlight(codeString, as: "swift") {
                                    
                                    //                        attributedString.replaceCharacters(in: contentRange, with: highlightedCode)
                                    textStorage.replaceCharacters(in: contentRange, with: highlightedCode)
                                    
                                    let codeBackground: [NSAttributedString.Key : Any] = [.backgroundColor: NSColor.black.withAlphaComponent(MarkdownDefaults.backgroundCodeBlock)]
                                    
                                    //                        attributedString.addAttributes(codeBackground, range: contentRange)
                                    attributedString.addAttributes(codeBackground, range: contentRange)
                                    
                                }
                            } // END highlighter check
                            
                        } // end code block check
            
            
            
            
//                
//                attributedString.addAttributes(syntax.syntaxAttributes, range: startSyntaxRange)
//                attributedString.addAttributes(syntax.syntaxAttributes, range: endSyntaxRange)
//                attributedString.addAttributes(syntax.contentAttributes, range: contentRange)
                
                //                textLayoutManager.addRenderingAttribute(.foregroundColor, value: NSColor.green, for: range)
                
                //                textStorage.removeAttribute(.backgroundColor, range: documentRange)
                
                // Apply attributes
                //                                textStorage.setAttributes(syntax.syntaxAttributes, range: startSyntaxRange)
                //            textStorage.addAttributes(syntax.syntaxAttributes, range: startSyntaxRange)
                //                textStorage.setAttributes(syntax.syntaxAttributes, range: endSyntaxRange)
                
                //            textStorage.removeAttribute(.backgroundColor, range: contentRange)
                
                
//                if syntax == .codeBlock {
//                    
//                    guard let highlightr = highlightr else { return }
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
//                        //                        textStorage.addAttribute(.paragraphStyle, value: globalParagraphStyles, range: range)
//                        
//                        //                        textStorage.addAttributes(codeBackground, range: contentRange)
//                        //                        textStorage.addAttributes(codeBackground, range: contentRange)
//                        
//                    }
//                    
                    
//                } // end code block check
                
                
                
//                textStorage.setAttributes(syntax.contentAttributes, range: contentRange)
                
//                textStorage.addAttributes(syntax.syntaxAttributes, range: startSyntaxRange)
//                textStorage.addAttributes(syntax.syntaxAttributes, range: endSyntaxRange)
                
                
                textStorage.setAttributedString(attributedString)
                
            } // END editing transaction
            
            
            
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
    
    
} // END markdown editor


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


#endif

