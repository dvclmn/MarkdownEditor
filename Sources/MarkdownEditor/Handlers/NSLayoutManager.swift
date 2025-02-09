//
//  LayoutManager.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 8/2/2025.
//

import AppKit
import BaseStyles
import MarkdownModels

class CodeBackgroundLayoutManager: NSLayoutManager {

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

    drawInlineCodeBackgrounds(
      in: charRange, textStorage: textStorage, textContainer: textContainer, origin: origin)

    //    drawCodeBlockBackgrounds(in: charRange, textStorage: textStorage, textContainer: textContainer, origin: origin)
    drawMergedCodeBlockBackgrounds(
      in: charRange, textStorage: textStorage, textContainer: textContainer, origin: origin)


    super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
  }

  private func drawInlineCodeBackgrounds(
    in charRange: NSRange, textStorage: NSTextStorage, textContainer: NSTextContainer,
    origin: NSPoint
  ) {
    textStorage.enumerateAttribute(
      CodeBackground.inlineCode.attributeKey, in: charRange, options: []
    ) { (value, range, _) in
      if let syntaxType = value as? Bool, syntaxType {
        let glyphRangeForCode = self.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        self.enumerateEnclosingRects(
          forGlyphRange: glyphRangeForCode,
          withinSelectedGlyphRange: NSRange(location: NSNotFound, length: 0), in: textContainer
        ) { (rect, _) in
          let drawRect = rect.offsetBy(dx: origin.x, dy: origin.y).insetBy(dx: -2, dy: -1)
          let roundedPath = NSBezierPath(
            roundedRect: drawRect, xRadius: self.configuration.theme.codeBackgroundRounding,
            yRadius: self.configuration.theme.codeBackgroundRounding)
          self.configuration.theme.inlineCodeBackgroundColour.nsColour.setFill()
          roundedPath.fill()
        }
      }
    }
  }

  private func drawCodeBlockBackgrounds(
    in charRange: NSRange, textStorage: NSTextStorage, textContainer: NSTextContainer,
    origin: NSPoint
  ) {
    textStorage.enumerateAttribute(
      CodeBackground.codeBlock.attributeKey, in: charRange, options: []
    ) { (value, range, _) in
      if let syntaxType = value as? Bool, syntaxType {
        let glyphRangeForCode = self.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        self.enumerateEnclosingRects(
          forGlyphRange: glyphRangeForCode,
          withinSelectedGlyphRange: NSRange(location: NSNotFound, length: 0), in: textContainer
        ) { (rect, _) in
          let drawRect = rect.offsetBy(dx: origin.x, dy: origin.y).insetBy(dx: -2, dy: -1)
          let roundedPath = NSBezierPath(
            roundedRect: drawRect, xRadius: self.configuration.theme.codeBackgroundRounding,
            yRadius: self.configuration.theme.codeBackgroundRounding)
          self.configuration.theme.codeBlockBackgroundColour.nsColour.setFill()
          roundedPath.fill()
        }
      }
    }
  }

  private func drawMergedCodeBlockBackgrounds(
    in charRange: NSRange, textStorage: NSTextStorage, textContainer: NSTextContainer,
    origin: NSPoint
  ) {
    var mergedRanges: [NSRange] = []
    var currentRange: NSRange?

    /// First, collect and merge all code block ranges
    textStorage.enumerateAttribute(
      CodeBackground.codeBlock.attributeKey, in: charRange, options: []
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
}
