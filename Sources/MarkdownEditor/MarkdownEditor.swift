//
//  MarkdownEditor.swift
//  Banksia
//
//  Created by Dave Coleman on 19/4/2024.
//

import Foundation
import SwiftUI
//import GeneralStyles
import Highlightr

class CopyButtonAttachment: NSTextAttachment {
    var range: NSRange
    
    init(range: NSRange) {
        self.range = range
        super.init(data: nil, ofType: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class MarkdownEditor: NSTextView {
    
    var editorHeight: CGFloat
    
    var editorMaxHeight: CGFloat?
    
    var editorHeightTypingBuffer: CGFloat
    
    var inlineCodeColour: Color
    
    var isShowingFrames: Bool
    
    let highlightr = Highlightr()
    
    init(
        frame frameRect: NSRect,
        editorHeight: CGFloat,
        editorMaxHeight: CGFloat?,
        editorHeightTypingBuffer: CGFloat,
        inlineCodeColour: Color,
        isShowingFrames: Bool
    ) {

        self.editorHeight = editorHeight
        self.editorMaxHeight = editorMaxHeight
        self.editorHeightTypingBuffer = editorHeightTypingBuffer
        self.inlineCodeColour = inlineCodeColour
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
    
    
    public override var intrinsicContentSize: NSSize {
        
        guard let layoutManager = self.layoutManager, let container = self.textContainer else {
            return super.intrinsicContentSize
        }
        container.containerSize = NSSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        layoutManager.ensureLayout(for: container)
        
        let rect = layoutManager.usedRect(for: container)
        
        print("NSTextView is editable?: \(self.isEditable)")
        
        let bufferHeight: CGFloat = self.isEditable ? editorHeightTypingBuffer : 0
        
        let contentSize = NSSize(width: NSView.noIntrinsicMetric, height: rect.height + bufferHeight)

        self.editorHeight = contentSize.height
        
        return contentSize
    }

   
    
    public func applyStyles() {
        
        guard let textStorage = self.textStorage else {
            print("Text storage not available for styling")
            return
        }
        
        let selectedRange = self.selectedRange()
        
        let globalParagraphStyles = NSMutableParagraphStyle()
        
        globalParagraphStyles.lineSpacing = 4
        
        globalParagraphStyles.paragraphSpacing = 0
        
        let baseStyles: [NSAttributedString.Key : Any] = [
            .font: NSFont.systemFont(ofSize: MarkdownDefaults.fontSize, weight: .medium),
            .foregroundColor: NSColor.textColor.withAlphaComponent(0.88),
            .paragraphStyle: globalParagraphStyles
        ]
        
        // MARK: - Set initial styles (First!)
        let attributedString = NSMutableAttributedString(string: textStorage.string, attributes: baseStyles)
        
        textStorage.setAttributedString(attributedString)
        
        let syntaxList = MarkdownSyntax.allCases
        
        for syntax in syntaxList {
            styleText(
                for: syntax,
                withString: attributedString
            )
        }
        self.setSelectedRange(selectedRange)
        
//        self.needsDisplay = true
        
        self.invalidateIntrinsicContentSize()
    }
    
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
            
            /// Paragraph range
            let paragraphLocation = max(0, range.location)
            let paragraphLength = min(range.length, attributedString.length)
            let paragraphRange = NSRange(location: paragraphLocation, length: paragraphLength)
            
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
                        .foregroundColor: NSColor(self.inlineCodeColour),
                    ]
                    
                    attributedString.addAttributes(userCodeColour, range: contentRange)
                }
            }
            
            if attributedString.length >= paragraphRange.upperBound {
                
                let paragraphStyles = NSMutableParagraphStyle()
                
                let paragraphAttributes: [NSMutableAttributedString.Key : Any] = [
                    .paragraphStyle: paragraphStyles
                ]
                
                attributedString.addAttributes(paragraphAttributes, range: paragraphRange)
                
                if syntax == .codeBlock {
                    
                    if let highlightr = highlightr {
                        
                        highlightr.setTheme(to: "tomorrow-night-eighties")

                        highlightr.theme.setCodeFont(.monospacedSystemFont(ofSize: 14, weight: .medium))
                        
                        // Extract the substring for the code block
                        let codeString = attributedString.attributedSubstring(from: contentRange).string
                        
                        // Highlight the extracted code string
                        if let highlightedCode = highlightr.highlight(codeString, as: "swift") {
                            
                            attributedString.replaceCharacters(in: contentRange, with: highlightedCode)
                            
                            let codeBackground: [NSAttributedString.Key : Any] = [.backgroundColor: NSColor.black.withAlphaComponent(MarkdownDefaults.backgroundAlphaAlt)]
                            
                            attributedString.addAttributes(codeBackground, range: contentRange)
                            
                            
                        }
                    } // END highlighter check

                } // end code block check
                
            } // END paragraph styles
            
        } // Loop over matches
        
        textStorage.setAttributedString(attributedString)
        
    } // END style text
    
    /// This really seems to be vital to styling the text. Have to keep this
    public override func didChangeText() {
        super.didChangeText()
        applyStyles()
    }
    
    
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
