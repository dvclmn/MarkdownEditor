//
//  EditorInfo.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI


public struct EditorInfo: Sendable {
  
  var text = EditorInfo.Text()
  var selection = EditorInfo.Selection()
  var scroll = EditorInfo.Scroll()
  var height: CGFloat = .zero
  
  public struct Text: Sendable {
    var characterCount: Int = 0
    var textElementCount: Int = 0
    var codeBlocks: Int = 0
    var documentRange: String = ""
    var viewportRange: String = ""
  }
  
  public struct Selection: Sendable {
    var selection: String = ""
    //  var selectedRange: NSTextRange?
    var selectedSyntax: [Markdown.Syntax] = []
    var location: Location? = nil
    
    public struct Location: Sendable {
      var line: Int
      var column: Int
    }
  }
  
  public struct Scroll: Sendable {
    var summary: String = ""
  }
}
