//
//  Coordinator.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI
import TextCore
import Rearrange
//import STTextKitPlus

public extension MarkdownEditor {
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  final class Coordinator: NSObject, NSTextViewDelegate, NSTextContentStorageDelegate, NSTextLayoutManagerDelegate {
    
    var parent: MarkdownEditor
    weak var textView: MarkdownTextView?
    var selectedRanges: [NSValue] = []
    
    var selections: [NSTextSelection] = []
    
    var updatingNSView = false
    
    init(_ parent: MarkdownEditor)
    {
      self.parent = parent
    }
    
    
    /// This method (`textLayoutManager`, defined on protocol `NSTextLayoutManagerDelegate`)
    /// is called by the system when it needs to create a layout fragment for a specific portion of text.
    /// It gives you an opportunity to provide a custom NSTextLayoutFragment subclass for different parts of your text.
    ///
    /// The method the framework calls to give the delegate an opportunity to return a custom text layout fragment.
    /// https://developer.apple.com/documentation/uikit/nstextlayoutmanagerdelegate/3810024-textlayoutmanager
    ///
    /// Use this to provide an NSTextLayoutFragment specialized for an NSTextElement subclass
    /// targeted for the rendering surface.
    ///
    
    
    
    public func textLayoutManager(
      _ textLayoutManager: NSTextLayoutManager,
      textLayoutFragmentFor location: NSTextLocation,
      in textElement: NSTextElement
    ) -> NSTextLayoutFragment {
      
      let tlm = textLayoutManager
      
      let defaultFragment = NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
      
      guard let tcm = tlm.textContentManager,
            let tcs = textView?.textContentStorage,
            let paragraph = textElement as? NSTextParagraph,
            let fullAttrString = tcs.textStorage?.attributedSubstring(from: NSRange(tlm.documentRange, in: tcm)),
            let textRange = textElement.elementRange
              
      else { return defaultFragment }
      
      let text = fullAttrString.string
      
      tcm.performEditingTransaction {
        
        
        let finder = MarkdownSyntaxFinder(
          text: text,
          provider: tcm,
          syntax: .bold
        )
        let inlineCodeRanges = finder.findInlineCode()
        
        tlm.removeRenderingAttribute(.foregroundColor, for: tlm.documentRange)
        
        for range in inlineCodeRanges {
          
          
          tlm.setRenderingAttributes(Markdown.Syntax.inlineCode.contentRenderingAttributes, for: range)
          
          
          //        print("NSTextRange: \(range)")
          //        print("---")
        }
        
        
        
        
        //      let tlm = textLayoutManager
        
        //      guard let tcm = tlm.textContentManager,
        //              let textRange = textElement.elementRange
        //      else { return defaultFragment }
        
        
        //      let fragment = CodeBlockBackground(
        //        textElement: textElement,
        //        range: textElement.elementRange,
        //        paragraphStyle: .default,
        //        isActive: false
        //      )
        
      }
      
      return defaultFragment
      
      
    }
    
    
    
    public func textDidChange(_ notification: Notification) {
      
      guard let textView = notification.object as? MarkdownTextView,
            !updatingNSView
              
      else { return }
      
      self.parent.text = textView.string
      self.selectedRanges = textView.selectedRanges
      
      /// I have learned, and need to remember, that this `Coordinator` is
      /// a delegate, for my ``MarkdownTextView``. Which means I can take
      /// full advantage of methods here, just like I can with overrides in `MarkdownTextView`. They often have different functionalities to
      /// experiment with.
      
    }
    
    public func textViewDidChangeSelection(_ notification: Notification) {
      guard let textView = notification.object as? MarkdownTextView,
            !updatingNSView
      else { return }
      
      self.selectedRanges = textView.selectedRanges
      
    }
    
    public func textViewWillChangeText() {
      
    }
    
    
    
    
    
    
  }
}

enum MarkdownSyntax {
  
  case heading(level: Int)
  case bold
  case italic
  case inlineCode
  case highlight
  case strikethrough
  
  var leadingCharacters: String {
    switch self {
      case .heading(let level):
        for level in 1..<level {
          return String(repeating: "#", count: level)
        }
        
      case .bold:
        return "**"
      case .italic:
        return "*"
      case .inlineCode:
        return "`"
      case .highlight:
        return "=="
      case .strikethrough:
        return "~~"
    }
  }
  
  var trailingCharacters: String {
    switch self {
      case .heading:
        "\n"
      case .bold, .italic, .inlineCode, .highlight, .strikethrough: self.leadingCharacters
    }
  }
  
}


class MarkdownSyntaxFinder {
  let text: String
  let provider: NSTextElementProvider
  let syntax: MarkdownSyntax
  
  init(
    text: String,
    provider: NSTextElementProvider,
    syntax: MarkdownSyntax
  ) {
    self.text = text
    self.provider = provider
    self.syntax = syntax
  }
  
  func findSyntaxRanges() -> [Range<String.Index>] {
    var ranges: [Range<String.Index>] = []
    var currentIndex = text.startIndex
    var inSyntax = false
    var syntaxStartIndex: String.Index?
    
    while currentIndex < text.endIndex {
      
      let currentChar = text[currentIndex]
      if currentChar == syntaxMarker && !inSyntax {
        inSyntax = true
        syntaxStartIndex = currentIndex
      } else if currentChar == endMarker && inSyntax {
        if let start = syntaxStartIndex {
          let end = text.index(after: currentIndex)
          ranges.append(start..<end)
          inSyntax = false
        }
      }
      currentIndex = text.index(after: currentIndex)
    }
    
    return ranges
  }
  
  
  func findInlineCode() -> [NSTextRange] {
    
    var ranges: [NSTextRange] = []
    
    var currentIndex = text.startIndex
    
    while currentIndex < text.endIndex {
      
      if let openingBacktick = text[currentIndex...].firstIndex(of: "#") {
        let afterOpeningBacktick = text.index(after: openingBacktick)
        if let closingBacktick = text[afterOpeningBacktick...].firstIndex(of: "\n") {
          let startOffset = text.distance(from: text.startIndex, to: openingBacktick)
          let endOffset = text.distance(from: text.startIndex, to: closingBacktick) + 1
          
          if let textRange = NSTextRange(NSRange(location: startOffset, length: endOffset - startOffset), provider: provider) {
            ranges.append(textRange)
          }
          currentIndex = text.index(after: closingBacktick)
        } else {
          // No closing backtick found, move to next character
          currentIndex = text.index(after: openingBacktick)
        }
      } else {
        // No more backticks found
        break
      }
    }
    
    return ranges
  }
}
