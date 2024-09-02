//
//  MainView.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 17/8/2024.
//

import AppKit

public class MarkdownContainerView: NSView {
  let scrollView: MarkdownScrollView
  
  init(frame: NSRect, configuration: MarkdownEditorConfiguration) {
    
    let scrollView = MarkdownScrollView(frame: .zero, configuration: configuration)
    self.scrollView = scrollView
    
    super.init(frame: frame)
    
    setupViews()
  }

  
  
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupViews() {

    // Set up ScrollView and TextView
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(scrollView)

    // Make ScrollView the same size as this view
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
    
    // Make ScrollView transparent
    scrollView.drawsBackground = false
    
  }
  

}
