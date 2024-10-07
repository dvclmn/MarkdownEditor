//
//  DataModel.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import SwiftUI
import RegexBuilder

//extension Regex<Substring>: @unchecked @retroactive Sendable {}
//extension NSTextRange: @unchecked @retroactive Sendable {}
//extension NSParagraphStyle: @unchecked @retroactive Sendable {}


enum BlockSyntax {
  case heading(level: Int)
  case list
  case code
  case quote
  case none
}



