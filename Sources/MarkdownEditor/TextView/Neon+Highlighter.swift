//
//  Neon+Highlighter.swift
//  Banksia
//
//  Created by Dave Coleman on 10/9/2024.
//


import AppKit

import Neon
import TreeSitterMarkdown
import TreeSitterMarkdownInline
import TreeSitterSwift
import SwiftTreeSitter
import TreeSitterClient

extension MarkdownViewController {
  
  
  @MainActor static func makeHighlighter(for textView: MarkdownTextView) throws -> TextViewHighlighter {
    
    //    print("Let's set up `TextViewHighlighter`.")
    
    //    textView.typingAttributes = textView.configuration.defaultTypingAttributes
    
    let markdownConfig = try LanguageConfiguration(
      tree_sitter_markdown(),
      name: "Markdown"
    )
    let markdownInlineConfig = try LanguageConfiguration(
      tree_sitter_markdown_inline(),
      name: "Markdown Inline",
      bundleName: "TreeSitterMarkdown_TreeSitterMarkdownInline"
    )
    let swiftConfig = try LanguageConfiguration(
      tree_sitter_swift(),
      name: "Swift",
      bundleName: "TreeSitterSwift_TreeSitterSwift"
    )
    
    let provider: TokenAttributeProvider = { token in
      
      let codeBlockElements = textView.elements.filter { $0.syntax == .codeBlock }
      
      // Check if the token's range intersects with any code block range
      let intersectsCodeBlock = codeBlockElements.contains { element in
        token.range.intersection(element.ranges.content) != nil
      }
      
      if intersectsCodeBlock {
        
        //            let string = textView.attributedSubstring(forProposedRange: token.range, actualRange: nil)
        
        print("Token: \(token)")
        //            print("String: \(string?.string ?? "nil")\n")
        
        return switch token.name {
            
          case "include": [.foregroundColor: NSColor.xcodePink]
            
          case "spell", "comment": [.foregroundColor: NSColor.gray]
          case "keyword": [
            .foregroundColor: NSColor.xcodePink,
            .font: NSFont.boldSystemFont(ofSize: 12)
          ]
            
          default: [.foregroundColor: NSColor.cyan]
            
        }
        
      } else {
        // Return empty dictionary or default styling for non-code-block tokens
        
        return switch token.name {
//          case "punctuation.delimiter":   [.foregroundColor: NSColor.red]      /// ❤️ — Default leading/trailing syntax characters, e.g. `~`, `*`
          case "punctuation.special":     [.foregroundColor: NSColor.yellow]   /// 💛 — Heading `#` and list `-`
          case "text.title":              [.foregroundColor: NSColor.green]    /// 💚 — Heading text
          case "text.literal":            [.foregroundColor: NSColor.purple]   /// 💜 — Default 'code' text
          case "text.emphasis":           [.foregroundColor: NSColor.cyan]     /// 🩵 — Italics
          case "text.strong":             [.foregroundColor: NSColor.brown]    /// 🤎 — Bold
          case "text.uri":                [.foregroundColor: NSColor.magenta]  /// 🩷 — Links
          case "text.reference":          [.foregroundColor: NSColor.gray]     /// 🩶 — Link label e.g. `[label](http://link.com)`
          case "none":                    [.foregroundColor: NSColor.orange]   /// 🧡 — Also seems related to 'code' text?
            ///
          default: [.foregroundColor: NSColor.blue]
        } // END switch and return
      } // END code block check
      
      
    }
    
    let highlighterConfig = TextViewHighlighter.Configuration(
      languageConfiguration: markdownConfig,
      attributeProvider: provider,
      languageProvider: { name in
        
        switch name {
          case "markdown_inline":
            print("Found inline markdown grammar.")
            return markdownInlineConfig

          case "swift":
            print("Found swift grammar")
            return swiftConfig
            
          default:
            return nil
        }
      },
      
      locationTransformer: { _ in nil }
    )
    
    return try TextViewHighlighter(textView: textView, configuration: highlighterConfig)
    
  } // END make highlighter
  
  
  func makeManualHighlighter() throws {
    
    let languageConfig = try LanguageConfiguration(
      tree_sitter_swift(),
      name: "Swift"
    )
    
    let clientConfig = TreeSitterClient.Configuration(
      languageProvider: { identifier in
        // look up nested languages by identifier here. If done
        // asynchronously, inform the client they are ready with
        // `languageConfigurationChanged(for:)`
        return nil
      },
      contentProvider: { [textView] length in
        // given a maximum needed length, produce a `Content` structure
        // that will be used to access the text data
        
        // this can work for any system that efficiently produce a `String`
        return .init(string: textView.string)
      },
      lengthProvider: { [textView] in
        textView.string.utf16.count
        
      },
      invalidationHandler: { set in
        // take action on invalidated regions of the text
      },
      locationTransformer: { location in
        // optionally, use the UTF-16 location to produce a line-relative Point structure.
        return nil
      }
    )
    
    let client = try TreeSitterClient(
      rootLanguageConfig: languageConfig,
      configuration: clientConfig
    )
    
    let source = textView.string
    
    let provider = source.predicateTextProvider
    
    // this uses the synchronous query API, but with the `.required` mode, which will force the client
    // to do all processing necessary to satisfy the request.
    let highlights = try client.highlights(in: NSRange(0..<24), provider: provider, mode: .required)!
    
    print("highlights:", highlights)
  }
  
  
}

extension NSColor {
  static let lightBlue = NSColor(#colorLiteral(red: 0.5372549295425415, green: 0.8666666746139526, blue: 0.9843137264251709, alpha: 1))
  static let darkGrey = NSColor(#colorLiteral(red: 0.14509804546833038, green: 0.14509804546833038, blue: 0.16470588743686676, alpha: 1))
  static let xcodePink = NSColor(#colorLiteral(red: 0.9333333373069763, green: 0.5058823823928833, blue: 0.6901960968971252, alpha: 1))
  static let offWhite = NSColor(#colorLiteral(red: 0.8705882430076599, green: 0.8745098114013672, blue: 0.8745098114013672, alpha: 1))
  static let xcodePurple = NSColor(#colorLiteral(red: 0.6705882549285889, green: 0.5137255191802979, blue: 0.8941176533699036, alpha: 1))
  static let xcodeMint = NSColor(#colorLiteral(red: 0.729411780834198, green: 0.9411764740943909, blue: 0.8941176533699036, alpha: 1))
  
}
