////
////  File.swift
////  
////
////  Created by Dave Coleman on 11/8/2024.
////
//
//import Foundation
//import XCTest
//@testable import MarkdownEditor
//
//
//class MockTextView: NSTextView {
//  var lastReplacementText: String?
//  var lastReplacementRange: NSRange?
//  
//  override func replaceCharacters(in range: NSRange, with string: String) {
//    lastReplacementText = string
//    lastReplacementRange = range
//    super.replaceCharacters(in: range, with: string)
//  }
//}
//
//final class TextViewDelegateTests: XCTestCase {
//  var delegate: YourTextViewDelegate!
//  var textView: MockTextView!
//  
//  override func setUp() {
//    super.setUp()
//    delegate = YourTextViewDelegate()
//    textView = MockTextView(frame: .zero)
//    textView.delegate = delegate
//  }
//  
//  func testAutoClosingBrackets() {
//    textView.string = ""
//    _ = delegate.textView(textView, doCommandBy: #selector(NSResponder.insertText(_:)))
//    textView.insertText("(", replacementRange: NSRange(location: 0, length: 0))
//    
//    XCTAssertEqual(textView.string, "()")
//    XCTAssertEqual(textView.selectedRange.location, 1)
//  }
//}
