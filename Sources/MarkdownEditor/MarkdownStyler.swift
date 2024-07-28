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
    weak var textStorage: NSTextStorage?

    init(textStorage: NSTextStorage) {
        self.textStorage = textStorage
    }

    func applyStyles(to range: NSRange) {
        styleTimer?.invalidate()
        styleTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
            self?.performStyling(in: range)
        }
    }

    private func performStyling(in range: NSRange) {
        guard let textStorage = self.textStorage else { return }
        let newText = textStorage.string

        textStorage.beginEditing()

        for syntax in MarkdownSyntax.allCases {
            if shouldApplyStyle(for: syntax, in: range, oldText: lastText, newText: newText) {
                styleText(for: syntax, in: range)
            }
        }

        textStorage.endEditing()
        lastText = newText
    }

    private func shouldApplyStyle(for syntax: MarkdownSyntax, in range: NSRange, oldText: String, newText: String) -> Bool {
        // Implement quick checks here based on syntax type
        // Return true if the style should be applied
    }

    private func styleText(for syntax: MarkdownSyntax, in range: NSRange) {
        // Move your existing styleText logic here
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

    override func processEditing() {
        let editedRange = self.editedRange
        super.processEditing()
        styler?.applyStyles(to: editedRange)
    }

    func setStyler(_ styler: MarkdownStyler) {
        self.styler = styler
    }
}

