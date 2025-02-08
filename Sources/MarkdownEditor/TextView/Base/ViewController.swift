//
//  ViewController.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 6/9/2024.
//

import AppKit
import MarkdownModels

public class MarkdownViewController: NSViewController {
  
  let configuration: MarkdownEditorConfiguration
  var textView: MarkdownTextView
  
  init(
    configuration: MarkdownEditorConfiguration
  ) {
    self.configuration = configuration
    
    self.textView = MarkdownTextView()
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  public override func loadView() {
    self.view = textView
  }
  
}
