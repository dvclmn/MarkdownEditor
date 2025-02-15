//
//  Paragraph.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 12/10/2024.
//

import AppKit

public class MarkdownParagraph: NSTextParagraph {
  
  public var attachmentRanges: Array<NSRange>
  
  public init(
    attributedString:NSAttributedString,
    textContentManager: NSTextContentManager,
    elementRange: NSTextRange?,
    attachmentRanges ranges:Array<NSRange>
  ) {
    attachmentRanges = ranges
    super.init(attributedString: attributedString)
    self.textContentManager = textContentManager
    self.elementRange = elementRange
  }
  
}


