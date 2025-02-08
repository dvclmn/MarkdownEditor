//
//  TextView.swift
//  Components
//
//  Created by Dave Coleman on 7/2/2025.
//

import AppKit

public class AutoSizingTextView: NSTextView {

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
