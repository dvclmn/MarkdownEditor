//
//  Parsing.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import Foundation
import AppKit

enum SyntaxRangeType {
  case total
  case content
  case leadingSyntax
  case trailingSyntax
}


struct MarkdownRanges {
  let all: NSRange
  let leading: NSRange
  let content: NSRange
  let trailing: NSRange
}
