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
import TreeSitterSwift
import TreeSitterClient
import MarkdownModels

public class MarkdownViewController: NSViewController {
  
  let configuration: MarkdownEditorConfiguration
  var textView: MarkdownTextView
  
  init(
    configuration: MarkdownEditorConfiguration
  ) {
    self.configuration = configuration
    
    self.textView = MarkdownTextView(
      frame: .zero,
      textContainer: nil,
      configuration: configuration
    )
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  public override func loadView() {
    
    let scrollView = NSScrollView()
    
    scrollView.hasVerticalScroller = true
    scrollView.documentView = textView
    scrollView.drawsBackground = false
    scrollView.additionalSafeAreaInsets.bottom =
    configuration.bottomSafeArea
    
    let max = CGFloat.greatestFiniteMagnitude
    
    textView.minSize = NSSize.zero
    textView.maxSize = NSSize(width: max, height: max)
    textView.isVerticallyResizable = true
    textView.isHorizontallyResizable = true
    
    textView.isRichText = false  // Discards any attributes when pasting.
    
    self.view = scrollView
    
    if let highlighter = highlighter {
      highlighter.observeEnclosingScrollView()
    }
    
  }
  
  
}

enum NeonConfiguration {
  case textViewHighlighter
  case manual // Not yet implemented
  case none
}
