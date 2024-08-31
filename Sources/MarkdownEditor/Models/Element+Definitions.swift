//
//  ElementDefinitions.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 21/8/2024.
//

//
//extension Markdown.InlineSymmetrical {
//  public static let bold = Markdown.InlineSymmetrical(
//    type: .bold,
//    
//    /// The pipe `|` denotes a boolean 'or', so `__|\*\*` just means
//    /// either match two underscores, or two asterisks.
//    ///
//    /// The parentheses form capture groups, which correspond directly to
//    /// the `Substring`s defined in:
//    /// `Regex<(Substring, Substring, Substring, Substring)>`
//    ///
//    /// Note: there are 4 substrings in `Markdown.InlineSymmetrical`s
//    /// regex property, and three capture groups below; this is because the first
//    /// `Substring` represents the *full match*. The three subsequent
//    /// substrings then match the three capture groups, as defined below.
//    ///
//    regex: /(__|\*\*)([^_|\*]*?)(__|\*\*)/
//  )
//  
//  public static let italic = Markdown.InlineSymmetrical(
//    type: .italic,
//    regex: /(_|\*)([^_|\*]*?)(_|\*)/
//  )
//  
//  public static let boldItalic = Markdown.InlineSymmetrical(
//    type: .boldItalic,
//    regex: /(___|\*\*\*)([^_|\*]*?)(___|\*\*\*)/
//  )
//  
//  public static let inlineCode = Markdown.InlineSymmetrical(
//    type: .inlineCode,
//    regex: /(`)((?:[^`\n])+?)(`)/
//  )
//  
//  public static let strikethrough = Markdown.InlineSymmetrical(
//    type: .strikethrough,
//    regex: /(~~)([^~\n]*?)(~~)/
//  )
//}
