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
  
  let editor: MarkdownEditor
  let coordinator: MarkdownEditor.Coordinator
  
  let nsView: MarkdownContainerView
  
  init() {
    
    let editor = MarkdownEditor(
      text: .constant("# Header\n\nThis is **bold** text."),
      configuration: .init()
    )
    let coordinator = MarkdownEditor.Coordinator(editor)
    let nsView = MarkdownContainerView(frame: .zero)
    
    nsView.scrollView.textView.delegate = coordinator
    nsView.scrollView.textView.textLayoutManager?.delegate = coordinator
    nsView.scrollView.textView.configuration = editor.configuration
    
    nsView.scrollView.textView.onInfoUpdate = { info in
      DispatchQueue.main.async { editor.info(info) }
    }
    
    self.editor = editor
    self.coordinator = coordinator
    self.nsView = nsView
    
  }
  
  
  @Test("Adding markdown content parses elements")
  func addingContentParsesElements() async throws {
    guard let textView = nsView.scrollView.textView else { return }
    
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
