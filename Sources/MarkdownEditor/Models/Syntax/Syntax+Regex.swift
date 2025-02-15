//
//  Regex.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 20/8/2024.
//

import AppKit

extension Markdown.Syntax {

  public var regexPattern: String? {

    let emphasisContent: String = "(.*?)"

    let italicSyntax: String = "(_|\\*)"
    let boldSyntax: String = "(__|\\*\\*)"
    let boldItalicSyntax: String = "(___|\\*\\*\\*)"

    return switch self {
        
      case .heading(let level): "^(#{\(level)})\\s+(.+)"
      case .inlineCode: "(`)((?:[^`\n])+?)(`)"
      case .strikethrough: "(~~)([^~]*?)(~~)"
      case .italic: italicSyntax + emphasisContent + italicSyntax
      case .bold: boldSyntax + emphasisContent + boldSyntax
      case .boldItalic: boldItalicSyntax + emphasisContent + boldItalicSyntax
      case .codeBlock: "(```(?:\\s*\\w+\\s?)\n)([\\s\\S]*?)(\\n```)"
      case .highlight: "==([^=]+)==(?!=)"
//      case .highlight: "(?<!=)==([^=]+)==(?!=)"
//      case .highlight: "(==)([^=]*?)(==)"
      case .list: "^\\s{0,3}([-*]|\\d+\\.)\\s+(.+)$"
      case .horizontalRule: "^[-*_]{3,}$"
      case .quoteBlock: "^>\\s*(.+)"
      case .link: "(\\[)(.*?)(\\]\\()(.*?)(\\))"
      case .image: "(!\\[)(.*?)(\\]\\()(.*?)(\\))"
    }
  }

  public var regexOptions: NSRegularExpression.Options {
    switch self {
      case .codeBlock:
        [.allowCommentsAndWhitespace, .anchorsMatchLines]
      default: [.anchorsMatchLines]
    }
  }

  public var nsRegex: NSRegularExpression? {
    guard let pattern = self.regexPattern else { return nil }

    do {
      let regex = try NSRegularExpression(pattern: pattern, options: self.regexOptions)
      return regex
    } catch {
      print("Error creating regex for \(self): \(error)")
      return nil
    }
  }
}
