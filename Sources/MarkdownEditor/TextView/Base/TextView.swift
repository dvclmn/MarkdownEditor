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
  
  var configuration: MarkdownEditorConfiguration

  public init(configuration: MarkdownEditorConfiguration) {
    self.configuration = configuration
    super.init(frame: .zero)
  }
  
  public override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
    self.configuration = MarkdownEditorConfiguration()
    super.init(frame: frameRect, textContainer: container)
  }
  
  required init?(coder: NSCoder) {
    self.configuration = MarkdownEditorConfiguration()
    super.init(coder: coder)
  }

  public override var intrinsicContentSize: NSSize {
    
    guard let layoutManager = self.layoutManager,
          let textContainer = self.textContainer
    else {
      return super.intrinsicContentSize
    }
    
    layoutManager.ensureLayout(for: textContainer)
    let usedRect = layoutManager.usedRect(for: textContainer)
    
    let overscroll: CGFloat = configuration.bottomSafeArea
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
