//
//  Regex.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 20/8/2024.
//

//import RegexBuilder
import Foundation
import AppKit

public typealias MarkdownRegex = Regex<(
  Substring,
  leading: Substring,
  content: Substring,
  trailing: Substring
)>

public typealias MarkdownRegexOutput = Regex<MarkdownRegex>.RegexOutput
public typealias MarkdownRegexMatch = MarkdownRegexOutput.Match

extension Markdown.Syntax {
  
  
  var regexPattern: String? {
    
    /// This matches emphasised content, places it in a group,
    /// and ensures it doesn't add in other emphasis characters
    /// such as `*` and `_`
    let emphasisContent: String = "(.*?)"
    
    let italicSyntax: String = "(_|\\*)"
    let boldSyntax: String = "(__|\\*\\*)"
    let boldItalicSyntax: String = "(___|\\*\\*\\*)"
    
    return switch self {
        
      case .inlineCode: "(`)((?:[^`\n])+?)(`)"

      case .strikethrough: "(~~)([^~]*?)(~~)"
        
//      case .italic: italicSyntax + emphasisContent + italicSyntax
//      case .bold: boldSyntax + emphasisContent + boldSyntax
//      case .boldItalic: boldItalicSyntax + emphasisContent + boldItalicSyntax
        

      case .boldItalic: "(\\*{3}|_{3})(?=\\S)(.+?)(?<=\\S)\\1"
      case .bold: "(\\*{2}|_{2})(?=\\S)(.+?)(?<=\\S)\\1"
      case .italic: "(\\*|_)(?=\\S)(.+?)(?<=\\S)\\1"
        
        
        
        /// These were from Claude, and they crashed the view
//      case .boldItalic: "(_{3}|\\*{3})([^_|\\*]*?)(_{3}|\\*{3})"
//      case .bold: "(_{2}|\\*{2})(?:[^_|\\*]|_(?!_)|\\*(?!\\*))*?(_{2}|\\*{2})"
//      case .italic: "(_|\\*)(?:[^_|\\*]|_(?!_)|\\*(?!\\*))*?(_|\\*)"
      
        
      case .codeBlock: "(```(?:\\s*\\w+)?\n?)([\\s\\S]*?)(```)"
        
      default: nil
    }
  }
  
  var regexOptions: NSRegularExpression.Options {
    switch self {
      case .codeBlock:
        [.allowCommentsAndWhitespace, .anchorsMatchLines]
      default: []
    }
  }

  var nsRegex: NSRegularExpression? {

    guard let pattern = self.regexPattern else {
//      print("No regex pattern defined for \(self.name), so no need to create a `NSRegularExpression` object.")
      return nil
    }
    
    do {
      let regex = try NSRegularExpression(pattern: pattern, options: self.regexOptions)
      return regex
    } catch {
      print("Error creating regex for \(self): \(error)")
      return nil
    }
    

  }
  
  //  func matches(in text: String) -> [NSTextCheckingResult] {
  //
  //    guard let regex = regex else {
  //      return []
  //    }
  //
  //    let range = NSRange(text.startIndex..., in: text)
  //    return regex.matches(in: text, options: [], range: range)
  //  }
  
  //  func replaceMatches(in text: String, using block: (String, String, String) -> String) -> String {
  //    let mutableString = NSMutableString(string: text)
  //    let matches = matches(in: text)
  //
  //    for match in matches.reversed() {
  //      guard
  //        let leadingRange = Range(match.range(at: 1), in: text),
  //        let contentRange = Range(match.range(at: 2), in: text),
  //        let trailingRange = Range(match.range(at: 3), in: text)
  //      else { continue }
  //
  //      let leading = String(text[leadingRange])
  //      let content = String(text[contentRange])
  //      let trailing = String(text[trailingRange])
  //
  //      let replacement = block(leading, content, trailing)
  //      mutableString.replaceCharacters(in: match.range, with: replacement)
  //    }
  //
  //    return String(mutableString)
  //  }
  
  //  var nsRegex: String? {
  //
  //    switch self {
  //      case .bold:
  //        "(?<leading>__|\\*\\*)(?<content>[^_|\\*]*?)(?<trailing>__|\\*\\*)"
  //      case .italic:
  //        "(?<leading>_|\\*)(?<content>[^_|\\*]*?)(?<trailing>_|\\*)"
  //      case .boldItalic:
  //        "(?<leading>___|\\*\\*\\*)(?<content>[^_|\\*]*?)(?<trailing>___|\\*\\*\\*)"
  //      case .strikethrough:
  //        "(?<leading>~~)(?<content>[^~]*?)(?<trailing>~~)"
  //      case .highlight:
  //        "(?<leading>==)(?<content>[^=]*?)(?<trailing>==)"
  //      case .inlineCode:
  //        "(?<leading>`)(?<content>(?:[^`\\n])+?)(?<trailing>`)"
  //      case .quoteBlock:
  //        "(?<leading>^>)(?<content>[^>\\n]+)(?<trailing>)"
  //      case .link:
  //        "(?<leading>\\[)(?<content>[^\\]]+)(?<trailing>\\]\\([^\\)]+\\))"
  //      case .image:
  //        "(?<leading>!\\[)(?<content>[^\\]]+)(?<trailing>\\]\\([^\\)]+\\))"
  //      case .list, .heading, .horizontalRule, .codeBlock:
  //        nil
  //    }
  //  }
  
  
  public var regexLiteral: MarkdownRegex? {
    switch self {
        
        /// `^# ` The caret ensures this only matches if the string starts on a new line
        /// The `$` matches the end of a line.
        ///
      case .heading:
        return nil
        
      case .bold:
        
        return /(?<leading>__|\*\*)(?<content>[^_|\*]*?)(?<trailing>__|\*\*)/
        //        switch style {
        
        /// `[^\*]` This is a 'negated set' or 'negated character class'. The caret here means 'match
        /// anything that *isn't* the following character(s). The character being negated is an asterisk,
        /// which needs to be escaped, hence the backslash.
        ///
        /// The non-escaped asterisk (the one performing an active role in the regex!) is a 'quantifier'.
        /// It means 'match zero or more of the preceding token'. The question mark `?` makes the
        /// expression 'lazy' / 'non-greedy' / 'reluctant'. It will match as few characters as possible,
        /// preventing the match from spilling out and finding matches that — depending on your
        /// needs — you may not want to have matched.
        ///
        //          case .asterisk:
        //            return /\*\*[^\*]*?\*\*/
        
        /// Matches bold text with underscores: Two underscores, followed by any characters (non-greedy), ending with two underscores
        ///
        //          case .underscore:
        //            return /__[^_]*?__/
        
      case .italic:
        return /(?<leading>_|\*)(?<content>[^_|\*]*?)(?<trailing>_|\*)/
        
      case .boldItalic:
        return /(?<leading>___|\*\*\*)(?<content>[^_|\*]*?)(?<trailing>___|\*\*\*)/
        
        
        /// Matches strikethrough text: Two tildes, followed by any characters (non-greedy), ending with two tildes
      case .strikethrough:
        return /(?<leading>~~)(?<content>[^~]*?)(?<trailing>~~)/
        
        /// Matches highlighted text: Two equal signs, followed by any characters (non-greedy), ending with two equal signs
      case .highlight:
        return /(?<leading>==)(?<content>[^=]*?)(?<trailing>==)/
        
        /// Matches inline code: A backtick, followed by one or more characters that are not newlines or backticks,
        /// not followed by two backticks, ending with a backtick not followed by another backtick
        /// Note: This complex pattern ensures that it doesn't match multi-line code blocks or nested backticks
      case .inlineCode:
        return /(?<leading>`)(?<content>(?:[^`\n])+?)(?<trailing>`)/
        
        /// Matches a simple list item: A hyphen followed by a space and any characters until the end of the line
        /// Note: This is a placeholder and needs proper implementation for nested lists
      case .list:
        return nil
        
        /// Matches a horizontal rule: Three hyphens
      case .horizontalRule:
        return nil
        
        /// Matches a code block: Starts with three backticks, includes any characters (including newlines),
        /// and ends with three backticks at the start of a line
        /// Note: (?m) enables multiline mode, [\s\S] matches any character including newlines
      case .codeBlock:
        //        return /(?<leading>```)(?<content>.*?)(?<trailing>```)/.dotMatchesNewlines()
        return /(?<leading>```[a-zA-Z]*)\n(?<content>.*?)(?<trailing>```)/.dotMatchesNewlines()
        
        /// Matches a quote block: A '>' followed by a space at the start of a line, then any characters until the end of the line
      case .quoteBlock:
        return /(?<leading>^>)(?<content>[^>\n]+)(?<trailing>)/
        
        /// Matches a link: Text in square brackets followed by a URL in parentheses
        /// Note: `[^\]]+` matches one or more characters that are not closing square brackets
        /// `[^\)]+` matches one or more characters that are not closing parentheses
      case .link:
        return  /(?<leading>\[)(?<content>[^\]]+)(?<trailing>\]\([^\)]+\))/
        
        /// Matches an image reference: Similar to a link, but prefixed with an exclamation mark
        /// Note: The pattern is identical to the link pattern, just with a leading '!'
        ///
      case .image:
        return  /(?<leading>!\[)(?<content>[^\]]+)(?<trailing>\]\([^\)]+\))/
    }
  }
  
  
}
