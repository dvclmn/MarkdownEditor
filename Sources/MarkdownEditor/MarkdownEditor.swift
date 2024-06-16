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
    
    //    var textBinding: Binding<String>?
    
    //    var isReadOnly: Bool = true
    
    var editorHeight: CGFloat
    
    var inlineCodeColour: Color
    
    var isShowingFrames: Bool = false
    
    //    var shouldAutocompleteForEmptySelection: Bool = false
    
    let highlightr = Highlightr()
    
    init(
        frame frameRect: NSRect,
        editorHeight: CGFloat,
        inlineCodeColour: Color,
        isShowingFrames: Bool
        //        shouldAutocompleteForEmptySelection: Bool
    ) {

        self.editorHeight = editorHeight
        self.inlineCodeColour = inlineCodeColour
        self.isShowingFrames = isShowingFrames
        //        self.shouldAutocompleteForEmptySelection = shouldAutocompleteForEmptySelection
        
        let textStorage = NSTextStorage()
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size: CGSize(width: frameRect.width, height: CGFloat.greatestFiniteMagnitude))
        
        layoutManager.addTextContainer(textContainer)
        
        super.init(frame: frameRect, textContainer: textContainer)
        
        // Additional setup here if needed
        self.isVerticallyResizable = true
        self.isHorizontallyResizable = true
        self.autoresizingMask = .width
        self.textContainerInset = CGSize(width: 10, height: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //    var copyButtons = [NSButton]()
    
    
    public override var intrinsicContentSize: NSSize {
        guard let layoutManager = self.layoutManager, let container = self.textContainer else {
            return super.intrinsicContentSize
        }
        container.containerSize = NSSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        layoutManager.ensureLayout(for: container)
        
        let rect = layoutManager.usedRect(for: container)
        
        let bufferHeight: CGFloat = isEditable ? 120 : 0
        
        let contentSize = NSSize(width: NSView.noIntrinsicMetric, height: rect.height + bufferHeight)
        
        self.editorHeight = contentSize.height
        
        /// Reminder: this print statement executes multiple times, because MarkdownEditor
        /// is being used not only as the app's editor, but also to display Single Messages
        print("This is the height from `NSTextView`: \(String(describing: editorHeight))")
        
        return contentSize
    }
    
    
    //    func createCopyButton() -> NSButton {
    //        let button = NSButton(frame: .zero)
    //        button.title = "Copy"
    //        button.bezelStyle = .rounded
    //        button.wantsLayer = true
    //        button.layer?.backgroundColor = NSColor.red.cgColor
    //        button.layer?.borderColor = NSColor.black.cgColor
    //        button.layer?.borderWidth = 2.0
    //        button.target = self
    //        button.action = #selector(copyText(_:))
    //        return button
    //    }
    
    //    func positionButtons() {
    //        removeAllCopyButtons()
    //        guard let layoutManager = layoutManager, let textContainer = textContainer else { return }
    //
    //        let regex: Regex<(Substring, Substring)> = MarkdownSyntax.codeBlock.regex
    //        let matches = string.matches(of: regex)
    //
    //        for match in matches {
    //            let glyphRange = NSRange(match.range, in: string)
    //            let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
    //
    //            let button = createCopyButton()
    //            button.frame = NSRect(x: boundingRect.minX - 110, y: boundingRect.minY, width: 100, height: 30)
    //
    //            self.addSubview(button)
    //            copyButtons.append(button)
    //        }
    //    }
    //
    //    func removeAllCopyButtons() {
    //        for button in copyButtons {
    //            button.removeFromSuperview()
    //        }
    //        copyButtons.removeAll()
    //    }
    //
    //    @objc func copyText(_ sender: NSButton) {
    //        // Implement copying logic here, possibly using sender to identify the text range
    //    }
    
    //    private func findCodeBlock() -> (Range<String.Index>, NSRect)? {
    //        guard let layoutManager = layoutManager, let textContainer = textContainer else { return nil }
    //
    //        let regex: Regex<(Substring, Substring)> = MarkdownSyntax.codeBlock.regex
    //
    //        let matches = string.matches(of: regex)
    //
    //        for match in matches {
    //            let glyphRange = NSRange(match.range, in: string)
    //            let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
    //            return (match.range, boundingRect)
    //
    //        }
    //        return nil
    //    }
    //
    
//    func drawCustomBackground(
//        in rect: NSRect,
//        for syntax: MarkdownSyntax,
//        paddingBase: CGFloat,
//        rounding: Double,
//        backgroundColor: NSColor
//    ) {
//        guard let layoutManager = layoutManager, let textContainer = textContainer else { return }
//        
//        let regex: Regex<(Substring, Substring)> = syntax.regex
//        
//        let matches = self.string.matches(of: regex)
//        
//        for match in matches {
//            
//            let glyphRange = NSRange(match.range, in: string)
//            
//            if syntax == .inlineCode {
//                
//                layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (lineRect, usedRect, textContainer, lineGlyphRange, stop) in
//                    
//                    let intersectionRange = NSIntersectionRange(lineGlyphRange, glyphRange)
//                    if intersectionRange.length > 0 {
//                        let boundingRect = layoutManager.boundingRect(forGlyphRange: intersectionRange, in: textContainer)
//                        
//                        let paddingLeft: CGFloat = paddingBase * 1.2
//                        let paddingRight: CGFloat = paddingBase * 1.2
//                        let paddingTop: CGFloat = paddingBase * 1.1
//                        let paddingBottom: CGFloat = 0
//                        
//                        var paddedRect = boundingRect
//                        paddedRect.origin.x -= paddingLeft
//                        paddedRect.origin.y -= paddingTop
//                        paddedRect.size.width += paddingLeft + paddingRight
//                        paddedRect.size.height += paddingTop + paddingBottom
//                        
//                        let path = NSBezierPath(roundedRect: paddedRect, xRadius: rounding, yRadius: rounding)
//                        backgroundColor.setFill()
//                        
//                        path.fill()
//                    }
//                }
//                
//            } else if syntax == .codeBlock {
//                
//                let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
//                
//                let paddingLeft: CGFloat = paddingBase * 1.2
//                let paddingRight: CGFloat = paddingBase * 1.2
//                let paddingTop: CGFloat = paddingBase * 1.1
//                let paddingBottom: CGFloat = 0
//                
//                var paddedRect = boundingRect
//                paddedRect.origin.x -= paddingLeft
//                paddedRect.origin.y -= paddingTop
//                paddedRect.size.width += paddingLeft + paddingRight
//                paddedRect.size.height += paddingTop + paddingBottom
//                
//                let path = NSBezierPath(roundedRect: paddedRect, xRadius: rounding, yRadius: rounding)
//                backgroundColor.setFill()
//                
//                path.fill()
//                
//            }
//            
//        }
//    }
    
    
//    public override func drawBackground(in rect: NSRect) {
//        
//        super.drawBackground(in: rect)
//        
//        let opacity: Double = 0.4
//        
//        drawCustomBackground(
//            in: rect,
//            for: .inlineCode,
//            paddingBase: 2,
//            rounding: 2,
//            backgroundColor: NSColor.black.withAlphaComponent(opacity)
//        )
//        
//        drawCustomBackground(
//            in: rect,
//            for: .codeBlock,
//            paddingBase: 10,
//            rounding: 4,
//            backgroundColor: NSColor.black.withAlphaComponent(opacity)
//        )
//    }
    
    //    public override func keyDown(with event: NSEvent) {
    //
    //        let wrappingSyntax: [String] = ["`", "*"]
    //
    //        guard let character = event.characters, wrappingSyntax.contains(character) else {
    //            super.keyDown(with: event)
    //            return
    //        }
    //
    //        let selectedRange = self.selectedRange()
    //
    //        if selectedRange.length > 0 || shouldAutocompleteForEmptySelection {
    //            let selectedText = (self.string as NSString).substring(with: selectedRange)
    //            let wrappedText = character + selectedText + character
    //
    //            // Prepare undo for this action
    //            undoManager?.registerUndo(withTarget: self) { target in
    //                target.replaceCharacters(in: NSRange(location: selectedRange.location, length: wrappedText.count), with: selectedText)
    //                target.setSelectedRange(selectedRange)
    //                self.applyStylesAndUpdateSwiftUI()
    //            }
    //            undoManager?.setActionName("Wrap with \(character)")
    //
    //            // Perform the text replacement
    //            self.replaceCharacters(in: selectedRange, with: wrappedText)
    //
    //            self.setSelectedRange(NSRange(location: selectedRange.location + 1, length: wrappedText.count - 2))
    //
    //            applyStylesAndUpdateSwiftUI()
    //
    //        } else {
    //            super.keyDown(with: event)
    //        }
    //    }
    
    //    func applyStylesAndUpdateSwiftUI() {
    //        self.applyStyles()
    //        textBinding?.wrappedValue = self.string
    //    }
    
    
    
    
    public func assessSelectedRange(_ selectedRange: NSRange) -> [MarkdownSyntax] {
        
        guard let textStorage = self.textStorage else {
            print("Text storage not available for styling")
            return []
        }
        
        let string = textStorage.string
        
        guard let range = Range(selectedRange, in: string) else {
            print("No range found")
            return []
        }
        
        var activeSyntaxTypes: [MarkdownSyntax] = []
        
        for syntax in MarkdownSyntax.allCases {
            
            let syntaxMatches = string.matches(of: syntax.regex)
            
            for match in syntaxMatches {
                
                if match.range.contains(range.lowerBound) {
                    print("Cursor is within \(syntax.name)")
                    activeSyntaxTypes.append(syntax)
                } else {
                    return []
                    //                        print("No reported selection matches for \(syntax.name)")
                }
            } // END match loop
            
        } // END loop markdown syntax
        
        return activeSyntaxTypes
        
    } // END assess selecred range
    
    public func applyStyles() {
        
        guard let textStorage = self.textStorage else {
            print("Text storage not available for styling")
            return
        }
        
        let selectedRange = self.selectedRange()
        
        let globalParagraphStyles = NSMutableParagraphStyle()
        
        globalParagraphStyles.lineSpacing = 4
        
        globalParagraphStyles.paragraphSpacing = 0
        
        //        globalParagraphStyles.firstLineHeadIndent = 40
        //        globalParagraphStyles.headIndent = 40
        //        globalParagraphStyles.tailIndent = -40
        
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
        
        self.needsDisplay = true
        
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
                
                if syntax == .codeBlock {
                    
                }
                
                attributedString.addAttributes(syntax.contentAttributes, range: contentRange)
                
                
                
            }
            
            
            
            if attributedString.length >= paragraphRange.upperBound {
                
                let paragraphStyles = NSMutableParagraphStyle()
                
                switch syntax {
                case .h1:
                    paragraphStyles.lineSpacing = 1
                    //                    paragraphStyles.headIndent = 26
                    paragraphStyles.paragraphSpacing = 12
                case .h2:
                    paragraphStyles.paragraphSpacing = 10
                case .h3:
                    paragraphStyles.paragraphSpacing = 10
                    
                case .codeBlock:
                    paragraphStyles.lineSpacing = 4
                    
                    
                    
                    //                    paragraphStyles.paragraphSpacingBefore = 20
                    //                    paragraphStyles.paragraphSpacing = 20
                    //                    paragraphStyles.headIndent = -40
                    //                    paragraphStyles.tailIndent = 80
                    
                    
                default:
                    paragraphStyles.lineSpacing = 4
                    paragraphStyles.firstLineHeadIndent = 80
                    paragraphStyles.headIndent = 80
                    paragraphStyles.tailIndent = -80
                }
                
                
                let paragraphAttributes: [NSMutableAttributedString.Key : Any] = [
                    .paragraphStyle: paragraphStyles
                ]
                
                
                //                let paragraphAtt = attributedString.attributedSubstring(from: paragraphRange).string
                //                attributedString.replaceCharacters(in: paragraphRange, with: paragraphAtt)
                
                attributedString.addAttributes(paragraphAttributes, range: paragraphRange)
                
                if syntax == .codeBlock {
                    
                    if let highlightr = highlightr {
                        
                        highlightr.setTheme(to: "tomorrow-night-eighties")
                        //                                    highlightr.setTheme(to: "paraiso-dark")
                        //                                    highlightr.setTheme(to: "atom-one-dark")
                        //                                    highlightr.setTheme(to: "atelier-plateau-dark")
                        
                        highlightr.theme.setCodeFont(.monospacedSystemFont(ofSize: 14, weight: .medium))
                        
                        // Extract the substring for the code block
                        let codeString = attributedString.attributedSubstring(from: contentRange).string
                        
                        // Highlight the extracted code string
                        if let highlightedCode = highlightr.highlight(codeString, as: "swift") {
                            
                            attributedString.replaceCharacters(in: contentRange, with: highlightedCode)
                            
                        }
                    }
                    
                    
                    
                    
                    
                    
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
