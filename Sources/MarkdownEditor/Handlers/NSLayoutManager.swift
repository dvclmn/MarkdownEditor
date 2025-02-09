//
//  LayoutManager.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 8/2/2025.
//

import AppKit
import BaseStyles
import MarkdownModels

class MarkdownLayoutManager: NSLayoutManager {

  let configuration: MarkdownEditorConfiguration

  public init(configuration: MarkdownEditorConfiguration) {
    self.configuration = configuration
    super.init()
  }

  required init?(coder: NSCoder) {
    fatalError("Not implemented")
  }

    
    
  override func drawBackground(
    forGlyphRange glyphsToShow: NSRange,
    at origin: NSPoint
  ) {
    guard let textStorage = self.textStorage,
      let textContainer = self.textContainers.first
    else {
      super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
      return
    }

    let charRange = self.characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
    
    
    // Log the ranges for debugging
    print("Glyph range: \(glyphsToShow), Character range: \(charRange)")

    
    /// Draw text backgrounds
    for type in TextBackground.allCases {
      drawTextBackground(
        for: type,
        in: charRange,
        textStorage: textStorage,
        textContainer: textContainer,
        origin: origin
      )
    }
    
    /// Draw horizontal rules
    drawHorizontalRules(in: charRange, at: origin)
    
    super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
    
  }

  private func drawTextBackground(
    for backgroundType: TextBackground,
    in charRange: NSRange,
    textStorage: NSTextStorage,
    textContainer: NSTextContainer,
    origin: NSPoint
  ) {
    
    /// It's a little clunky, but for now, `codeBlock` has it's own special implementation.
    guard backgroundType != .codeBlock else {
      return drawMergedCodeBlockBackgrounds(
        in: charRange,
        textStorage: textStorage,
        textContainer: textContainer,
        origin: origin
      )
    }
    
    /// From here, we're only dealing with non`codeBlock` backgrounds,
    /// such as `highlight` and `inlineCode`
    textStorage.enumerateAttribute(
      backgroundType.attributeKey, in: charRange, options: []
    ) { (value, range, _) in

      /// Check we're working with the correct attribute type
      guard let backgroundValue = value as? Bool, backgroundValue else { return }

      let glyphRange = self.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
      self.enumerateEnclosingRects(
        forGlyphRange: glyphRange,
        withinSelectedGlyphRange: NSRange(location: NSNotFound, length: 0), in: textContainer
      ) { (rect, _) in

        /// Create the rectangle
        let drawRect = rect.offsetBy(
          dx: origin.x,
          dy: origin.y
        ).insetBy(
          dx: backgroundType.insets.dx,
          dy: backgroundType.insets.dx
        )

        let rounding = self.configuration.theme.codeBackgroundRounding
        let fillColour: NSColor = backgroundType.fillColour(from: self.configuration).nsColour
        let roundedPath = NSBezierPath(roundedRect: drawRect, xRadius: rounding, yRadius: rounding)
        fillColour.setFill()
        roundedPath.fill()
      }

    }
  }

  private func drawMergedCodeBlockBackgrounds(
    in charRange: NSRange,
    textStorage: NSTextStorage,
    textContainer: NSTextContainer,
    origin: NSPoint
  ) {
    var mergedRanges: [NSRange] = []
    var currentRange: NSRange?

    /// First, collect and merge all code block ranges
    textStorage.enumerateAttribute(
      TextBackground.codeBlock.attributeKey, in: charRange, options: []
    ) { (value, range, _) in
      guard let isCodeBlock = value as? Bool, isCodeBlock else { return }

      if let existing = currentRange {
        /// If ranges are adjacent or overlapping, merge them
        if range.location <= existing.upperBound {
          currentRange = NSRange(
            location: existing.location,
            length: max(range.upperBound - existing.location, existing.length))
        } else {
          /// If there's a gap, store the current range and start a new one
          mergedRanges.append(existing)
          currentRange = range
        }
      } else {
        currentRange = range
      }
    }

    /// Add the last range if it exists
    if let lastRange = currentRange {
      mergedRanges.append(lastRange)
    }

    /// Draw each merged range as a single background
    for range in mergedRanges {
      let glyphRange = self.glyphRange(forCharacterRange: range, actualCharacterRange: nil)

      /// Get all rects that enclose the entire range
      var unionRect: NSRect?
      self.enumerateEnclosingRects(
        forGlyphRange: glyphRange,
        withinSelectedGlyphRange: NSRange(location: NSNotFound, length: 0),
        in: textContainer
      ) { (rect, stop) in
        if let current = unionRect {
          unionRect = current.union(rect)
        } else {
          unionRect = rect
        }
      }

      /// Draw the unified background
      if let rect = unionRect {
        let drawRect = rect.offsetBy(dx: origin.x, dy: origin.y)
          .insetBy(dx: -4, dy: -2)

        let roundedPath = NSBezierPath(
          roundedRect: drawRect,
          xRadius: configuration.theme.codeBackgroundRounding,
          yRadius: configuration.theme.codeBackgroundRounding)

        configuration.theme.codeBlockBackgroundColour.nsColour.setFill()
        roundedPath.fill()
      }
    }
  }
  
  
  private func drawHorizontalRules(in charRange: NSRange, at origin: NSPoint) {
    guard let textStorage = self.textStorage else { return }
    
    textStorage.enumerateAttribute(.attachment, in: charRange, options: []) { value, range, stop in
      if let attachment = value as? HorizontalRuleAttachment {
        // Calculate the glyph range for the attachment
        let glyphRange = self.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        
        // Get the line fragment rect for the glyph range
        var lineFragmentRect = CGRect.zero
        self.lineFragmentRect(forGlyphAt: glyphRange.location, effectiveRange: nil, withoutAdditionalLayout: true)
        
        // Adjust the rect for the origin
        lineFragmentRect.origin.x += origin.x
        lineFragmentRect.origin.y += origin.y
        
        // Draw the horizontal rule
        self.drawHorizontalRule(attachment: attachment, in: lineFragmentRect)
      }
    }
  }
  
  private func drawHorizontalRule(attachment: HorizontalRuleAttachment, in rect: CGRect) {
    guard let context = NSGraphicsContext.current?.cgContext else { return }
    
    // Calculate the line position (centered vertically in the frame)
    let y = rect.midY
    
    // Set up the line style
    context.setLineWidth(attachment.thickness)
    context.setStrokeColor(attachment.color.cgColor)
    
    // Draw the line
    context.move(to: CGPoint(x: rect.minX, y: y))
    context.addLine(to: CGPoint(x: rect.maxX, y: y))
    context.strokePath()
  }
}
