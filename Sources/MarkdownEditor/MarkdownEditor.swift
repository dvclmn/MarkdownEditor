//
//  MarkdownEditor.swift
//  Banksia
//
//  Created by Dave Coleman on 19/4/2024.
//

import Foundation
import SwiftUI
import Highlightr
import OSLog

/// Help with NSTextViews:
/// https://developer.apple.com/library/archive/documentation/TextFonts/Conceptual/CocoaTextArchitecture/TextEditing/TextEditing.html#//apple_ref/doc/uid/TP40009459-CH3-SW16
/// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/TextLayout/TextLayout.html#//apple_ref/doc/uid/10000158i

@MainActor
public class MarkdownEditor: NSTextView {
    
    var editorHeight: CGFloat = .zero
    
    var configuration: MarkdownEditorConfiguration?
    
    var isShowingFrames: Bool
    
    let highlightr = Highlightr()
    
    
    init(
        frame frameRect: NSRect,
        configuration: MarkdownEditorConfiguration? = nil,
        isShowingFrames: Bool
    ) {
        self.configuration = configuration
        self.isShowingFrames = isShowingFrames
        
        let textStorage = NSTextStorage()
        let layoutManager = NSLayoutManager()
        
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size: CGSize(width: frameRect.width, height: CGFloat.greatestFiniteMagnitude))
        
        layoutManager.addTextContainer(textContainer)
        
        super.init(frame: frameRect, textContainer: textContainer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func handleRawText() {
        
    }
    
    func applyParagraphStyles() {
        
        guard let textStorage = self.textStorage else {
            print("Text storage not available for styling")
            return
        }
        
        let globalParagraphStyles = NSMutableParagraphStyle()
        globalParagraphStyles.lineSpacing = MarkdownDefaults.lineSpacing
        globalParagraphStyles.paragraphSpacing = MarkdownDefaults.paragraphSpacing
        
        let baseStyles: [NSAttributedString.Key : Any] = [
            .font: NSFont.systemFont(ofSize: MarkdownDefaults.fontSize, weight: MarkdownDefaults.fontWeight),
            .foregroundColor: NSColor.textColor.withAlphaComponent(MarkdownDefaults.fontOpacity),
            .paragraphStyle: globalParagraphStyles
        ]
        
        let attributedString = NSMutableAttributedString(string: textStorage.string, attributes: baseStyles)
        
        textStorage.setAttributedString(attributedString)
        
    }
    
    func applyStyles() {
        
        guard let textStorage = self.textStorage else {
            print("Text storage not available for styling")
            return
        }
        
        
        let currentSelectedRange = self.selectedRange()
        
        
        let attributedString = NSMutableAttributedString(string: textStorage.string)
        
        
        let syntaxList = MarkdownSyntax.allCases
        
        for syntax in syntaxList {
            styleText(
                for: syntax,
                withString: attributedString
            )
        }
        
//        textStorage.setAttributes(<#T##attrs: [NSAttributedString.Key : Any]?##[NSAttributedString.Key : Any]?#>, range: <#T##NSRange#>)
//        textStorage.setAttributedString(attributedString)
        self.setSelectedRange(currentSelectedRange)
        self.invalidateIntrinsicContentSize()
        self.needsDisplay = true
        
    }
    
    @MainActor
    public func styleText(
        for syntax: MarkdownSyntax,
        withString attributedString: NSMutableAttributedString
    ) {
        
        guard let textStorage = self.textStorage else {
            print("Text storage not available for styling")
            return
        }
        
        let regexLiteral: Regex<(Substring, Substring)> = syntax.regex
        
        let syntaxCharacterRanges: Int = syntax.syntaxCharacters.count
        let syntaxSymmetrical: Bool = syntax.syntaxSymmetrical
        
        let string = attributedString.string
        let matches = string.matches(of: regexLiteral)
        
        for match in matches {
            let range = NSRange(match.range, in: string)
            
            /// Content range
            let contentLocation = max(0, range.location + syntaxCharacterRanges)
            let contentLength = min(range.length - (syntaxSymmetrical ? 2 : 1) * syntaxCharacterRanges, attributedString.length - contentLocation)
            let contentRange = NSRange(location: contentLocation, length: contentLength)
            
            /// Opening syntax range
            let startSyntaxLocation = range.location
            let startSyntaxLength = min(syntaxCharacterRanges, attributedString.length - startSyntaxLocation)
            let startSyntaxRange = NSRange(location: startSyntaxLocation, length: startSyntaxLength)
            
            /// Closing syntax range
            let endSyntaxLocation = max(0, range.location + range.length - syntaxCharacterRanges)
            let endSyntaxLength = min(syntax == .codeBlock ? syntaxCharacterRanges + 1 : syntaxCharacterRanges, attributedString.length - endSyntaxLocation)
            let endSyntaxRange = NSRange(location: endSyntaxLocation, length: endSyntaxLength)
            
            /// Apply attributes to opening and closing syntax
            if attributedString.length >= startSyntaxRange.upperBound {
//                attributedString.addAttributes(syntax.syntaxAttributes, range: startSyntaxRange)
                textStorage.addAttributes(syntax.syntaxAttributes, range: startSyntaxRange)
            }
            
            if attributedString.length >= endSyntaxRange.upperBound {
//                attributedString.addAttributes(syntax.syntaxAttributes, range: endSyntaxRange)
                textStorage.addAttributes(syntax.syntaxAttributes, range: endSyntaxRange)
            }
            
            /// Apply attributes to content
            if attributedString.length >= contentRange.upperBound {
                attributedString.addAttributes(syntax.contentAttributes, range: contentRange)
                textStorage.addAttributes(syntax.contentAttributes, range: contentRange)
                
                if syntax == .inlineCode {
                    
                    let userCodeColour: [NSAttributedString.Key : Any] = [
                        .foregroundColor: NSColor(configuration?.defaultCodeColour ?? .white),
                    ]
                    
                    attributedString.addAttributes(userCodeColour, range: contentRange)
                    textStorage.addAttributes(userCodeColour, range: contentRange)
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
                        textStorage.addAttributes(codeBackground, range: contentRange)
                        
                    }
                } // END highlighter check
                
            } // end code block check
        } // Loop over matches
        
    } // END style text
    
    /// This really seems to be vital to styling the text. Have to keep this
    public override func didChangeText() {
        super.didChangeText()
        applyStyles()
    }
    
    public override var intrinsicContentSize: NSSize {
        
        guard let layoutManager = self.layoutManager, let container = self.textContainer else {
            return super.intrinsicContentSize
        }
        container.containerSize = NSSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        layoutManager.ensureLayout(for: container)
        
        let rect = layoutManager.usedRect(for: container)
        
//        let bufferHeight: CGFloat = 120
        let bufferHeight: CGFloat = self.isEditable ? 120 : 0
        let contentSize = NSSize(width: NSView.noIntrinsicMetric, height: rect.height + bufferHeight)
        
        self.editorHeight = contentSize.height
        
        return contentSize
    }
    
    /// Attempt to update the text layout when width changes
//    public override func viewDidMoveToSuperview() {
//        super.viewDidMoveToSuperview()
//        // Register for frame change notifications
//        NotificationCenter.default.addObserver(self, selector: #selector(frameDidChange), name: NSView.frameDidChangeNotification, object: self)
//    }
//    
//    deinit {
//        // Remove observer when the view is no longer in use
////        DispatchQueue.main.async {
//            NotificationCenter.default.removeObserver(self, name: NSView.frameDidChangeNotification, object: self)
////        }
//    }
//    
//    @objc private func frameDidChange(notification: Notification) {
//        // Invalidate intrinsic content size to trigger a layout update
//        self.invalidateIntrinsicContentSize()
//    }
    
    
}

extension MarkdownEditor {
    
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
