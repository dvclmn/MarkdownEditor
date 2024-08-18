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
    
    //    if let paragraphStyle = scrollView.textView.defaultParagraphStyle {
    //
    //      let spacingMultiple = max(paragraphStyle.lineHeightMultiple, 1)
    //      let spacing = max(paragraphStyle.lineSpacing, 1) * (spacingMultiple * 10)
    //
    //      gridView.grid.configuration.spacing = spacing
    //
    //    } else {
    //      gridView.grid.configuration.spacing = 20
    //    }
    
    gridView.grid.isSubdivided = true
    
    // TODO: Create function to properly calculate according to text line height
    gridView.grid.spacing = 39
    
    
    
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
