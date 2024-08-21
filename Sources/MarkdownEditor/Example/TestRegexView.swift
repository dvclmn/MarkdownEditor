//
//  TestRegexView.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 20/8/2024.
//

import SwiftUI
import BaseHelpers
import RegexBuilder

struct RegexTestView: View {
  
  var body: some View {
    
    Text(self.attributedString)
      .padding(40)
      .frame(width: 600, height: 700)
      .background(.black.opacity(0.6))
  }
}

extension RegexTestView {
  
  func applyAttributes(
    to attributedString: inout AttributedString,
    range: Range<String.Index>,
    attributes: AttributeContainer
  ) {
    
    // Convert String.Index range to AttributedString.Index range
    let startIndex = AttributedString.Index(range.lowerBound, within: attributedString)
    let endIndex = AttributedString.Index(range.upperBound, within: attributedString)
    
    // Check if both indices are valid
    guard let start = startIndex, let end = endIndex else {
      print("Invalid range")
      return
    }
    
    // Create the AttributedString range
    let attributedStringRange = start..<end
    
    // Set the attributes
    attributedString[attributedStringRange].setAttributes(attributes)
  }
  
  var attributeContainer: AttributeContainer {
    var container = AttributeContainer()
    container.backgroundColor = .green.opacity(0.3)
    
    return container
  }
  
  var attributedString: AttributedString {
    let string = TestStrings.Markdown.anotherMarkdownString
    var attrString = AttributedString(string)
    
    
    
    
//    let regex = Regex {
//      
//      let syntax: Capture = Capture {
//        ChoiceOf {
//          "**"
//          "__"
//        }
//      }
//      
//      syntax
//      
//      Capture {
//        
//        OneOrMore(.reluctant) {
//          /./
//        }
//      }
//      
//      syntax
//    }
//      .anchorsMatchLineEndings()
//      .ignoresCase()
//    
//    let matches = string.matches(of: regex)
    
//    var attributedString = AttributedString("This is a test string")
    
//    let range = attributedString.string.range(of: "test")!
    

//    
//    for match in matches {
//      
//      let range = match.range
//      applyAttributes(to: &attrString, range: range, attributes: attributeContainer)
//      
//    }
    
    
    return attrString
  }
  
}


#Preview {
  RegexTestView()
}

//
//extension StringProtocol {
//  
//  func ranges<T: StringProtocol>(
//    of stringToFind: T,
//    options: String.CompareOptions = [],
//    locale: Locale? = nil
//  ) -> [Range<AttributedString.Index>] {
//    
//    // 1.
//    var ranges: [Range<String.Index>] = []
//    // 2.
//    var attributedRanges: [Range<AttributedString.Index>] = []
//    // 3.
//    let attributedString = AttributedString(self)
//    
//    while let result = range(
//      of: stringToFind,
//      options: options,
//      // 4.
//      range: (ranges.last?.upperBound ?? startIndex)..<endIndex,
//      locale: locale
//    ) {
//      // 5.
//      ranges.append(result)
//      
//      // 6.
//      let start = AttributedString.Index(result.lowerBound, within: attributedString)!
//      let end = AttributedString.Index(result.upperBound, within: attributedString)!
//      
//      // 7.
//      let attributedResult = start..<end
//      attributedRanges.append(attributedResult)
//    }
//    // 8.
//    return attributedRanges
//  }
//}
