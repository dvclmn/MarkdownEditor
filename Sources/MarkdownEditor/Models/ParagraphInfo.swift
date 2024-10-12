//
//  ParagraphInfo.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 17/9/2024.
//

import AppKit
import Rearrange
import Wrecktangle

@MainActor
struct ParagraphHandler: Sendable {
  
  private(set) var currentParagraph: ParagraphInfo
  private(set) var previousParagraph: ParagraphInfo
  
  init() {
    self.currentParagraph = .zero
    self.previousParagraph = .zero
  }
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

extension ParagraphInfo {
  public static let zero = ParagraphInfo()
}

extension ParagraphInfo: CustomStringConvertible {
  var description: String {
    
    // - Selected: \(Date.now.friendlyDateAndTime)
    let output: String = """
    
      - Range: \(range.info)
      - Type: \(type)
      - String: \(string.trimmingCharacters(in: .whitespacesAndNewlines).preview(40, hasDividers: false))
    """
    
    return output
  }
}

extension ParagraphHandler {
  
  mutating func updateParagraphInfo(using textView: MarkdownTextView) {
    
    print("Going to try and update paragraph info")
    
    let paragraphRange: NSRange = textView.nsString.paragraphRange(for: textView.safeSelectedRange)
    
    let safeCurrentParagraphRange: NSRange = paragraphRange.clamped(to: textView.documentLength)

    guard let currentParagraphText = textView.attributedSubstring(forProposedRange: safeCurrentParagraphRange, actualRange: nil)?.string else {
      print("Couldn't get that text")
      return
    }
    
    /// Update previous paragraph
    self.previousParagraph = self.currentParagraph
    
    let blockSyntax = self.identifyBlockSyntax(for: currentParagraphText)
    
    let result = ParagraphInfo(
      string: currentParagraphText,
      range: safeCurrentParagraphRange,
      type: blockSyntax
    )

    self.currentParagraph = result
    
  }
  
  func identifyBlockSyntax(for text: String) -> BlockSyntax {
    
    var syntax: BlockSyntax
    
    if text.hasPrefix("#") {
      
      let headingLevel = text.prefix(while: { $0 == "#" }).count
      
      if headingLevel <= 6 && (text.count == headingLevel || text[text.index(text.startIndex, offsetBy: headingLevel)] == " ") {
        syntax = BlockSyntax.heading(level: headingLevel)
      } else {
        syntax = BlockSyntax.heading(level: 1)
      }
      
    } else if text.hasPrefix("- ") {
      syntax = .list
    } else {
      // TODO: Implement more cases
      syntax = .none
    }
    return syntax
    
  } // END identify syntax
  

  
} // END paragraph handler extension
