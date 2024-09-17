//
//  ParagraphInfo.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 17/9/2024.
//

import AppKit

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
    
    let output: String = """
     \(Date.now.friendlyDateAndTime.string)
    Type: \(type)
    Range: \(range)
    String: \(string.trimmingCharacters(in: .whitespacesAndNewlines).preview(40))...
    """
    
    return output
  }
}
