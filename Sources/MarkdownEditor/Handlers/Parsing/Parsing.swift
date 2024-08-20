//
//  Parsing.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import AppKit
import BaseHelpers

extension MarkdownTextView {
  
  func applyMarkdownStyles() async {
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager,
          let viewportRange = tlm.textViewportLayoutController.viewportRange
    else { return }
    
    self.parsingTask?.cancel()
    self.parsingTask = Task {
      
      tcm.performEditingTransaction {
        for element in self.elements where element.range.intersects(viewportRange) {
          tlm.setRenderingAttributes(element.type.contentAttributes, for: element.range)
        }
      } // END perform editing
    } // END task
  }
  
  
  func parseMarkdown(
    in range: NSTextRange? = nil
  ) async {
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager
    else { return }
    
    let searchRange = range ?? tlm.documentRange
    
    self.parsingTask?.cancel()
    
    self.parsingTask = Task {
      
      self.parsingTask = Task {
        self.elements.removeAll()
        self.rangeIndex.removeAll()
        
        for syntax in Markdown.Syntax.testCases {
          let newElements = self.string.markdownMatches(
            of: syntax,
            in: searchRange,
            textContentManager: tcm
          )
          
          newElements.forEach { self.addElement($0) }
        }
        self.elements.sort { $0.range.location.compare($1.range.location) == .orderedAscending }
      } // END task
    }
    
    await self.parsingTask?.value
    
  }

  

}





extension Regex<Regex<(Substring, Substring)>.RegexOutput>.Match {
  var prettyDescription: String {
    var result = "Match:\n"
    result += "  Range: \(self.range)\n"
    result += "  Matched text: \"\(self.0)\"\n"
    if !self.1.isEmpty {
      result += "  Captured group: \"\(self.1)\"\n"
    }
    result += "  Output:\n"
    result += "    Full match: \"\(self.output.0)\"\n"
    result += "    Capture: \"\(self.output.1)\"\n"
    return result
  }
}

extension Regex<Regex<Substring>.RegexOutput>.Match {
  var prettyDescription: String {
    var result = "Match:\n"
    result += "  Range: \(self.range)\n"
    result += "  Matched text: \"\(self)\"\n"
    
    result += "  Output:\n"
    result += "    Full match: \"\(self.output)\"\n"
    return result
  }
}



extension String {
  
  func markdownMatches(
    of syntax: Markdown.Syntax,
    in range: NSTextRange? = nil,
    textContentManager tcm: NSTextContentManager
  ) -> [Markdown.Element] {
    
    /// If no range is supplied, we default to the `documentRange`
    ///
    let textRange = range ?? tcm.documentRange
    
    let nsRange = NSRange(textRange, in: tcm)
    
    guard let stringRange = nsRange.range(in: self) else {
      print("Couldn't get `Range<String.Index>` from NSRange")
      return []
    }
    
    var elements: [Markdown.Element] = []
    
    for match in self[stringRange].matches(of: syntax.regex) {
      
      print("Original string: \(self)")
      print("Document range: \(textRange)")
      print(match.prettyDescription)
      
      let matchRange: Range<String.Index> = match.range
      let matchStart: Int = matchRange.lowerBound.utf16Offset(in: self)
      
      /// Both parameters in `String.distance(from:to:)`
      /// ask for a value of type `String.Index`
      ///
      /// ```
      /// func distance(
      ///   from start: String.Index,
      ///   to end: String.Index
      /// ) -> Int
      ///```
      ///
      let matchLength: Int = self.distance(
        from: matchRange.lowerBound,
        to: matchRange.upperBound)
      
      let offsetRange = NSRange(
        location: nsRange.location + matchStart,
        length: matchLength
      )
      
      guard let matchTextRange = NSTextRange(offsetRange, in: tcm) else { continue }
      
      if isValidMarkdownElement(syntax: syntax, match: match) {
        let element = Markdown.Element(type: syntax, range: matchTextRange)
        elements.append(element)
      }
    }
    
    return elements
  }

  
  
  func isValidMarkdownElement(syntax: Markdown.Syntax, match: MarkdownRegexOutput.Match) -> Bool {
    
    let fullMatch = String(self[match.range])
    
    switch syntax {
      case .heading(let level):
        // Check if the heading has the correct number of '#' symbols
        return fullMatch.hasPrefix(String(repeating: "#", count: level))
        
      case .bold(let style), .italic(let style), .boldItalic(let style):
        let (start, end) = delimiterPair(for: syntax, style: style)
        return fullMatch.hasPrefix(start) && fullMatch.hasSuffix(end)
        
      case .strikethrough:
        return fullMatch.hasPrefix("~~") && fullMatch.hasSuffix("~~")
        
      case .highlight:
        return fullMatch.hasPrefix("==") && fullMatch.hasSuffix("==")
        
      case .inlineCode:
        return fullMatch.hasPrefix("`") && fullMatch.hasSuffix("`")
        
      case .list(let style):
        switch style {
          case .ordered:
            // Check if it starts with a number followed by a dot and space
            return fullMatch.matches(of: /^\d+\.\s/).count > 0
          case .unordered:
            // Check if it starts with '- ', '* ', or '+ '
            return ["- ", "* ", "+ "].contains { fullMatch.hasPrefix($0) }
        }
        
      case .horizontalRule:
        // Check for at least 3 hyphens, asterisks, or underscores
        return ["---", "***", "___"].contains { fullMatch.hasPrefix($0) }
        
      case .codeBlock(let language):
        // Check for triple backticks, optionally followed by a language hint
        return fullMatch.hasPrefix("```") && (language == nil || fullMatch.hasPrefix("```\(language?.rawValue ?? "")"))
        
      case .quoteBlock:
        // Check if it starts with '> '
        return fullMatch.hasPrefix("> ")
        
      case .link, .image:
        // Basic check for markdown link/image syntax
        return fullMatch.matches(of: /\[.*\]\(.*\)/).count > 0
    }
  }
  
  private func delimiterPair(for syntax: Markdown.Syntax, style: Markdown.Syntax.EmphasisStyle) -> (String, String) {
    let delimiter: String
    switch (syntax, style) {
      case (.bold, .asterisk), (.boldItalic, .asterisk):
        delimiter = "**"
      case (.bold, .underscore), (.boldItalic, .underscore):
        delimiter = "__"
      case (.italic, .asterisk):
        delimiter = "*"
      case (.italic, .underscore):
        delimiter = "_"
      default:
        delimiter = ""
    }
    return (delimiter, delimiter)
  }

  
}

