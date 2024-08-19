//
//  File.swift
//
//
//  Created by Dave Coleman on 11/8/2024.
//

import Foundation
import SwiftUI
import Testing

@testable import MarkdownEditor

@MainActor @Suite("MarkdownTextView tests")
struct MarkdownTextViewTests {
  
  @Test("Adding markdown content parses elements")
  func addingContentParsesElements() async throws {
    
    let textView = MarkdownTextView(frame: .zero, textContainer: nil)
    
    textView.string = """
    # Header
    
    This is **bold** text.
    """
    
    textView.setupViewportLayoutController()
    
    try await Task.sleep(for: .seconds(0.1))
    
    await textView.runMainMarkdownParse()
    
    print("Text: \(textView.string)")
    print("Elements: \(textView.elements)")
    
    #expect(!textView.elements.isEmpty)
    #expect(textView.elements.count == 2)
    #expect(textView.elements[0].type == .heading(level: 1))
    #expect(textView.elements[1].type == .bold(style: .asterisk))

  }
  
  
  
}
