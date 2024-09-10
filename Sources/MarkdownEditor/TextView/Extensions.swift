//
//  Extensions.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 10/9/2024.
//

import AppKit

extension NSTextView {
  var selectedText: String {
    var text = ""
    for case let range as NSRange in self.selectedRanges {
      text.append(string[range]+"\n")
    }
    text = String(text.dropLast())
    return text
  }
}

extension String {
  subscript (_ range: NSRange) -> Self {
    .init(self[index(startIndex, offsetBy: range.lowerBound) ..< index(startIndex, offsetBy: range.upperBound)])
  }
}
