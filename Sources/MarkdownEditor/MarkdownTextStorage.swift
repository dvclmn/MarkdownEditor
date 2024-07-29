//
//  MarkdownTextStorage.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 29/7/2024.
//

import SwiftUI


public class MarkdownTextStorage: NSTextStorage {
    
    private var backingStore = NSMutableAttributedString()
    private var styler: MarkdownStyleManager?
    
    public override var fixesAttributesLazily: Bool { true }
    
    public override var string: String {
        return backingStore.string
    }
    
    public override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        return backingStore.attributes(at: location, effectiveRange: range)
    }
    
    public override func replaceCharacters(in range: NSRange, with str: String) {
        beginEditing()
        backingStore.replaceCharacters(in: range, with: str)
        edited(.editedCharacters, range: range, changeInLength: (str as NSString).length - range.length)
        endEditing()
    }
    
    public override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        beginEditing()
        backingStore.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
    
//    @MainActor public override func processEditing() {
//        let editedRange = self.editedRange
//        super.processEditing()
//        styler?.applyStyles(to: editedRange)
//    }
}
