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
    let codeBlocks: Int
    let documentRange: NSTextRange
  }
  
  public struct Selection {
    let selectedRange: NSTextRange?
    let selectedSyntax: [Markdown.Syntax]
    let lineNumber: Int
    let columnNumber: Int
  }
}

extension EditorInfo.Text {
  public var summary: String {
      """
      Editor height: \(editorHeight)
      Characters: \(characterCount)
      Paragraphs: \(textElementCount)
      Code blocks: \(codeBlocks)
      Document Range: \(documentRange)
      """
  }
}

extension EditorInfo.Selection {
  public var summary: String {
    
    let formattedSyntaxNames: String = selectedSyntax.map { syntax in
      syntax.name
    }.joined(separator: ", ")
    
    return """
      Selected Syntax: [\(formattedSyntaxNames)]
      Selected Range: \(selectedRange?.description ?? "nil")
      Line: \(lineNumber), Column: \(columnNumber)
      """
  }
  
  public static func summaryFor(selection: EditorInfo.Selection) -> String {
    selection.summary
  }
}

extension EditorInfo {
  public static func fullSummary(text: Text, selection: Selection) -> String {
    """
    Text Info:
    \(text.summary)
    
    Selection Info:
    \(selection.summary)
    """
  }
}
