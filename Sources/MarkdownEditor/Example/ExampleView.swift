//
//  SwiftUIView.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import SwiftUI
import BaseHelpers
import BaseStyles

import Neon
import NSUI
import SwiftTreeSitter
import TreeSitterSwift

import TreeSitterMarkdown
import TreeSitterMarkdownInline

@MainActor
struct TextView: NSUIViewControllerRepresentable {
  typealias NSUIViewControllerType = TextViewController
  func makeNSUIViewController(context: Context) -> TextViewController {
    TextViewController()
  }
  
  func updateNSUIViewController(_ viewController: TextViewController, context: Context) {
  }
}

public final class TextViewController: NSUIViewController {
  private let textView: NSUITextView
  private let highlighter: TextViewHighlighter
  
  init() {
    if #available(iOS 16.0, *) {
      self.textView = NSUITextView(usingTextLayoutManager: false)
    } else {
      self.textView = NSUITextView()
    }
    
    self.highlighter = try! Self.makeHighlighter(for: textView)
    
    super.init(nibName: nil, bundle: nil)
    
    // enable non-continguous layout for TextKit 1
    if #available(macOS 12.0, iOS 16.0, *), textView.textLayoutManager == nil {
      textView.nsuiLayoutManager?.allowsNonContiguousLayout = true
    }
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private static func makeHighlighter(for textView: NSUITextView) throws -> TextViewHighlighter {
    let regularFont = NSUIFont.monospacedSystemFont(ofSize: 16, weight: .regular)
    let boldFont = NSUIFont.monospacedSystemFont(ofSize: 16, weight: .bold)
    let italicDescriptor = regularFont.fontDescriptor.nsuiWithSymbolicTraits(.traitItalic) ?? regularFont.fontDescriptor
    
    let italicFont = NSUIFont(nsuiDescriptor: italicDescriptor, size: 16) ?? regularFont
    
    // Set the default styles. This is applied by stock `NSTextStorage`s during
    // so-called "attribute fixing" when you type, and we emulate that as
    // part of the highlighting process in `TextViewSystemInterface`.
    textView.typingAttributes = [
      .foregroundColor: NSUIColor.darkGray,
      .font: regularFont,
    ]
    
    let provider: TokenAttributeProvider = { token in
      return switch token.name {
        case let keyword where keyword.hasPrefix("keyword"): [.foregroundColor: NSUIColor.red, .font: boldFont]
        case "comment", "spell": [.foregroundColor: NSUIColor.green, .font: italicFont]
          // Note: Default is not actually applied to unstyled/untokenized text.
        default: [.foregroundColor: NSUIColor.blue, .font: regularFont]
      }
    }
    
    // this is doing both synchronous language initialization everything, but TreeSitterClient supports lazy loading for embedded languages
    let markdownConfig = try! LanguageConfiguration(
      tree_sitter_markdown(),
      name: "Markdown"
    )
    
    let markdownInlineConfig = try! LanguageConfiguration(
      tree_sitter_markdown_inline(),
      name: "MarkdownInline",
      bundleName: "TreeSitterMarkdown_TreeSitterMarkdownInline"
    )
    
    let swiftConfig = try! LanguageConfiguration(
      tree_sitter_swift(),
      name: "Swift"
    )
    
    let highlighterConfig = TextViewHighlighter.Configuration(
      languageConfiguration: swiftConfig, // the root language
      attributeProvider: provider,
      languageProvider: { name in
        print("embedded language: ", name)
        
        switch name {
          case "swift":
            return swiftConfig
          case "markdown_inline":
            return markdownInlineConfig
          default:
            return nil
        }
      },
      locationTransformer: { _ in nil }
    )
    
    return try TextViewHighlighter(textView: textView, configuration: highlighterConfig)
  }
  
  override func loadView() {
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    let scrollView = NSScrollView()
    
    scrollView.hasVerticalScroller = true
    scrollView.documentView = textView
    
    let max = CGFloat.greatestFiniteMagnitude
    
    textView.minSize = NSSize.zero
    textView.maxSize = NSSize(width: max, height: max)
    textView.isVerticallyResizable = true
    textView.isHorizontallyResizable = true
    
    textView.isRichText = false  // Discards any attributes when pasting.
    
    self.view = scrollView
#else
    self.view = textView
#endif
    
    // this has to be done after the textview has been embedded in the scrollView if
    // it wasn't that way on creation
    highlighter.observeEnclosingScrollView()
    
    regularTest()
  }
  
  func regularTest() {
    let url = Bundle.main.url(forResource: "test", withExtension: "code")!
    let content = try! String(contentsOf: url)
    
    textView.text = content
  }
  
  func doBigTest() {
    let url = Bundle.main.url(forResource: "big_test", withExtension: "md")!
    let content = try! String(contentsOf: url)
    
    textView.text = content
    
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
      let range = NSRange(location: content.utf16.count, length: 0)
      
      self.textView.scrollRangeToVisible(range)
    }
  }
}


//
//struct ExampleView: View {
//  
//  @State private var text: String = TestStrings.Markdown.basicMarkdown
//  @State private var editorInfo: EditorInfo? = nil
//  @State private var config = MarkdownEditorConfiguration(
//    fontSize: 13,
//    lineHeight: 1.1,
//    renderingAttributes: .markdownRenderingDefaults,
//    insertionPointColour: .pink,
//    codeColour: .green,
//    hasLineNumbers: false,
//    isShowingFrames: false,
//    insets: 20
//  )
//  
//  var body: some View {
//    
//    VStack(spacing: 0) {
//      
//      
//      
//      
////      HStack {
////        Button {
////          
////        } label: {
////          Label("Bold", systemImage: Icons.text.icon)
////        }
////      }
////      .padding()
////      Spacer()
//      
//      MarkdownEditor(text: $text, configuration:config) { info in
//          self.editorInfo = info
//        }
//      .background(alignment: .topLeading) {
//        Rectangle()
//          .fill(.blue.opacity(0.05))
//          .frame(height: self.editorInfo?.frame.height, alignment: .topLeading)
//          .border(Color.blue.opacity(0.2))
//      }
//        .frame(maxWidth: .infinity, alignment: .top)
//      
//      
////      HStack(alignment: .bottom) {
////        Text(self.editorInfo?.selection.summary ?? "nil")
////        Spacer()
////        Text(self.editorInfo?.scroll.summary ?? "nil")
////        Spacer()
////        Text(self.editorInfo?.text.scratchPad ?? "nil")
////      }
////      .textSelection(.enabled)
////      .foregroundStyle(.secondary)
////      .font(.callout)
////      .frame(maxWidth: .infinity, alignment: .leading)
////      .padding(.horizontal, 30)
////      .padding(.top, 10)
////      .padding(.bottom, 14)
////      .background(.black.opacity(0.5))
//    }
////    .overlay(alignment: .topTrailing) {
////      VStack {
////        //              Text("Local editor height \(self.editorInfo?.frame.height.description ?? "nil")")
////      }
////      .allowsHitTesting(false)
////      .foregroundStyle(.secondary)
////    }
//    .background(.black.opacity(0.5))
//    .background(.purple.opacity(0.1))
//    .frame(width: 440, height: 600)
//    
//    /// Interestingly, the below 'simulates' text being added to the NSTextView, but NOT
//    /// in the same as a user actually focusing the view and typing into it. There appears
//    /// to be a difference between these two methods of the text being mutated.
//    ///
////    .task {
////      do {
////        try await Task.sleep(for: .seconds(0.8))
////        
////        self.text += "Hello"
////      } catch {
////        
////      }
////    }
//  }
//}
//
//
//#Preview {
//  ExampleView()
//  
//}
