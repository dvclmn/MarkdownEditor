//
//  TextChanged.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI

extension MarkdownEditor.Coordinator {
  
  
  
}

extension MarkdownTextView {
  
  public override func didChangeText() {
    
    super.didChangeText()
    
    /// Debounced editor height updates, to avoid glitching
    ///
//    Task {
//      await heightHandler.processTask { [weak self] in
//        
//        guard let self = self else { return }
//        
//        let height = await self.generateEditorHeight()
//        
//        Task { @MainActor in
//          await self.infoHandler.update(height)
//        }
//        
//      } // END process scroll
//    } // END Task
    
    Task { @MainActor in

      let info = self.generateTextInfo()
      await infoHandler.update(info)

    }
#if DEBUG
    // TODO: This is an expensive operation, and is only here temporarily for debugging.
    self.processMarkdownBlocks(highlight: true)
#endif

//    Task {
//      
//      do {
//        try await Task.sleep(for: .seconds(0.4))
//        
//        self.processingTime = await self.processFullDocumentWithTiming(self.string)
//      } catch {
//        
//      }
//    }
  }
}

extension EditorInfo.Text {
  public var summary: String {
      """
      Processing time: \(processingTime)
      Characters: \(characterCount)
      Paragraphs: \(textElementCount)
      Code blocks: \(codeBlocks)
      Document Range: \(documentRange)
      Viewport Range: \(viewportRange)
      """
  }
}


extension MarkdownTextView {
  
//  
//  func generateEditorHeight() -> EditorInfo.Frame {
//    
//    guard let tlm = self.textLayoutManager
//    else { return .init() }
//    let documentRange = tlm.documentRange
//    
//    tlm.ensureLayout(for: documentRange)
//    
//    let typographicBounds: CGFloat = tlm.typographicBounds(in: documentRange)?.height ?? .zero
//    let height = (configuration.insets * 2) + typographicBounds
//
//    return EditorInfo.Frame(
//      height: height,
//      width: .greatestFiniteMagnitude // Not used currently
//    )
//  }
  
  
  func generateTextInfo() -> EditorInfo.Text {
    
    guard let tlm = self.textLayoutManager,
          let viewportRange = tlm.textViewportLayoutController.viewportRange
    else { return .init() }
    
    let documentRange = tlm.documentRange
    
    var textElementCount: Int = 0
    
    tlm.textContentManager?.enumerateTextElements(from: documentRange.location, using: { _ in
      textElementCount += 1
      return true
    })
    
    return EditorInfo.Text(
      processingTime: self.processingTime,
      characterCount: self.string.count,
      textElementCount: textElementCount,
      codeBlocks: self.blocks.filter { $0.syntax == .codeBlock }.count,
      documentRange: documentRange.description,
      viewportRange: viewportRange.description
    )
  }
  
  //  func calculateCodeBlocks() -> Int? {
  //    guard let tlm = self.textLayoutManager,
  //          let tcm = tlm.textContentManager
  //            //          let tcs = self.textContentStorage
  //            //          let visible = tlm.textViewportLayoutController.viewportRange
  //    else { return nil }
  //
  //    let documentRange = tlm.documentRange
  //
  //    var codeBlockCount = 0
  //
  //    //    let nsRange = NSRange(documentRange, in: tcm)
  //
  //    // Enumerate through text paragraphs
  //    tcm.enumerateTextElements(from: documentRange.location, options: []) { textElement in
  //      guard let paragraph = textElement as? NSTextParagraph else { return true }
  //
  //      // Get the content of the paragraph
  //      let paragraphRange = paragraph.elementRange
  //      guard let content = tcm.attributedString(in: paragraphRange)?.string else { return true }
  //
  //      // Check if the paragraph starts with three backticks
  //      if content.hasPrefix("```") {
  //        codeBlockCount += 1
  //      }
  //
  //      return true
  //    }
  //
  //    return codeBlockCount
  //  } // END calc code blocks
  //
  //
  //  func highlightCodeBlocks() {
  //    guard let tlm = self.textLayoutManager,
  //          let tcm = tlm.textContentManager,
  //          let tcs = self.textContentStorage else {
  //      return
  //    }
  //
  //    let documentRange = tlm.documentRange
  //    var codeBlockRanges: [NSTextRange] = []
  //
  //    tcm.enumerateTextElements(from: documentRange.location, options: []) { textElement in
  //
  //      guard let paragraph = textElement as? NSTextParagraph,
  //            let paragraphRange = paragraph.elementRange
  //      else { return true }
  //
  //      guard let content = tcm.attributedString(in: paragraphRange)?.string else { return true }
  //
  //      if content.hasPrefix("```") {
  //        codeBlockRanges.append(paragraphRange)
  //      }
  //
  //      return true
  //    }
  //
  //    tcm.performEditingTransaction {
  //      for range in codeBlockRanges {
  //
  //
  //
  //        tcs.textStorage?.addAttributes(.highlighter, range: NSRange(range, in: tcm))
  //
  //
  //
  //      }
  //    }
  //  }
  
}

//
//final class MarkdownTextLayoutFragment: NSTextLayoutFragment {
//  private let paragraphStyle: NSParagraphStyle
//  var showsInvisibleCharacters: Bool = false
//
//  init(textElement: NSTextElement, range rangeInElement: NSTextRange?, paragraphStyle: NSParagraphStyle) {
//    self.paragraphStyle = paragraphStyle
//    super.init(textElement: textElement, range: rangeInElement)
//  }
//
//  required init?(coder: NSCoder) {
//    self.paragraphStyle = NSParagraphStyle.default
//    self.showsInvisibleCharacters = false
//    super.init(coder: coder)
//  }
//
//  override func draw(at point: CGPoint, in context: CGContext) {
//
//    context.saveGState()
//
//#if USE_FONT_SMOOTHING_STYLE
//    // This seems to be available at least on 10.8 and later. The only reference to it is in
//    // WebKit. This causes text to render just a little lighter, which looks nicer.
//    let useThinStrokes = true // shouldSmooth
//    var savedFontSmoothingStyle: Int32 = 0
//
//    if useThinStrokes {
//      context.setShouldSmoothFonts(true)
//      savedFontSmoothingStyle = STContextGetFontSmoothingStyle(context)
//      STContextSetFontSmoothingStyle(context, 16)
//    }
//#endif
//
//    for lineFragment in textLineFragments {
//      // Determine paragraph style. Either from the fragment string or default for the text view
//      // the ExtraLineFragment doesn't have information about typing attributes hence layout manager uses a default values - not from text view
//      let paragraphStyle: NSParagraphStyle
//      if !lineFragment.isExtraLineFragment,
//         let lineParagraphStyle = lineFragment.attributedString.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle
//      {
//        paragraphStyle = lineParagraphStyle
//      } else {
//        paragraphStyle = self.paragraphStyle
//      }
//
//      if !paragraphStyle.lineHeightMultiple.isAlmostZero() {
//        let offset = -(lineFragment.typographicBounds.height * (paragraphStyle.lineHeightMultiple - 1.0) / 2)
//        lineFragment.draw(at: point.moved(dx: lineFragment.typographicBounds.origin.x, dy: lineFragment.typographicBounds.origin.y + offset), in: context)
//      } else {
//        lineFragment.draw(at: lineFragment.typographicBounds.origin, in: context)
//      }
//    }
//
//#if USE_FONT_SMOOTHING_STYLE
//    if (useThinStrokes) {
//      STContextSetFontSmoothingStyle(context, savedFontSmoothingStyle);
//    }
//#endif
//
//    if showsInvisibleCharacters {
//      drawInvisibles(at: point, in: context)
//    }
//
//    context.restoreGState()
//  }
//
//  private func drawInvisibles(at point: CGPoint, in context: CGContext) {
//    guard let textLayoutManager = textLayoutManager else {
//      return
//    }
//
//    context.saveGState()
//
//    for lineFragment in textLineFragments where !lineFragment.isExtraLineFragment {
//
//      let string = lineFragment.attributedString.string
//      if let textLineTextRange = lineFragment.textRange(in: self) {
//        for (offset, character) in string.utf16.enumerated() where Unicode.Scalar(character)?.properties.isWhitespace == true {
//          guard let segmentLocation = textLayoutManager.location(textLineTextRange.location, offsetBy: offset),
//                let segmentEndLocation = textLayoutManager.location(textLineTextRange.location, offsetBy: offset),
//                let segmentRange = NSTextRange(location: segmentLocation, end: segmentEndLocation),
//                let segmentFrame = textLayoutManager.textSegmentFrame(in: segmentRange, type: .standard),
//                let font = lineFragment.attributedString.attribute(.font, at: offset, effectiveRange: nil) as? NSFont
//          else {
//            // assertionFailure()
//            continue
//          }
//
//          let symbol: Character = switch character {
//          case 0x0020: "\u{00B7}"  // • Space
//          case 0x0009: "\u{00BB}"  // » Tab
//          case 0x000A: "\u{00AC}"  // ¬ Line Feed
//          case 0x000D: "\u{21A9}"  // ↩ Carriage Return
//          case 0x00A0: "\u{235F}"  // ⎵ Non-Breaking Space
//          case 0x200B: "\u{205F}"  // ⸱ Zero Width Space
//          case 0x200C: "\u{200C}"  // ‌ Zero Width Non-Joiner
//          case 0x200D: "\u{200D}"  // ‍ Zero Width Joiner
//          case 0x2060: "\u{205F}"  //   Word Joiner
//          case 0x2028: "\u{23CE}"  // ⏎ Line Separator
//          case 0x2029: "\u{00B6}"  // ¶ Paragraph Separator
//          default: "\u{00B7}"  // • Default symbol for unspecified whitespace
//          }
//
//          let symbolString = String(symbol)
//          let attributes: [NSAttributedString.Key: Any] = [
//            .font: font,
//            .foregroundColor: NSColor.placeholderTextColor
//          ]
//
//          let frameRect = CGRect(origin: CGPoint(x: segmentFrame.origin.x - layoutFragmentFrame.origin.x, y: segmentFrame.origin.y - layoutFragmentFrame.origin.y), size: CGSize(width: segmentFrame.size.width, height: segmentFrame.size.height)).pixelAligned
//
//          let charSize = symbolString.size(withAttributes: attributes)
//          let writingDirection = textLayoutManager.baseWritingDirection(at: textLineTextRange.location)
//          let point = CGPoint(x: frameRect.origin.x - (writingDirection == .leftToRight ? 0 : charSize.width),
//                              y: (frameRect.height - charSize.height) / 2)
//
//          symbolString.draw(at: point, withAttributes: attributes)
//        }
//      }
//    }
//
//    context.restoreGState()
//  }
//}
//
