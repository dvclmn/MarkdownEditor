//
//  ViewController.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 6/9/2024.
//

import AppKit

//import Neon
//import TreeSitterMarkdown
//import TreeSitterMarkdownInline
//import SwiftTreeSitter
//import TreeSitterClient

public class MarkdownViewController: NSViewController {
  
  var textView: MarkdownTextView
  
//  private let highlighter: TextViewHighlighter
  
  init(
    configuration: MarkdownEditorConfiguration
  ) {
    
    self.textView = MarkdownTextView(
      frame: .zero,
      textContainer: nil,
      configuration: configuration
    )
    
    if configuration.isScrollable {
      
      let scrollView = NSScrollView()
      
      scrollView.hasVerticalScroller = true
      scrollView.drawsBackground = false
      scrollView.documentView = textView
      scrollView.additionalSafeAreaInsets.bottom = 40
      
      scrollView.documentView = textView
      
    } else {
      print("No scrolling needed, did not set up NSScrollView.")
    }
    
    
          super.init(nibName: nil, bundle: nil)
//    do {
//      self.highlighter = try Self.makeHighlighter(for: textView)
//      print("`TextViewHighlighter` is running.")
//      super.init(nibName: nil, bundle: nil)
//    } catch {
//      fatalError("Error setting up the highlighter: \(error)")
//    }
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func loadView() {

//    do {
//      try self.neonSetup()
//    } catch {
//      print("Error with Neon: \(error)")
//    }
    
    if let scrollview = textView.scrollView {
      self.view = scrollview
    } else {
      self.view = textView
    }
    
//    highlighter.observeEnclosingScrollView()
    
  }
  
  
}
