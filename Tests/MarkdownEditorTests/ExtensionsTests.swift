//
//  Extensions.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 20/8/2024.
//

import Foundation
import SwiftUI
import Testing
import BaseHelpers

import Logging

@testable import MarkdownEditor




extension MarkdownTextViewTests {
  
  @Test("Finds markdown matches at all")
  func findMarkdownMatches() async {
    guard let tcm = textView.textLayoutManager?.textContentManager else { return }
    
    textView.string = TestStrings.Markdown.anotherMarkdownString
    
    await textView.parseMarkdown()
    
//    printCollection(textView.elements)

  }
  
}

@MainActor @Suite("Extension tests")
struct MarkdownExtensionTests {
  
  let exampleString = "This has some **bold** text."
  
//  
//  
//  
//  
//  
//  @Test("Correctly identifies markdown syntax", .disabled())
//  func stringExtensionIdentifiesMarkdown() async throws {
//    
//    let boldRegex = Markdown.Syntax.bold(style: .asterisk).regex
//    let italicRegex = Markdown.Syntax.italic(style: .asterisk).regex
//    
//    // Test bold syntax
//    if let boldMatch = exampleString.firstMatch(of: boldRegex) {
//      #expect(exampleString.isValidMarkdownElement(syntax: .bold(style: .asterisk), match: boldMatch))
//    } else {
//      Issue.record("Failed to find bold pattern in test string")
//    }
//    
//    // Test italic syntax (should fail as there's no italic in the example string)
//    if let italicMatch = exampleString.firstMatch(of: italicRegex) {
//      #expect(!exampleString.isValidMarkdownElement(syntax: .italic(style: .asterisk), match: italicMatch))
//    } else {
//      // This is expected as there's no italic in the string
//      #expect(true)
//    }
//    
//    // Test with a string that contains italic
//    let italicString = "This has some *italic* text."
//    
//    if let italicMatch = italicString.firstMatch(of: italicRegex) {
//      #expect(italicString.isValidMarkdownElement(syntax: .italic(style: .asterisk), match: italicMatch))
//    } else {
//      Issue.record("Failed to find italic pattern in test string")
//    }
//    
//  }
}
