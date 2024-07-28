//
//  File.swift
//
//
//  Created by Dave Coleman on 28/7/2024.
//

import SwiftUI

@MainActor
class MarkdownStyler {
    private var lastText: String = ""
    private var styleTimer: Timer?
    weak var textContentStorage: NSTextContentStorage?
    
    init(textContentStorage: NSTextContentStorage) {
        self.textContentStorage = textContentStorage
    }
    
    func applyStyles(to range: NSRange) {
        styleTimer?.invalidate()
        styleTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.performStyling(in: range)
            }
        }
    }
    
    private func performStyling(in range: NSRange) {
        guard let textContentStorage = self.textContentStorage else { return }
        
        textContentStorage.performEditingTransaction {
            
            guard let newText = textContentStorage.attributedString?.string else {
                return
            }
            
            for syntax in MarkdownSyntax.allCases {
                if shouldApplyStyle(for: syntax, in: range, oldText: lastText, newText: newText) {
                    styleText(for: syntax, in: range)
                }
            }
            
            lastText = newText
        }
    }
    
    
    private func shouldApplyStyle(for syntax: MarkdownSyntax, in range: NSRange, oldText: String, newText: String) -> Bool {
        // Implement quick checks here based on syntax type
        // Return true if the style should be applied
        
        return true
    }
    
    private func styleText(for syntax: MarkdownSyntax, in range: NSRange) {
        guard let textContentStorage = self.textContentStorage else { return }
        
        // Your styling logic here
        // Use textContentStorage.attributedString to apply attributes
    }
    
    
}


class MarkdownTextStorage: NSTextStorage {
    private var backingStore = NSMutableAttributedString()
    private var styler: MarkdownStyler?
    
    override var string: String {
        return backingStore.string
    }
    
    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        return backingStore.attributes(at: location, effectiveRange: range)
    }
    
    override func replaceCharacters(in range: NSRange, with str: String) {
        beginEditing()
        backingStore.replaceCharacters(in: range, with: str)
        edited(.editedCharacters, range: range, changeInLength: str.count - range.length)
        endEditing()
    }
    
    override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        beginEditing()
        backingStore.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
    
    @MainActor override func processEditing() {
        let editedRange = self.editedRange
        super.processEditing()
        styler?.applyStyles(to: editedRange)
    }
    
    func setStyler(_ styler: MarkdownStyler) {
        self.styler = styler
    }
}

