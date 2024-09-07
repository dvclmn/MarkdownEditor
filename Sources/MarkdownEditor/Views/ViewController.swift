//
//  ViewController.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 6/9/2024.
//

import AppKit


public class MarkdownViewController: NSViewController {
  
  var scrollView: MarkdownScrollView
  var textView: MarkdownTextView
  
  init(
    configuration: MarkdownEditorConfiguration
  ) {

    self.scrollView = MarkdownScrollView(frame: .zero, configuration: configuration)
    self.textView = self.scrollView.documentView as! MarkdownTextView
    
    super.init(nibName: nil, bundle: nil)
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  public override func loadView() {
    
    let max = CGFloat.greatestFiniteMagnitude
    
    textView.minSize = NSSize.zero
    textView.maxSize = NSSize(width: max, height: max)
    textView.isVerticallyResizable = true
    textView.isHorizontallyResizable = true
    
    self.view = scrollView
    
    assert(self.textView.enclosingScrollView != nil, "I need the textView to have a scrollview.")

  }
  
}
