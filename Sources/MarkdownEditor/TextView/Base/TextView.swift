//
//  File.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import BaseHelpers
import MarkdownModels
import SwiftUI

public class MarkdownTextView: NSTextView {

  var configuration: EditorConfiguration
  private let minEditorHeight: CGFloat = 80
  
  /// Closure to call when the intrinsic height (of the text view) changes.
  var heightChanged: ((CGFloat) -> Void)?

  /// A stored property to throttle height updates.
  private var lastReportedHeight: CGFloat = 0
  private let reportableHeightThreshold: TimeInterval = 4


  public init(
    configuration: EditorConfiguration
  ) {
    self.configuration = configuration
    super.init(frame: .zero)
  }

  public init(
    frame frameRect: NSRect,
    textContainer container: NSTextContainer?,
    configuration: EditorConfiguration
  ) {
    self.configuration = configuration
    super.init(frame: frameRect, textContainer: container)
  }

  required init?(coder: NSCoder) {
    self.configuration = EditorConfiguration()
    super.init(coder: coder)
  }

  /// Compute our “intrinsic” height based on layoutManager’s used rect.
  public override var intrinsicContentSize: NSSize {
    layoutManager?.ensureLayout(for: textContainer!)
    /// usedRect is in the text container’s coordinate system.
    let usedRect = layoutManager?.usedRect(for: textContainer!) ?? .zero
    /// Add textContainerInsets (top + bottom) to the used height.
    let calculatedHeight = adjustedHeight(height: usedRect.height)
    return NSSize(width: NSView.noIntrinsicMetric, height: max(calculatedHeight, minEditorHeight))
  }
  
  
  public override func layout() {
    super.layout()
    
    
    if isEditable {
      /// When editable, let the document view's height be determined by its content.
      guard let layoutManager = layoutManager,
            let textContainer = textContainer
      else {
        return
      }
      /// Recalculate layout so that `usedRect` is up-to-date.
      layoutManager.ensureLayout(for: textContainer)
      let usedRect = layoutManager.usedRect(for: textContainer)
      
      /// Compute the content height including our text container insets.
      let contentHeight = adjustedHeight(height: usedRect.height)
      
      /// The document view (textView) should be as tall as:
      /// - self.bounds.height if content is short (so the whole visible area is used)
      /// - or contentHeight if the text is larger than the view.
      let newFrameHeight = max(contentHeight, self.bounds.height)
      
      /// Set the text view's frame accordingly.
      frame = NSRect(x: 0, y: 0, width: self.bounds.width, height: newFrameHeight)
      
    } else {
      /// In non-editable mode, simply match the bounds.
      frame = self.bounds
    }
    
    /// Invalidate intrinsic content size to trigger a height update.
    invalidateIntrinsicContentSize()
    let newHeight = intrinsicContentSize.height
    /// Only notify if the height has changed significantly.
    if abs(newHeight - lastReportedHeight) > reportableHeightThreshold {
      lastReportedHeight = newHeight
      heightChanged?(newHeight)
    }
  }
  
  func adjustedHeight(height: CGFloat) -> CGFloat {
    return height + (adjustedInsets() * 2) + configuration.theme.overScrollAmount
  }
  
  func adjustedInsets() -> CGFloat {

    let minInsets = configuration.theme.insets
    guard let targetContentWidth = configuration.theme.maxReadingWidth,
          let availableWidth = self.textContainer?.size.width
    else {
      return minInsets
    }

    /// If the available width is less than target, use minimum insets
    if availableWidth <= targetContentWidth {
      return minInsets
    }

    /// Calculate how much total padding we need
    let totalPadding = availableWidth - targetContentWidth

    /// Since lineFragmentPadding is applied to both sides,
    /// divide by 2 to get the per-side value
    let padding = totalPadding / 2.0

    return max(minInsets, padding)
  }

  public override func didChangeText() {
    print("didChangeText")
    super.didChangeText()
    self.invalidateIntrinsicContentSize()
  }

}
