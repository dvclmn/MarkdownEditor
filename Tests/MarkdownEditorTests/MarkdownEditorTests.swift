//
//  File.swift
//
//
//  Created by Dave Coleman on 11/8/2024.
//

import Foundation
import SwiftUI
import Testing
import BaseHelpers

@testable import MarkdownEditor


@MainActor @Suite("MarkdownTextView tests", .disabled())

struct MarkdownTextViewTests {
  
  let textView = MarkdownTextView(frame: .zero, textContainer: nil, configuration: .init())
  
  let exampleString = """
    # Header
    
    This is **bold** text.
    """
  let exampleString02 = "This has some **bold** text."
  
  
  
}









extension MarkdownTextViewTests {
  
  @Test("Finds markdown matches at all", .disabled())
  func findMarkdownMatches() async {
    
    guard let tcm = textView.textLayoutManager?.textContentManager else { return }
    
    textView.string = TestStrings.Markdown.anotherMarkdownString
    
    //    await textView.parseMarkdown()
    
    //    printCollection(textView.elements)
    
  }
  
}

