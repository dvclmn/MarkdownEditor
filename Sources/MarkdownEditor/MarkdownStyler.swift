//
//  File.swift
//
//
//  Created by Dave Coleman on 28/7/2024.
//

import SwiftUI


@MainActor
class MarkdownStyleManager {
    
    private var previouslyStyledRanges: [MarkdownSyntax: [NSRange]] = [:]
    
    func applyStyleForPattern(_ syntax: MarkdownSyntax, in range: NSTextRange, textContentManager: NSTextContentManager, textStorage: NSTextStorage) {
        
        guard let nsRange = textContentManager.range(for: range),
              let documentRange: NSRange = textContentManager.range(for: textContentManager.documentRange) else { return }
        
        let string = textStorage.string
        guard let regex = syntax.regex else { return }
        
        // Find new matches
        let matches = regex.matches(in: string, options: [], range: nsRange)
        let newMatchRanges = matches.map { $0.range }
        
        // Get previously styled ranges for this syntax
        let oldMatchRanges = previouslyStyledRanges[syntax] ?? []
        
        // Find ranges to unstyle (old ranges that are not in new ranges)
        let rangesToUnstyle = oldMatchRanges.filter { oldRange in
            !newMatchRanges.contains { newRange in
                
                let intersection = NSIntersectionRange(oldRange, newRange)
                return intersection.length == 0
                
            }
        }
        
        
        // Remove style from ranges no longer matching
        for rangeToUnstyle in rangesToUnstyle {
            let intersection = rangeToUnstyle.intersection(documentRange)
            if let validRange = intersection {
                textStorage.removeAttribute(.backgroundColor, range: validRange)
                // Remove any other attributes specific to this syntax
            }
        }
        
        // Apply style to new matches
        for match in matches {
            let matchRange = match.range
            let contentRange = NSRange(location: matchRange.location + syntax.syntaxCharacterCount,
                                       length: matchRange.length - 2 * syntax.syntaxCharacterCount)
            
            textStorage.setAttributes(syntax.contentAttributes, range: contentRange)
        }
        
        // Update previously styled ranges
        previouslyStyledRanges[syntax] = newMatchRanges
    }
}



//class CustomBackgroundTextLayoutFragment: NSTextLayoutFragment {
//    
//    override func draw(at point: CGPoint, in context: CGContext) {
//        // Draw the custom background
//        guard let textLayoutManager = textLayoutManager,
//           let textContentManager = textLayoutManager.textContentManager else { return }
//
//            
//            textContentManager.enumerateAttribute(.backgroundColor, in: textRange, options: []) { (value, range, stop) in
//                guard let color = value as? NSColor else { return }
//                
//                if let fragmentRange = range.intersection(textRange) {
//                    let rects = self.rects(forTextRange: fragmentRange)
//                    
//                    context.saveGState()
//                    context.setFillColor(color.cgColor)
//                    for rect in rects {
//                        var adjustedRect = rect
//                        adjustedRect.origin.x += point.x
//                        adjustedRect.origin.y += point.y
//                        context.fill(adjustedRect)
//                    }
//                    context.restoreGState()
//                }
//            }
//        
//        
//        // Draw the text
//        super.draw(at: point, in: context)
//    }
//}

//
//
//class CustomBackgroundTextLayoutFragment: NSTextLayoutFragment {
//    override func draw(at point: CGPoint, in context: CGContext) {
//        // Draw the custom background
//        if let textLayoutManager = textLayoutManager,
//           let textContent = textLayoutManager.textContentManager?.textElement(for: rangeInElement) as? NSTextStorage {
//            
//            textContent.enumerateAttribute(.backgroundColor, in: rangeInElement, options: []) { (value, range, stop) in
//                guard let color = value as? NSColor else { return }
//                
//                let fragmentRange = NSRange(location: range.location - rangeInElement.location, length: range.length)
//                let rects = self.rects(forTextRange: fragmentRange)
//                
//                context.saveGState()
//                context.setFillColor(color.cgColor)
//                for rect in rects {
//                    var adjustedRect = rect
//                    adjustedRect.origin.x += point.x
//                    adjustedRect.origin.y += point.y
//                    context.fill(adjustedRect)
//                }
//                context.restoreGState()
//            }
//        }
//        
//        // Draw the text
//        super.draw(at: point, in: context)
//    }
//}


//class CustomBackgroundTextLayoutManager: NSTextLayoutManager {
//    override func textLayoutFragment(for location: NSTextLocation) -> NSTextLayoutFragment {
//        return CustomBackgroundTextLayoutFragment(range: documentRange)
//    }
//}

//class CustomBackgroundTextLayoutManager: NSTextLayoutManager {
//    override func textLayoutFragment(for location: NSTextLocation) -> NSTextLayoutFragment {
//        let fragment = CustomBackgroundTextLayoutFragment(range: self.documentRange)
//        fragment.textLayoutManager = self
//        return fragment
//    }
//}



//@MainActor
//class MarkdownStyler {
//    private var lastText: String = ""
//    private var styleTimer: Timer?
//    weak var textContentStorage: NSTextContentStorage?
//    
//    init(textContentStorage: NSTextContentStorage) {
//        self.textContentStorage = textContentStorage
//    }
//    
//    func applyStyles(to range: NSRange) {
//        styleTimer?.invalidate()
//        styleTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
//            DispatchQueue.main.async {
//                self?.performStyling(in: range)
//            }
//        }
//    }
//    
//    private func performStyling(in range: NSRange) {
//        guard let textContentStorage = self.textContentStorage else { return }
//        
//        textContentStorage.performEditingTransaction {
//            
//            guard let newText = textContentStorage.attributedString?.string else {
//                return
//            }
//            
//            for syntax in MarkdownSyntax.allCases {
//                if shouldApplyStyle(for: syntax, in: range, oldText: lastText, newText: newText) {
//                    styleText(for: syntax, in: range)
//                }
//            }
//            
//            lastText = newText
//        }
//    }
//    
//    
//    private func shouldApplyStyle(for syntax: MarkdownSyntax, in range: NSRange, oldText: String, newText: String) -> Bool {
//        // Implement quick checks here based on syntax type
//        // Return true if the style should be applied
//        
//        return true
//    }
//    
//    private func styleText(for syntax: MarkdownSyntax, in range: NSRange) {
//        guard let textContentStorage = self.textContentStorage else { return }
//        
//        // Your styling logic here
//        // Use textContentStorage.attributedString to apply attributes
//    }
//    
//    
//}
//
//
//class MarkdownTextStorage: NSTextStorage {
//    private var backingStore = NSMutableAttributedString()
//    private var styler: MarkdownStyler?
//    
//    override var string: String {
//        return backingStore.string
//    }
//    
//    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
//        return backingStore.attributes(at: location, effectiveRange: range)
//    }
//    
//    override func replaceCharacters(in range: NSRange, with str: String) {
//        beginEditing()
//        backingStore.replaceCharacters(in: range, with: str)
//        edited(.editedCharacters, range: range, changeInLength: str.count - range.length)
//        endEditing()
//    }
//    
//    override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
//        beginEditing()
//        backingStore.setAttributes(attrs, range: range)
//        edited(.editedAttributes, range: range, changeInLength: 0)
//        endEditing()
//    }
//    
//    @MainActor override func processEditing() {
//        let editedRange = self.editedRange
//        super.processEditing()
//        styler?.applyStyles(to: editedRange)
//    }
//    
//    func setStyler(_ styler: MarkdownStyler) {
//        self.styler = styler
//    }
//}
//
