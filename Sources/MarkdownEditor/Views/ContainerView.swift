//
//  MainView.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 17/8/2024.
//

import AppKit

public class MarkdownContainerView: NSView {
  var textView: MarkdownTextView
  let scrollView: MarkdownScrollView
  
  init(frame: NSRect, configuration: MarkdownEditorConfiguration) {
    
    let textView = MarkdownTextView(frame: .zero, textContainer: nil, configuration: configuration)
    self.textView = textView
    
    let scrollView = MarkdownScrollView(frame: .zero, configuration: configuration)
    self.scrollView = scrollView
    
    super.init(frame: frame)
    
    setupViews()
  }

  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupViews() {

    addSubview(scrollView)
    
    scrollView.hasVerticalScroller = true
    scrollView.hasHorizontalScroller = false
    scrollView.autohidesScrollers = true
    
    scrollView.documentView = textView
    
    scrollView.translatesAutoresizingMaskIntoConstraints = false

    scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    
    scrollView.drawsBackground = false

  }
  

}
