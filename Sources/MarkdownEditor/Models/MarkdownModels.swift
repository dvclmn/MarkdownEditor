//
//  DataModel.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import SwiftUI
import RegexBuilder
import BoxMaker

extension Regex<Substring>: @unchecked @retroactive Sendable {}
extension NSTextRange: @unchecked @retroactive Sendable {}
extension NSParagraphStyle: @unchecked @retroactive Sendable {}

public struct Markdown {

  struct Element {
    var syntax: Markdown.Syntax
    var range: NSTextRange
  }
  
  
  
}

enum BlockSyntax {
  case heading
  case list
  case code
  case quote
  case none
}

struct ParagraphInfo {
  var string: String
  var range: NSRange
  var type: BlockSyntax
  
  init(
    string: String = "",
    range: NSRange = .zero,
    type: BlockSyntax = .none
  ) {
    self.string = string
    self.range = range
    self.type = type
  }
}

extension ParagraphInfo: CustomStringConvertible {
  var description: String {
    
    
    
    return "ParagraphInfo: \(string)"
  }
}


