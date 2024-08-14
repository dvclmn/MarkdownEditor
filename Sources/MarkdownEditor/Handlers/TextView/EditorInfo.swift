//
//  EditorInfo.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI

public struct EditorInfo {
  
  public struct Text {
    let editorHeight: CGFloat
    let characterCount: Int
    let textElementCount: Int // TextElement seems to equate to a paragraph
    let documentRange: NSTextRange
    
    public var summary: String {
      """
      Editor height: \(editorHeight)
      Characters: \(characterCount)
      Paragraphs: \(textElementCount)
      Document Range: \(documentRange)
      """
    }
  }
  
  public struct Selection {
    let selectedRange: NSRange
    let lineNumber: Int
    let columnNumber: Int
    
    public var summary: String {
      """
      Selected Range: \(selectedRange)
      Line: \(lineNumber), Column: \(columnNumber)
      """
    }
    
    public static func summaryFor(selection: Selection) -> String {
      selection.summary
    }
    
    
  }
  
  public static func fullSummary(text: Text, selection: Selection) -> String {
    """
    Text Info:
    \(text.summary)
    
    Selection Info:
    \(selection.summary)
    """
  }
  
}
