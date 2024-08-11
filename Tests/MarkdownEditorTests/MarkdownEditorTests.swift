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
//final class MarkdownEditorTests: XCTestCase {
//  func testMarkdownStyling() {
//    // Your test code here
//  }
//  
//  func testTextWrapping() {
//    // Your test code here
//  }
//  
//  // Add more test methods as needed
//}
//
//class MarkdownStylerTests: XCTestCase {
//  var styler: MarkdownStyler!
//  
//  override func setUpWithError() throws {
//    styler = MarkdownStyler()
//  }
//  
//  func testBoldStyling() {
//    let input = "This is **bold** text"
//    let attributes = styler.style(input)
//    
//    XCTAssertEqual(attributes.count, 3)
//    XCTAssertTrue(attributes[1].attributes.contains { $0.key == .font && ($0.value as? NSFont)?.fontDescriptor.symbolicTraits.contains(.bold) == true })
//  }
//  
//  func testItalicStyling() {
//    let input = "This is *italic* text"
//    let attributes = styler.style(input)
//    
//    XCTAssertEqual(attributes.count, 3)
//    XCTAssertTrue(attributes[1].attributes.contains { $0.key == .font && ($0.value as? NSFont)?.fontDescriptor.symbolicTraits.contains(.italic) == true })
//  }
//  
//  func testWrappingConfig() {
//    let config = WrappingConfig(syntax: .inlineCode, triggerKey: "`", shortcut: AppKitKeyboardShortcut("e", modifiers: .command))
//    
//    XCTAssertEqual(config.syntax, .inlineCode)
//    XCTAssertEqual(config.triggerKey, "`")
//    XCTAssertEqual(config.shortcut?.key, "e")
//    XCTAssertEqual(config.shortcut?.modifiers, .command)
//  }
//}
