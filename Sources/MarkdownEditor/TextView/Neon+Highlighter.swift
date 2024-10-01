//
//  Neon+Highlighter.swift
//  Banksia
//
//  Created by Dave Coleman on 10/9/2024.
//


import AppKit

import Neon
import TreeSitterMarkdown
//import TreeSitterMarkdownInline
import SwiftTreeSitter
import TreeSitterClient

extension MarkdownViewController {
  
  
  @MainActor static func makeHighlighter(for textView: MarkdownTextView) throws -> TextViewHighlighter {
    
    textView.typingAttributes = textView.configuration.defaultTypingAttributes
    
    let markdownConfig = try LanguageConfiguration(
      tree_sitter_markdown(),
      name: "Markdown"
    )
//    let markdownInlineConfig = try LanguageConfiguration(
//      tree_sitter_markdown_inline(),
//      name: "Markdown Inline",
//      bundleName: "TreeSitterMarkdown_TreeSitterMarkdownInline"
//    )
    
    let provider: TokenAttributeProvider = { token in
      
//      let string = textView.attributedSubstring(forProposedRange: token.range, actualRange: nil)
      
//      print("Token: \(token)")
//      print("String: \(string?.string ?? "nil")\n")
      
      return switch token.name {
          
        case "punctuation.delimiter":  [.foregroundColor: NSColor.red]      /// ❤️ — Default leading/trailing syntax characters, e.g. `~`, `*`
        case "punctuation.special":    [.foregroundColor: NSColor.yellow]   /// 💛 — Heading `#` and list `-`
        case "text.title":             [.foregroundColor: NSColor.green]    /// 💚 — Heading text
        case "text.literal":           [.foregroundColor: NSColor.purple]   /// 💜 — Default 'code' text
        case "text.emphasis":          [.foregroundColor: NSColor.cyan]     /// 🩵 — Italics
        case "text.strong":            [.foregroundColor: NSColor.brown]    /// 🤎 — Bold
        case "text.uri":               [.foregroundColor: NSColor.magenta]  /// 🩷 — Links
        case "text.reference":         [.foregroundColor: NSColor.gray]     /// 🩶 — Link label e.g. `[label](http://link.com)`
        case "none":                   [.foregroundColor: NSColor.orange]   /// 🧡 — Also seems related to 'code' text?

        default: [.foregroundColor: NSColor.blue]
          
      }
    }
    
    let highlighterConfig = TextViewHighlighter.Configuration(
      languageConfiguration: markdownConfig,
      attributeProvider: provider,
//      languageProvider: { name in
//        
////        print("Embedded language: ", name)
//        
//        switch name {
////          case "markdown_inline": // tried both this and "Markdown Inline"
////          case "Markdown Inline":
////            print("Let's fire up markdown inline")
////            return markdownInlineConfig
//          default:
//            return nil
//        }
//      },
      locationTransformer: { _ in nil }
    )
    
    return try TextViewHighlighter(textView: textView, configuration: highlighterConfig)
    
  }
  
  
  
//    func neonSetup() throws {
//  
//      let languageConfig = try LanguageConfiguration(
//        tree_sitter_markdown(),
//        name: "Markdown"
//      )
//  
//      let clientConfig = TreeSitterClient.Configuration(
//        languageProvider: { identifier in
//          print("Nested languages? \(identifier)")
//          return languageConfig
//        },
//        contentProvider: { [textView] length in
//  
//          print("contentProvider `length`: \(length.description)")
//  
//          return .init(string: textView.string)
//        },
//        lengthProvider: { [textView] in
//          textView.string.utf16.count
//  
//        },
//        invalidationHandler: { set in
//          print("Invalidations: \(set)")
//        },
//        locationTransformer: { location in
//  
//          return nil
//        }
//      )
//  
//      let client = try TreeSitterClient(
//        rootLanguageConfig: languageConfig,
//        configuration: clientConfig
//      )
//  
//      let source = textView.string
//  
//      let provider = source.predicateTextProvider
//  
//      Task { @MainActor in
//  
//        let highlights = try await client.highlights(in: textView.visibleTextRange, provider: provider)
//  
//        print("Highlights: ", highlights)
//      }
//  
//    } // END neon setup
}
