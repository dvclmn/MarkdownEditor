//
//  EditorInfo.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI

public struct EditorInfo: Sendable {
  
  public struct Text: Sendable {
    let editorHeight: CGFloat
    let characterCount: Int
    let textElementCount: Int // TextElement seems to equate to a paragraph
    let codeBlocks: Int
    let documentRange: String
    let viewportRange: String
  }
  
  public struct Selection: Sendable {
    let selection: String
//    let selectedRange: NSTextRange?
    let selectedSyntax: [Markdown.Syntax]
    let lineNumber: Int?
    let columnNumber: Int?
  }
  
  public struct Scroll: Sendable {
    let summary: String
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
      Viewport Range: \(viewportRange)
      """
  }
}

extension EditorInfo.Selection {
  public var summary: String {
    
    let formattedSyntaxNames: String = selectedSyntax.map { syntax in
      syntax.name
    }.joined(separator: ", ")
    
    return """
      Selection: \(selection)
      Selected Syntax: [\(formattedSyntaxNames)]
      Line: \(lineNumber?.description ?? "nil"), Column: \(columnNumber?.description ?? "nil")
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
