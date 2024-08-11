////
////  File.swift
////  
////
////  Created by Dave Coleman on 11/8/2024.
////
//
//import SwiftUI
//import XCTest
//@testable import MarkdownEditor
//
////class HighlightedTextEditorTests: XCTestCase {
////  var editor: MarkdownEditor!
////  
////  override func setUpWithError() throws {
////    editor = MarkdownEditor(text: .constant("Test"))
////  }
////  
////  func testMakeNSView() {
////    let context = NSViewRepresentableContext<MarkdownEditor>(coordinator: editor.makeCoordinator())
////    let view = editor.makeNSView(context: context)
////    
////    XCTAssertTrue(view is MarkdownView)
////    XCTAssertNotNil((view as? MarkdownView)?.textView)
////    // Add more assertions based on your setup
////  }
////  
////  func testUpdateNSView() {
////    let context = NSViewRepresentableContext<HighlightedTextEditor>(coordinator: editor.makeCoordinator())
////    let view = editor.makeNSView(context: context)
////    
////    editor.updateNSView(view, context: context)
////    
////    XCTAssertEqual((view as? MarkdownView)?.textView.string, "Test")
////    // Add more assertions based on your update logic
////  }
////}
//
//final class HighlightedTextEditorTests: XCTestCase {
//  var editor: MarkdownEditor!
//  
//  override func setUp() {
//    super.setUp()
//    editor = MarkdownEditor(text: .constant("Test"))
//  }
//  
//  func testHighlightRulesApplication() {
//    let rules = [
//      HighlightRule(pattern: "Test", formattingRule: .init([.foregroundColor: NSColor.red]))
//    ]
//    editor = HighlightedTextEditor(text: .constant("Test text"), highlightRules: rules)
//    
//    let attributes = editor.applyHighlightRules(to: "Test text")
//    
//    XCTAssertEqual(attributes.count, 2)
//    XCTAssertEqual(attributes[0].range, NSRange(location: 0, length: 4))
//    XCTAssertEqual(attributes[0].attributes[.foregroundColor] as? NSColor, .red)
//  }
//  
//  func testWrappingLogic() {
//    let config = WrappingConfig(syntax: .inlineCode, triggerKey: "`", shortcut: nil)
//    let result = editor.wrapText("some code", with: config)
//    
//    XCTAssertEqual(result, "`some code`")
//  }
//}
