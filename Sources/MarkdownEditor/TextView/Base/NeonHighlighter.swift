//
//  TextViewHighlighter.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 15/2/2025.
//

import AppKit
import Neon
import SwiftTreeSitter
import TreeSitterMarkdown
import TreeSitterMarkdownInline
import TreeSitterSwift

extension MarkdownController {
  static func makeHighlighter(
    for textView: NSTextView,
    with config: EditorConfiguration
  ) throws -> TextViewHighlighter {

    textView.typingAttributes = config.defaultTypingAttributes
    
    
    
//    let markdownConfig = try LanguageConfiguration(
//      tree_sitter_markdown(),
//      name: "Markdown"
//    )
//    let markdownInlineConfig = try LanguageConfiguration(
//      tree_sitter_markdown_inline(),
//      name: "Markdown Inline"
//    )
    
    let provider: TokenAttributeProvider = { token in
      
      print("Token: \(token)")
      
      return switch token.name {
        case let keyword where keyword.hasPrefix("punctuation"): [.foregroundColor: NSColor.red]
        case let keyword where keyword.hasPrefix("text.title"): [.foregroundColor: NSColor.green]
        case let keyword where keyword.hasPrefix("text.literal"): [.foregroundColor: NSColor.purple]
        default: [.foregroundColor: NSColor.blue]
      }
    }
    
    let swiftConfig = try LanguageConfiguration(
      tree_sitter_swift(),
      name: "Swift"
    )
    
    let highlighterConfig = TextViewHighlighter.Configuration(
      languageConfiguration: swiftConfig,
      attributeProvider: provider,
      languageProvider: { name in
        
        print("embedded language: ", name)
        
        switch name {
          case "swift":
            return swiftConfig
          default:
            return nil
        }
      },
      locationTransformer: { _ in nil }
    )
    
    return try TextViewHighlighter(textView: textView, configuration: highlighterConfig)
    
    
    
    

//    textView.typingAttributes = config.defaultTypingAttributes
//
//    let markdownConfig = try LanguageConfiguration(
//      tree_sitter_markdown(),
//      name: "Markdown"
//    )
//    let markdownInlineConfig = try LanguageConfiguration(
//      tree_sitter_markdown_inline(),
//      name: "Markdown Inline",
//      bundleName: "TreeSitterMarkdown_TreeSitterMarkdownInline"
//    )
//    let swiftConfig = try LanguageConfiguration(
//      tree_sitter_swift(),
//      name: "Swift",
//      bundleName: "TreeSitterSwift_TreeSitterSwift"
//    )
//
//    let provider: TokenAttributeProvider = { token in

      //      let codeBlockElements = textView.elements.filter { $0.syntax == .codeBlock }

      // Check if the token's range intersects with any code block range
      //      let intersectsCodeBlock = codeBlockElements.contains { element in
      //        token.range.intersection(element.ranges.content) != nil
      //      }

      //      if intersectsCodeBlock {
      //
      //        //            let string = textView.attributedSubstring(forProposedRange: token.range, actualRange: nil)
      //
      //        print("Token: \(token)")
      //        //            print("String: \(string?.string ?? "nil")\n")
      //
      //        return switch token.name {
      //
      //          case "include": [.foregroundColor: NSColor.xcodePink]
      //
      //          case "spell", "comment": [.foregroundColor: NSColor.gray]
      //          case "keyword": [
      //            .foregroundColor: NSColor.xcodePink,
      //            .font: NSFont.boldSystemFont(ofSize: 12)
      //          ]
      //
      //          default: [.foregroundColor: NSColor.cyan]
      //
      //        }
      //
      //      } else {
      //        // Return empty dictionary or default styling for non-code-block tokens
      //
//      return switch token.name {
//        case "punctuation.delimiter": [.foregroundColor: NSColor.red]
//        /// ❤️ — Default leading/trailing syntax characters, e.g. `~`, `*`
//        case "punctuation.special": [.foregroundColor: NSColor.yellow]
//        /// 💛 — Heading `#` and list `-`
//        case "text.title": [.foregroundColor: NSColor.green]
//        /// 💚 — Heading text
//        case "text.literal": [.foregroundColor: NSColor.purple]
//        /// 💜 — Default 'code' text
//        case "text.emphasis": [.foregroundColor: NSColor.cyan]
//        /// 🩵 — Italics
//        case "text.strong": [.foregroundColor: NSColor.brown]
//        /// 🤎 — Bold
//        case "text.uri": [.foregroundColor: NSColor.magenta]
//        /// 🩷 — Links
//        case "text.reference": [.foregroundColor: NSColor.gray]
//        /// 🩶 — Link label e.g. `[label](http://link.com)`
//        case "none": [.foregroundColor: NSColor.orange]
//        /// 🧡 — Also seems related to 'code' text?
//        ///
//        default: [.foregroundColor: NSColor.blue]
//      }  // END switch and return
//      //      } // END code block check


//    }

//    let highlighterConfig = TextViewHighlighter.Configuration(
//      languageConfiguration: markdownConfig,
//      attributeProvider: provider,
//      languageProvider: { name in
//
//        switch name {
//          case "markdown_inline":
//            print("Found inline markdown grammar.")
//            return markdownInlineConfig
//
//          case "swift":
//            print("Found swift grammar")
//            return swiftConfig
//
//          default:
//            return nil
//        }
//      },
//
//      locationTransformer: { _ in nil }
//    )
//
//    return try TextViewHighlighter(textView: textView, configuration: highlighterConfig)

  }
  //    let regularFont = NSFont.monospacedSystemFont(ofSize: 16, weight: .regular)
  //    let boldFont = NSFont.monospacedSystemFont(ofSize: 16, weight: .bold)
  ////    let italicDescriptor = regularFont.fontDescriptor.withSymbolicTraits(.traitItalic) ?? regularFont.fontDescriptor
  //
  ////    let italicFont = NSFont(descriptor: italicDescriptor, size: 16) ?? regularFont
  //
  //    // Set the default styles. This is applied by stock `NSTextStorage`s during
  //    // so-called "attribute fixing" when you type, and we emulate that as
  //    // part of the highlighting process in `TextViewSystemInterface`.
  //    textView.typingAttributes = [
  //      .foregroundColor: NSColor.darkGray,
  //      .font: regularFont,
  //    ]
  //
  //    let provider: TokenAttributeProvider = { token in
  //      return switch token.name {
  //        case let keyword where keyword.hasPrefix("keyword"): [.foregroundColor: NSUIColor.red, .font: boldFont]
  //        case "comment", "spell": [.foregroundColor: NSUIColor.green, .font: italicFont]
  //          // Note: Default is not actually applied to unstyled/untokenized text.
  //        default: [.foregroundColor: NSUIColor.blue, .font: regularFont]
  //      }
  //    }
  //
  //    // this is doing both synchronous language initialization everything, but TreeSitterClient supports lazy loading for embedded languages
  //    let markdownConfig = try! LanguageConfiguration(
  //      tree_sitter_markdown(),
  //      name: "Markdown"
  //    )
  //
  //    let markdownInlineConfig = try! LanguageConfiguration(
  //      tree_sitter_markdown_inline(),
  //      name: "MarkdownInline",
  //      bundleName: "TreeSitterMarkdown_TreeSitterMarkdownInline"
  //    )
  //
  //    let swiftConfig = try! LanguageConfiguration(
  //      tree_sitter_swift(),
  //      name: "Swift"
  //    )
  //
  //    let highlighterConfig = TextViewHighlighter.Configuration(
  //      languageConfiguration: swiftConfig, // the root language
  //      attributeProvider: provider,
  //      languageProvider: { name in
  //        print("embedded language: ", name)
  //
  //        switch name {
  //          case "swift":
  //            return swiftConfig
  //          case "markdown_inline":
  //            return markdownInlineConfig
  //          default:
  //            return nil
  //        }
  //      },
  //      locationTransformer: { _ in nil }
  //    )
  //
  //    return try TextViewHighlighter(textView: textView, configuration: highlighterConfig)
  //  }

}

extension NSColor {
  static let lightBlue = NSColor(#colorLiteral(red: 0.5372549295425415, green: 0.8666666746139526, blue: 0.9843137264251709, alpha: 1))
  static let darkGrey = NSColor(#colorLiteral(red: 0.14509804546833038, green: 0.14509804546833038, blue: 0.16470588743686676, alpha: 1))
  static let xcodePink = NSColor(#colorLiteral(red: 0.9333333373069763, green: 0.5058823823928833, blue: 0.6901960968971252, alpha: 1))
  static let offWhite = NSColor(#colorLiteral(red: 0.8705882430076599, green: 0.8745098114013672, blue: 0.8745098114013672, alpha: 1))
  static let xcodePurple = NSColor(#colorLiteral(red: 0.6705882549285889, green: 0.5137255191802979, blue: 0.8941176533699036, alpha: 1))
  static let xcodeMint = NSColor(#colorLiteral(red: 0.729411780834198, green: 0.9411764740943909, blue: 0.8941176533699036, alpha: 1))
  
}
