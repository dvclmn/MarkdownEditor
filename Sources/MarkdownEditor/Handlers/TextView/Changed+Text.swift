//
//  TextChanged.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI


extension MarkdownTextView {
  
  public override func didChangeText() {
    
    super.didChangeText()
    

    Task { @MainActor in

      try await Task.sleep(for: .seconds(0.1))
      
      await self.applyMarkdownStyles()
      
      let info = self.generateTextInfo()
      await infoHandler.update(info)
      

    }
    
    Task {
      // TODO: Consider adding a debounce to this as well as all the rest
      await self.parseMarkdown()
    }
  }
}

extension EditorInfo.Text {
  public var summary: String {
      """
      Characters: \(characterCount)
      Paragraphs: \(textElementCount)
      Viewport Range: \(viewportRange)
      
      \(scratchPad)
      """
  }
}

extension MarkdownTextView {
  
  
  
  func generateTextInfo() -> EditorInfo.Text {
    
//    TCM's attString char. count: \(tcm.attributedString(in: documentRange)?.string.count ?? 0)
    
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager,
          let viewportRange = tlm.textViewportLayoutController.viewportRange
    else { return .init() }
    
    let documentRange = tlm.documentRange
    
    var textElementCount: Int = 0
    
    tlm.textContentManager?.enumerateTextElements(from: documentRange.location, using: { _ in
      textElementCount += 1
      return true
    })
    
    let scratchPad: String = """
    Insets: \(self.textContainer?.lineFragmentPadding.description ?? "")
    Total elements: \(self.elements.count)
    """
    
    return EditorInfo.Text(
      characterCount: self.string.count,
      textElementCount: textElementCount,
//      codeBlocks: self.elements.filter { $0.type == .codeBlock(language: nil) }.count,
      documentRange: documentRange.description,
      viewportRange: viewportRange.description,
      scratchPad: scratchPad
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
