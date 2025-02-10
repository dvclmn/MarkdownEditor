//
//  File.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import SwiftUI
import BaseHelpers
import MarkdownModels

public class MarkdownTextView: NSTextView {
  
  var configuration: EditorConfiguration
  let minHeight: CGFloat
//  var width: CGFloat

  public init(
    configuration: EditorConfiguration,
    minHeight: CGFloat
//    width: CGFloat
  ) {
    self.configuration = configuration
    self.minHeight = minHeight
//    self.width = width
    super.init(frame: .zero)
  }
  
  public init(
    frame frameRect: NSRect,
    textContainer container: NSTextContainer?,
    configuration: EditorConfiguration,
    minHeight: CGFloat
//    width: CGFloat
  ) {
    self.configuration = configuration
    self.minHeight = minHeight
//    self.width = width
    super.init(frame: frameRect, textContainer: container)
  }
  
  required init?(coder: NSCoder) {
    self.configuration = EditorConfiguration()
    self.minHeight = .zero
//    self.width = .zero
    super.init(coder: coder)
  }
  
  
  // Compute our “intrinsic” height based on layoutManager’s used rect.
  public override var intrinsicContentSize: NSSize {
    // When in non-editable mode the text view should size itself
    if !isEditable {
      layoutManager?.ensureLayout(for: textContainer!)
      // usedRect is in the text container’s coordinate system.
      let usedRect = layoutManager?.usedRect(for: textContainer!) ?? .zero
      // Add textContainerInsets (top + bottom) to the used height.
      let calculatedHeight = usedRect.height + (textContainerInset.height * 2)
      return NSSize(width: NSView.noIntrinsicMetric, height: max(calculatedHeight, minHeight))
    }
    // When editable, return no intrinsic height (the height is controlled externally)
    return NSSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
  }
  
  
  
  

//  public override var intrinsicContentSize: NSSize {
//    
//    guard let layoutManager = self.layoutManager,
//          let textContainer = self.textContainer
//    else {
//      return super.intrinsicContentSize
//    }
//    
//    layoutManager.ensureLayout(for: textContainer)
//    let usedRect = layoutManager.usedRect(for: textContainer)
//    
//    let overscroll: CGFloat = configuration.theme.bottomSafeArea
//    let insets = self.textContainerInset.height * 2 // For top and bottom
//    
//    return NSSize(width: NSView.noIntrinsicMetric, height: ceil(usedRect.height) + (insets + overscroll))
//  }
  
  
//  public override func layout() {
//    super.layout()
//    if let textContainer = self.textContainer {
//      textContainer.containerSize = NSSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
//    }
//    self.invalidateIntrinsicContentSize()
//  }
  
//  func adjustedInsets(_ config: EditorConfiguration) -> CGFloat {
//
//    let minInsets = config.theme.insets
//    guard let targetContentWidth = config.theme.maxReadingWidth else {
//      return minInsets
//    }
//    
//    
////    let availableWidth = self.width
//    
//    /// If the available width is less than target, use minimum insets
//    if availableWidth <= targetContentWidth {
//      return minInsets
//    }
//    
//    /// Calculate how much total padding we need
//    let totalPadding = availableWidth - targetContentWidth
//    
//    /// Since lineFragmentPadding is applied to both sides,
//    /// divide by 2 to get the per-side value
//    let padding = totalPadding / 2.0
//    
//    return max(minInsets, padding)
//  }
  
//  func updateContainerWidth(width: CGFloat) {
//    if let textContainer = self.textContainer {
//      let insets = adjustedInsets(configuration)
//      self.textContainer?.lineFragmentPadding = insets
//      
//      textContainer.containerSize = NSSize(width: width, height: CGFloat.greatestFiniteMagnitude)
//      self.invalidateIntrinsicContentSize()
//    }
//  }
  
  public override func didChangeText() {
    print("didChangeText")
    super.didChangeText()
    self.invalidateIntrinsicContentSize()
  }
  
//  public override func setFrameSize(_ newSize: NSSize) {
////    print("setFrameSize – new size: \(newSize)")
//    super.setFrameSize(newSize)
//    self.invalidateIntrinsicContentSize()
//  }
  
  
}
