////
////  Ranges.swift
////  MarkdownEditor
////
////  Created by Dave Coleman on 13/8/2024.
////
//
//import SwiftUI

import AppKit



/// Having this here (at least for now) seems to avoid conflicts between `STTextKitPlus`
/// and `Rearrange`.
///





public extension Range where Bound == String.Index {

  func textRange(
    in string: String,
    syntax: Markdown.Syntax,
    tcm: NSTextElementProvider
  ) -> NSTextRange? {
    
    // Check if the range is valid for the given string
    guard self.lowerBound >= string.startIndex && self.upperBound <= string.endIndex else {
      print("Range is out of bounds for the given string")
      return nil
    }
    
    let documentLocation: NSTextLocation = tcm.documentRange.location
    
    // Use a safer method to get UTF-16 offsets
    let oldStart: Int = string.distance(from: string.startIndex, to: self.lowerBound)
    let oldEnd: Int = string.distance(from: string.startIndex, to: self.upperBound)

    // Ensure offsets are non-negative
    guard oldStart >= 0 && oldEnd >= 0 else {
      print("Calculated offsets are negative")
      return nil
    }

    
    guard let newStart = tcm.location?(documentLocation, offsetBy: oldStart),
          let newEnd = tcm.location?(documentLocation, offsetBy: oldEnd)
    else { return nil }
    
    let finalResult = NSTextRange(location: newStart, end: newEnd)
    
    return finalResult
    
  }
}
