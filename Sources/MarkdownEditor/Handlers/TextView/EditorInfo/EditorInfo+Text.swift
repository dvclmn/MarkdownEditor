//
//  EditorInfo+Text.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import SwiftUI

extension EditorInfo.Text {
  public var summary: String {
      """
      Editor height: \(editorHeight)
      Characters: \(characterCount)
      Paragraphs: \(textElementCount)
      Code blocks: \(codeBlocks)
      Document Range: \(documentRange)
      Viewport Range: \(viewportRange)
      """
  }
}

extension MarkdownTextView {
  
  func calculateTextInfo() -> EditorInfo.Text {
    
    guard let tlm = self.textLayoutManager,
          let viewportRange = tlm.textViewportLayoutController.viewportRange
    else { return .init() }
    
    let documentRange = self.textLayoutManager!.documentRange
    
    var textElementCount: Int = 0
    
    textLayoutManager?.textContentManager?.enumerateTextElements(from: documentRange.location, using: { _ in
      textElementCount += 1
      return true
    })
    
    return EditorInfo.Text(
      editorHeight: self.editorHeight,
      characterCount: self.string.count,
      textElementCount: textElementCount,
//      codeBlocks: self.countCodeBlocks(),
      documentRange: documentRange.description,
      viewportRange: viewportRange.description
    )
  }
}
