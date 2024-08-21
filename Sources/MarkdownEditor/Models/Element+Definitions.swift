//
//  ElementDefinitions.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 21/8/2024.
//

extension Markdown {
  public static let allSyntax: [AnyMarkdownElement] = [
    Markdown.Heading.heading1,
    Markdown.Heading.heading2,
    Markdown.Heading.heading3,
    Markdown.Heading.heading4,
    Markdown.Heading.heading5,
    Markdown.Heading.heading6,
    
    Markdown.InlineSymmetrical.bold,
    Markdown.InlineSymmetrical.italic,
    Markdown.InlineSymmetrical.boldItalic,
    Markdown.InlineSymmetrical.inlineCode,
    Markdown.InlineSymmetrical.strikethrough
  ]
}

extension Markdown.Heading {
  
  public static let heading1 = Markdown.Heading(
    level: 1,
    regex: /^# .*$/
  )
  public static let heading2 = Markdown.Heading(
    level: 2,
    regex: /^## .*$/
  )
  public static let heading3 = Markdown.Heading(
    level: 3,
    regex: /^### .*$/
  )
  public static let heading4 = Markdown.Heading(
    level: 4,
    regex: /^#### .*$/
  )
  public static let heading5 = Markdown.Heading(
    level: 5,
    regex: /^##### .*$/
  )
  public static let heading6 = Markdown.Heading(
    level: 6,
    regex: /^###### .*$/
  )
}

extension Markdown.InlineSymmetrical {
  public static let bold = Markdown.InlineSymmetrical(
    type: .bold,
    
    /// The pipe `|` denotes a boolean 'or', so `__|\*\*` just means
    /// either match two underscores, or two asterisks.
    ///
    /// The parentheses form capture groups, which correspond directly to
    /// the `Substring`s defined in:
    /// `Regex<(Substring, Substring, Substring, Substring)>`
    ///
    /// Note: there are 4 substrings in `Markdown.InlineSymmetrical`s
    /// regex property, and three capture groups below; this is because the first
    /// `Substring` represents the *full match*. The three subsequent
    /// substrings then match the three capture groups, as defined below.
    ///
    regex: /(__|\*\*)([^_|\*]*?)(__|\*\*)/
  )
  
  public static let italic = Markdown.InlineSymmetrical(
    type: .italic,
    regex: /(_|\*)([^_|\*]*?)(_|\*)/
  )
  
  public static let boldItalic = Markdown.InlineSymmetrical(
    type: .boldItalic,
    regex: /(___|\*\*\*)([^_|\*]*?)(___|\*\*\*)/
  )
  
  public static let inlineCode = Markdown.InlineSymmetrical(
    type: .inlineCode,
    regex: /(`)((?:[^`\n])+?)(`)/
  )
  
  public static let strikethrough = Markdown.InlineSymmetrical(
    type: .strikethrough,
    regex: /(~~)([^~\n]*?)(~~)/
  )
}
