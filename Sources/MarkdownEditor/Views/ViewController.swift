//
//  ViewController.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 6/9/2024.
//

import AppKit
import Neon
import SwiftTreeSitter
import TreeSitterMarkdown
import TreeSitterMarkdownInline
import TreeSitterClient

public class MarkdownViewController: NSViewController {
  
  var scrollView: MarkdownScrollView
  var textView: MarkdownTextView
  
//  let highlighter: TextViewHighlighter
  
  init(
    configuration: MarkdownEditorConfiguration
  ) {

    self.scrollView = MarkdownScrollView(frame: .zero, configuration: configuration)
    self.textView = self.scrollView.documentView as! MarkdownTextView
//    self.highlighter = try! Self.makeHighlighter(for: textView)
    
    super.init(nibName: nil, bundle: nil)
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  

  private static func makeHighlighter(for textView: MarkdownTextView) throws {
    
    let fontSize: CGFloat = 15
    
    let regularFont = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
    let boldFont = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .bold)
    let italicDescriptor = regularFont.fontDescriptor.withSymbolicTraits(.italic)
    
    let italicFont = NSFont(descriptor: italicDescriptor, size: fontSize) ?? regularFont
    
    // Set the default styles. This is applied by stock `NSTextStorage`s during
    // so-called "attribute fixing" when you type, and we emulate that as
    // part of the highlighting process in `TextViewSystemInterface`.
    textView.typingAttributes = [
      .foregroundColor: NSColor.darkGray,
      .font: regularFont,
    ]
//    
//    let provider: TokenAttributeProvider = { token in
//      return switch token.name {
//        case let keyword where keyword.hasPrefix("keyword"): [.foregroundColor: NSColor.red, .font: boldFont]
//        case "comment", "spell": [.foregroundColor: NSColor.green, .font: italicFont]
//          // Note: Default is not actually applied to unstyled/untokenized text.
//        default: [.foregroundColor: NSColor.blue, .font: regularFont]
//      }
//    }
    
    let languageConfig = try LanguageConfiguration(
      tree_sitter_markdown(),
      name: "Markdown"
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
  
  public override func loadView() {
    
    let max = CGFloat.greatestFiniteMagnitude
    
    textView.minSize = NSSize.zero
    textView.maxSize = NSSize(width: max, height: max)
    textView.isVerticallyResizable = true
    textView.isHorizontallyResizable = true
    
    self.view = scrollView
    
    assert(self.textView.enclosingScrollView != nil, "I need the textView to have a scrollview.")

  }
  
}
