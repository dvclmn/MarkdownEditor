////
////  File.swift
////  
////
////  Created by Dave Coleman on 11/8/2024.
////
//
//import Foundation
//
//import XCTest
//@testable import MarkdownEditor
//
//
//final class PerformanceTests: XCTestCase {
//  func testStylingPerformance() {
//    let longText = String(repeating: "This is a **bold** and *italic* test. ", count: 1000)
//    let styler = MarkdownStyler()
//    
//    measure {
//      _ = styler.style(longText)
//    }
//  }
//}
//
//func testComplexMarkdownStyling() {
//  let input = "# Heading\n\nThis is **bold _and italic_** text with `inline code`."
//  let attributes = styler.style(input)
//  
//  // Assert the correct number of attribute runs
//  XCTAssertEqual(attributes.count, 6)
//  
//  // Check heading style
//  XCTAssertTrue(attributes[0].attributes.contains { $0.key == .font && ($0.value as? NSFont)?.pointSize == 24 })
//  
//  // Check bold and italic
//  XCTAssertTrue(attributes[3].attributes.contains { $0.key == .font && ($0.value as? NSFont)?.fontDescriptor.symbolicTraits.contains([.bold, .italic]) == true })
//  
//  // Check inline code
//  XCTAssertTrue(attributes[5].attributes.contains { $0.key == .font && ($0.value as? NSFont)?.fontName.contains("Menlo") == true })
//}
//
//func testTextWrapping() {
//  let editor = HighlightedTextEditor(text: .constant("test"), highlightRules: [])
//  
//  let wrappedBold = editor.wrapText("test", with: WrappingConfig(syntax: .bold, triggerKey: "**", shortcut: nil))
//  XCTAssertEqual(wrappedBold, "**test**")
//  
//  let wrappedItalic = editor.wrapText("test", with: WrappingConfig(syntax: .italic, triggerKey: "*", shortcut: nil))
//  XCTAssertEqual(wrappedItalic, "*test*")
//  
//  let wrappedCode = editor.wrapText("test", with: WrappingConfig(syntax: .inlineCode, triggerKey: "`", shortcut: nil))
//  XCTAssertEqual(wrappedCode, "`test`")
//}
//
//func testUndoRedo() {
//  let textView = NSTextView(frame: .zero)
//  let undoManager = UndoManager()
//  textView.undoManager = undoManager
//  
//  textView.string = "Initial text"
//  textView.replaceCharacters(in: NSRange(location: 0, length: 0), with: "New ")
//  
//  XCTAssertEqual(textView.string, "New Initial text")
//  
//  undoManager.undo()
//  XCTAssertEqual(textView.string, "Initial text")
//  
//  undoManager.redo()
//  XCTAssertEqual(textView.string, "New Initial text")
//}
//
//func testCustomKeyCommands() {
//  let editor = HighlightedTextEditor(text: .constant("test"), highlightRules: [])
//  let keyEvent = NSEvent.keyEvent(with: .keyDown, location: .zero, modifierFlags: .command, timestamp: 0, windowNumber: 0, context: nil, characters: "b", charactersIgnoringModifiers: "b", isARepeat: false, keyCode: 11)!
//  
//  let handled = editor.handleKeyEquivalent(keyEvent)
//  
//  XCTAssertTrue(handled)
//  // You might need to check the resulting text or state here, depending on what the key command does
//}
//
//func testSyntaxHighlighting() {
//  let rules = [
//    HighlightRule(pattern: "\\*\\*.*?\\*\\*", formattingRule: .init([.foregroundColor: NSColor.red])), // Bold
//    HighlightRule(pattern: "\\*.*?\\*", formattingRule: .init([.foregroundColor: NSColor.blue])), // Italic
//    HighlightRule(pattern: "`.*?`", formattingRule: .init([.foregroundColor: NSColor.green])) // Inline code
//  ]
//  
//  let editor = HighlightedTextEditor(text: .constant("This is **bold**, *italic*, and `code`"), highlightRules: rules)
//  
//  let attributes = editor.applyHighlightRules(to: "This is **bold**, *italic*, and `code`")
//  
//  XCTAssertEqual(attributes.count, 7)
//  XCTAssertEqual(attributes[1].attributes[.foregroundColor] as? NSColor, .red)
//  XCTAssertEqual(attributes[3].attributes[.foregroundColor] as? NSColor, .blue)
//  XCTAssertEqual(attributes[5].attributes[.foregroundColor] as? NSColor, .green)
//}
//
//func testTextInsertionAndDeletion() {
//  let textView = NSTextView(frame: .zero)
//  textView.string = "Initial text"
//  
//  // Test insertion
//  textView.replaceCharacters(in: NSRange(location: 7, length: 0), with: "new ")
//  XCTAssertEqual(textView.string, "Initial new text")
//  
//  // Test deletion
//  textView.replaceCharacters(in: NSRange(location: 8, length: 3), with: "")
//  XCTAssertEqual(textView.string, "Initial  text")
//}
//
//func testTextSelection() {
//  let textView = NSTextView(frame: .zero)
//  textView.string = "Select this text"
//  
//  textView.setSelectedRange(NSRange(location: 7, length: 4))
//  XCTAssertEqual(textView.selectedRange.location, 7)
//  XCTAssertEqual(textView.selectedRange.length, 4)
//  XCTAssertEqual(textView.selectedText(), "this")
//}
//
