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
  let minHeight: CGFloat

  public init(
    configuration: EditorConfiguration,
    minHeight: CGFloat
  ) {
    self.configuration = configuration
    self.minHeight = minHeight
    super.init(frame: .zero)
  }

  public init(
    frame frameRect: NSRect,
    textContainer container: NSTextContainer?,
    configuration: EditorConfiguration,
    minHeight: CGFloat
  ) {
    self.configuration = configuration
    self.minHeight = minHeight
    super.init(frame: frameRect, textContainer: container)
  }

  required init?(coder: NSCoder) {
    self.configuration = EditorConfiguration()
    self.minHeight = .zero
    super.init(coder: coder)
  }

  /// Compute our “intrinsic” height based on layoutManager’s used rect.
  public override var intrinsicContentSize: NSSize {
    layoutManager?.ensureLayout(for: textContainer!)
    /// usedRect is in the text container’s coordinate system.
    let usedRect = layoutManager?.usedRect(for: textContainer!) ?? .zero
    /// Add textContainerInsets (top + bottom) to the used height.
    let calculatedHeight = usedRect.height + (textContainerInset.height * 2)
    return NSSize(width: NSView.noIntrinsicMetric, height: max(calculatedHeight, minHeight))
  }

  func adjustedInsets(_ config: EditorConfiguration) -> CGFloat {

    let minInsets = config.theme.insets
    guard let targetContentWidth = config.theme.maxReadingWidth,
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
