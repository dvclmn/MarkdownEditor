//
//  File.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import SwiftUI
import BaseHelpers
import MarkdownModels
//import Highlightr

public class MarkdownTextView: NSTextView {
  
//  var elements: [Markdown.Element] = []
//  var paragraphHandler = ParagraphHandler()
  
  /// Debouncers
  ///
//  var frameDebouncer = Debouncer(interval: 0.3)
//  var parsingDebouncer = Debouncer(interval: 0.1)
//  var infoDebouncer = Debouncer(interval: 0.3)
//  var paragraphDebouncer = Debouncer(interval: 0.3)
//  var stylingDebouncer = Debouncer(interval: 0.3)
  
//  let infoUpdater: EditorInfoUpdater
//  public var onInfoUpdate: InfoUpdate = { _ in }

//  var horizontalInsets: CGFloat {
//    
//    print("Horizontal insets, Called @ \(Date.now.friendlyDateAndTime)")
//    
//    let width = self.frame.width
//    let maxWidth: CGFloat = configuration.maxReadingWidth
//    
//    if width > maxWidth + (configuration.insets * 2) {
//      return (width - maxWidth) / 2
//    } else {
//      return configuration.insets
//    }
//    
//  }
  
//  func handleWidthChange(newWidth: CGFloat) {
//    
//    // Perform your task here when the width changes
//    print("Text view width changed to: \(newWidth)")
//  }
  
  
  public override var intrinsicContentSize: NSSize {
    
    print("Ran `intrinsicContentSize`")
    guard let layoutManager = self.layoutManager,
          let textContainer = self.textContainer
    else {
      return super.intrinsicContentSize
    }
    
    layoutManager.ensureLayout(for: textContainer)
    let usedRect = layoutManager.usedRect(for: textContainer)
    
    let overscroll: CGFloat = 60
    let insets = self.textContainerInset.height * 2 // For top and bottom
    
    return NSSize(width: NSView.noIntrinsicMetric, height: ceil(usedRect.height) + (insets + overscroll))
    
  }
  
  public override func layout() {
    super.layout()
    print("Performed layout")
    
    if let textContainer = self.textContainer {
      textContainer.containerSize = NSSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
    }
    self.invalidateIntrinsicContentSize()
  }
  
  func updateContainerWidth(width: CGFloat) {
    if let textContainer = self.textContainer {
      textContainer.containerSize = NSSize(width: width, height: CGFloat.greatestFiniteMagnitude)
      self.invalidateIntrinsicContentSize()
      //      needsLayout = true
      //      needsDisplay = true
    }
  }
  
  public override func didChangeText() {
    print("didChangeText")
    super.didChangeText()
    self.invalidateIntrinsicContentSize()
  }
  
  public override func setFrameSize(_ newSize: NSSize) {
    print("setFrameSize – new size: \(newSize)")
    super.setFrameSize(newSize)
    self.invalidateIntrinsicContentSize()
  }
  
  
}
