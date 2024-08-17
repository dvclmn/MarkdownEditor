//
//  MainView.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 17/8/2024.
//

import AppKit

public class MarkdownContainerView: NSView {
  let scrollView: MarkdownScrollView
  let gridView: GridView
  
  override init(frame: NSRect) {
    
    let scrollView = MarkdownScrollView(frame: .zero)

    let gridView = GridView(frame: frame)
    
    self.scrollView = scrollView
    self.gridView = gridView
    
    super.init(frame: frame)
    
    setupViews()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupViews() {
    // Set up GridView
    gridView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(gridView)
    
    // Set up ScrollView and TextView
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(scrollView)
    
    gridView.gridColor = .lightGray.withAlphaComponent(0.3)
    gridView.gridSpacing = 20.0
    
    // Make GridView and ScrollView the same size as this view
    NSLayoutConstraint.activate([
      gridView.topAnchor.constraint(equalTo: topAnchor),
      gridView.leadingAnchor.constraint(equalTo: leadingAnchor),
      gridView.trailingAnchor.constraint(equalTo: trailingAnchor),
      gridView.bottomAnchor.constraint(equalTo: bottomAnchor),
      
      scrollView.topAnchor.constraint(equalTo: topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
    
    // Make ScrollView transparent
    scrollView.drawsBackground = false

  }
}
