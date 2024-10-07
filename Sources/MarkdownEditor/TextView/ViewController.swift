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
import Highlightr


public class MarkdownViewController: NSViewController {
  
  var textView: MarkdownTextView
  
//  private let highlighter: TextViewHighlighter?
  
  init(
    configuration: MarkdownEditorConfiguration
  ) {
    
    guard let highlightr = Highlightr() else {
      fatalError("Why no Highlightr?")
    }
    
    if configuration.isTextKit2 {
      self.textView = MarkdownTextView(
        frame: .zero,
        textContainer: nil,
        configuration: configuration,
        highlightr: highlightr
      )
    } else {
      
      /// TextKit 1 setup
      let container = NSTextContainer()
      let textStorage = NSTextStorage()
      let layoutManager = NSLayoutManager()
      textStorage.addLayoutManager(layoutManager)
      
      layoutManager.addTextContainer(container)
      
      self.textView = MarkdownTextView(
        frame: .zero,
        textContainer: container,
        configuration: configuration,
        highlightr: highlightr
      )
      
    }
    
    
    if configuration.isScrollable {
      let scrollView = NSScrollView()
      
      scrollView.hasVerticalScroller = true
      scrollView.drawsBackground = false
      scrollView.documentView = textView
      scrollView.additionalSafeAreaInsets.bottom = configuration.bottomSafeArea
    } else {
//      print("No scroll view set up, text view is not editable, and scrolling is handled in SwiftUI.")
    }
    
    super.init(nibName: nil, bundle: nil)
    
//    if configuration.isNeonEnabled {
//      do {
//        self.highlighter = try Self.makeHighlighter(for: textView)
//        print("`TextViewHighlighter` is running.")
//        super.init(nibName: nil, bundle: nil)
//      } catch {
//        fatalError("Error setting up the highlighter: \(error)")
//      }
//    } else {
//      
//      self.highlighter = nil
//      
//      super.init(nibName: nil, bundle: nil)
//    }
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func loadView() {

    if let scrollView = textView.scrollView {
      self.view = scrollView
    } else {
      self.view = textView
    }
    
//    if let highlighter = highlighter {
//      highlighter.observeEnclosingScrollView()
//    }
    
  }
  
  
}
