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

public class MarkdownViewController: NSViewController {
  
  let configuration: MarkdownEditorConfiguration
  var textView: MarkdownTextView
  
  private let highlighter: TextViewHighlighter?
  
  init(
    configuration: MarkdownEditorConfiguration
  ) {
    self.configuration = configuration
    let scrollView = NSScrollView()
    
    self.textView = MarkdownTextView(
      frame: .zero,
      textContainer: nil,
      configuration: configuration
    )
    
    if configuration.neonConfig == .textViewHighlighter {
      do {
        self.highlighter = try Self.makeHighlighter(for: textView)
        print("`TextViewHighlighter` is running.")
        super.init(nibName: nil, bundle: nil)
      } catch {
        fatalError("Error setting up the highlighter: \(error)")
      }
    } else {
      
      self.highlighter = nil
      super.init(nibName: nil, bundle: nil)
    }
    
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
