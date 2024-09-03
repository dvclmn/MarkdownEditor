//
//  Regex.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 20/8/2024.
//

//import RegexBuilder
import Foundation
import AppKit

//public typealias MarkdownRegex = Regex<(
//  Substring,
//  leading: Substring,
//  content: Substring,
//  trailing: Substring
//)>
//
//public typealias MarkdownStringRange = (
//  leading: Range<String.Index>,
//  content: Range<String.Index>,
//  trailing: Range<String.Index>
//)
//
//public typealias MarkdownNSTextRange = (
//  leading: NSTextRange?,
//  content: NSTextRange,
//  trailing: NSTextRange?
//)

//extension Markdown.Element {
  /// Let's convert `typealias MarkdownStringRange = (content: Range<String.Index>, syntax: Range<String.Index>)` to a tuple of `NSTextRange`
  ///
//  public static func markdownNSTextRange(
//    _ range: MarkdownStringRange,
//    in string: String,
//    syntax: Markdown.Syntax,
//    tcm: NSTextElementProvider
//  ) -> MarkdownNSTextRange? {
//    
//    guard let content = range.content.textRange(in: string, syntax: syntax, tcm: tcm),
//          let leading = range.leading.textRange(in: string, syntax: syntax, tcm: tcm),
//          let trailing = range.trailing.textRange(in: string, syntax: syntax, tcm: tcm)
//    else { return nil }
//    
//    let result: MarkdownNSTextRange = (leading, content, trailing)
//    
//    return result
//    
//  } // END markdownNSTextRange
  
  /// Trying out this version (overload) of the above `markdownNSTextRange`
  /// for times when I don't need the full tuple version.
  ///
//  public static func markdownNSTextRange(
//    _ range: NSTextRange,
//    in string: String,
//    syntax: Markdown.Syntax,
//    tcm: NSTextElementProvider
//  ) -> MarkdownNSTextRange? {
//    
//    let result: MarkdownNSTextRange = (nil, range, nil)
//    
//    return result
//    
//  } // END markdownNSTextRange
  
  
  
//}
