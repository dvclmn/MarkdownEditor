//
//  ParagraphInfo.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 17/9/2024.
//

import AppKit
import Rearrange
import Wrecktangle

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
    Range: \(range.info)
    String: \(string.trimmingCharacters(in: .whitespacesAndNewlines).preview(40))...
    """
    
    return output
  }
}


extension MarkdownTextView {
  
//  func updateParagraphInfo(firstSelected: NSRange?) {
//    
//    let nsString = self.string as NSString
//    let documentLength = nsString.length
//    
//    // Ensure the selected range is within bounds
//    let selectedRange: NSRange = firstSelected ?? self.selectedRange()
//    let safeSelectedRange = NSRange(
//      location: min(selectedRange.location, documentLength),
//      length: min(selectedRange.length, documentLength - selectedRange.location)
//    )
//    
//    // Calculate paragraph range safely
//    let paragraphRange = nsString.paragraphRange(for: safeSelectedRange)
//    let safeParagraphRange = NSRange(
//      location: min(paragraphRange.location, documentLength),
//      length: min(paragraphRange.length, documentLength - paragraphRange.location)
//    )
//    
//    // Get the text safely
//    guard let text = self.attributedSubstring(forProposedRange: safeParagraphRange, actualRange: nil)?.string else {
//      print("Couldn't get that text")
//      return
//    }
//    
//    var syntax: BlockSyntax
//    
//    if text.hasPrefix("#") {
//      
//      let headingLevel = text.prefix(while: { $0 == "#" }).count
//      
//      if headingLevel <= 6 && (text.count == headingLevel || text[text.index(text.startIndex, offsetBy: headingLevel)] == " ") {
//        syntax = BlockSyntax.heading(level: headingLevel)
//      } else {
//        syntax = BlockSyntax.heading(level: 1)
//      }
//      
//    } else if text.hasPrefix("- ") {
//      syntax = .list
//    } else {
//      // TODO: Implement more cases
//      syntax = .none
//    }
//    
//    let result = ParagraphInfo(string: text, range: safeParagraphRange, type: syntax)
//    
//    
////    let box = Box(header: "Paragraph Info", content: result.description + "Paragraph count: \(self)")
////    print(box)
//    
//    self.currentParagraph = result
//    
//  }
//  

  
}
