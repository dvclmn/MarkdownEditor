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
    
    if self.string != lastTextValue {

      updateEditorHeight()

      lastTextValue = self.string
      onTextChange(calculateTextInfo())
    }
    
  }
  
  func calculateTextInfo() -> EditorInfo.Text {
    
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
      documentRange: documentRange
    )
  }
  
  
}
