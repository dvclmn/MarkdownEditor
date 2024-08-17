//
//  LanguageComboBox.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 17/8/2024.
//

import AppKit

@MainActor
class LanguageComboBox: NSComboBox, Sendable {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        completes = true
        isEditable = true
        
        // Customize appearance
        backgroundColor = NSColor.textBackgroundColor
        textColor = NSColor.labelColor
        
        // Add a border
        wantsLayer = true
        layer?.borderWidth = 1.0
        layer?.borderColor = NSColor.separatorColor.cgColor
        layer?.cornerRadius = 4.0
        
        // Set font
        font = NSFont.systemFont(ofSize: 12)
    }
}


extension MarkdownTextView {
  
  func showDropdownForCodeBlock(at range: NSTextRange) {
    guard let startLocation = textLayoutManager?.location(range.location, offsetBy: 0) else { return }
    
    // Get the position for the dropdown
//    let glyphIndex = textLayoutManager.glyphIndex(for: startLocation)
//    let glyphRect = textLayoutManager.boundingRect(forGlyphRange: NSRange(location: glyphIndex, length: 1))
    
    // Create and position the combo box
    let comboBox = LanguageComboBox(frame: NSRect(x: 5, y: 5, width: 150, height: 25))
    comboBox.addItems(withObjectValues: Language.allCases)
    
    // Add the combo box to the text view
    self.addSubview(comboBox)
    
    // Set up action for when an item is selected
    comboBox.target = self
    comboBox.action = #selector(languageSelected(_:))
  }
  
  @objc private func languageSelected(_ sender: NSComboBox) {
    guard let selectedLanguage = sender.objectValueOfSelectedItem as? String else { return }
    // Handle language selection (e.g., update the code block, apply syntax highlighting)
    print("Selected language: \(selectedLanguage)")
  }
}
