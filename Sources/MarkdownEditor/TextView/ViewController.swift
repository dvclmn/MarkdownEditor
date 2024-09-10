//
//  ViewController.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 6/9/2024.
//

import AppKit

import Neon
import TreeSitterMarkdown
import TreeSitterMarkdownInline
import SwiftTreeSitter
import TreeSitterClient

public class MarkdownViewController: NSViewController {
  
  var textView: MarkdownTextView
  var scrollView: NSScrollView
  
  init(
    configuration: MarkdownEditorConfiguration
  ) {
    
    self.textView = MarkdownTextView(
      frame: .zero,
      textContainer: nil,
      configuration: configuration
    )
    
    self.scrollView = NSScrollView()
    
//    do {
//      self.highlighter = try Self.makeHighlighter(for: textView)
//      print("`TextViewHighlighter` is running.")
      super.init(nibName: nil, bundle: nil)
//    } catch {
//      fatalError("Error setting up the highlighter: \(error)")
//    }
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func loadView() {

    do {
      try self.neonSetup()
    } catch {
      print("Error with Neon: \(error)")
    }
    
    setUpScrollView()
    self.view = textView.scrollView
    assert(self.textView.enclosingScrollView != nil, "I need the textView to have a scrollview.")
    
  }
  
  func neonSetup() throws {
    
    let languageConfig = try LanguageConfiguration(
      tree_sitter_markdown(),
      name: "Markdown"
    )
    
    let clientConfig = TreeSitterClient.Configuration(
      languageProvider: { identifier in
        print("Nested languages? \(identifier)")
        return languageConfig
      },
      contentProvider: { [textView] length in
        
        print("contentProvider `length`: \(length.description)")
        
        return .init(string: textView.string)
      },
      lengthProvider: { [textView] in
        textView.string.utf16.count
        
      },
      invalidationHandler: { set in
        print("Invalidations: \(set)")
      },
      locationTransformer: { location in

        return nil
      }
    )
    
    let client = try TreeSitterClient(
      rootLanguageConfig: languageConfig,
      configuration: clientConfig
    )
    
    let source = textView.string
    
    let provider = source.predicateTextProvider
    
    Task { @MainActor in
      
      let highlights = try await client.highlights(in: textView.visibleTextRange, provider: provider)

      print("Highlights: ", highlights)
    }

  }
  
}
