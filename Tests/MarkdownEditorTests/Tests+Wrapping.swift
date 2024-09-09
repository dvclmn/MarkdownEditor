//
//  Wrapping.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 9/9/2024.
//

import Testing
import Foundation
import Shortcuts

@testable import MarkdownEditor

@MainActor @Suite("Wrapping tests")
struct WrappingTests {
  
  let textView = MarkdownTextView(frame: .zero, textContainer: nil, configuration: .init())
  
  let exampleString = """
    # Header
    
    This is **bold** text.
    """
  let exampleString02 = "This has some **bold** text."
  
  @Test("Wrap text with bold syntax")
  func testWrapBold() throws {
    // Setup
    textView.string = "Hello, world!"
    textView.setSelectedRange(NSRange(location: 0, length: 5))
    
    let boldSyntax = Markdown.Syntax.bold
    let boldShortcut = boldSyntax.shortcuts.first!
    
    // Execute
    textView.handleWrapping(.wrap, for: boldSyntax, shortcut: boldShortcut)
    
    // Verify
    #expect(textView.string == "**Hello**, world!")
    #expect(textView.selectedRange() == NSRange(location: 2, length: 5))
  }
  
  @Test("Wrap text with italic syntax")
  func testWrapItalic() throws {
    // Setup
    textView.string = "Hello, world!"
    textView.setSelectedRange(NSRange(location: 7, length: 5))
    
    let italicSyntax = Markdown.Syntax.italic
    let italicShortcut = Keyboard.Shortcut(.character("I"), modifierFlags: .command)
    
    // Execute
    textView.handleWrapping(.wrap, for: italicSyntax, shortcut: italicShortcut)
    
    // Verify
    #expect(textView.string == "Hello, *world*!")
    #expect(textView.selectedRange() == NSRange(location: 8, length: 5))
  }
  
  @Test("Wrap text with strikethrough syntax")
  func testWrapStrikethrough() throws {
    // Setup
    let originalString = "Hello, world!"
    textView.string = originalString
    let selectedRange = NSRange(location: 0, length: originalString.count)
    textView.setSelectedRange(selectedRange)
    
    let strikethroughSyntax = Markdown.Syntax.strikethrough
    let strikethroughShortcut = Keyboard.Shortcut(.character("S"), modifierFlags: [.command, .shift])
    
    // Pre-execution checks
    #expect(textView.string.count == originalString.count)
    #expect(textView.selectedRange() == selectedRange)
    
    print("Original string: \(textView.string)")
    print("Original selected range: \(textView.selectedRange())")
    
    // Execute
    textView.handleWrapping(.wrap, for: strikethroughSyntax, shortcut: strikethroughShortcut)
    
    // Post-execution checks
    let expectedWrappedString = "~~Hello, world!~~"
    let expectedWrappedRange = NSRange(location: 2, length: originalString.count)
    
    print("Resulting string: \(textView.string)")
    print("Resulting selected range: \(textView.selectedRange())")
    
    #expect(textView.string == expectedWrappedString)
    #expect(textView.selectedRange() == expectedWrappedRange)
  }

  @Test("Unwrap text with bold syntax")
  func testUnwrapBold() throws {
    // Setup
    textView.string = "Hello, **world**!"
    textView.setSelectedRange(NSRange(location: 8, length: 5))
    
    let boldSyntax = Markdown.Syntax.bold
    let boldShortcut = Keyboard.Shortcut(.character("B"), modifierFlags: .command)
    
    // Execute
    textView.handleWrapping(.unwrap, for: boldSyntax, shortcut: boldShortcut)
    
    // Verify
    #expect(textView.string == "Hello, world!")
    #expect(textView.selectedRange() == NSRange(location: 7, length: 5))
  }
  
  @Test("Wrap and unwrap with different syntaxes", arguments: [
    Markdown.Syntax.bold,
    Markdown.Syntax.italic,
    Markdown.Syntax.strikethrough,
    Markdown.Syntax.inlineCode
  ])
  func testWrapAndUnwrapWithSyntax(syntax: Markdown.Syntax) throws {
    // Setup
    let testString = "Test string"
    textView.string = testString
    textView.setSelectedRange(NSRange(location: 0, length: testString.count))
    
    let dummyShortcut = Keyboard.Shortcut(.character("X"), modifierFlags: .command)
    
    // Wrap
    textView.handleWrapping(.wrap, for: syntax, shortcut: dummyShortcut)
    
    let wrappedString = textView.string
    let wrappedRange = textView.selectedRange()
    
    #expect(
      wrappedString.hasPrefix(
        String(
          repeating: "\(syntax.leadingCharacter)" ?? "",
          count: syntax.leadingCharacterCount ?? 0
        )
      )
    )
    #expect(
      wrappedString.hasSuffix(
        String(
          repeating: "\(syntax.trailingCharacter)" ?? "",
          count: syntax.trailingCharacterCount ?? 0
        )
      )
    )
    #expect(wrappedRange.location == (syntax.leadingCharacterCount ?? 0))
    #expect(wrappedRange.length == testString.count)
    
    // Unwrap
    textView.handleWrapping(.unwrap, for: syntax, shortcut: dummyShortcut)
    
    #expect(textView.string == testString)
    #expect(textView.selectedRange() == NSRange(location: 0, length: testString.count))
  }
  
  
}
