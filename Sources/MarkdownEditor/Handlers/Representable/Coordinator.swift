//
//  Coordinator.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI


public extension MarkdownEditor {
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  final class Coordinator: NSObject, NSTextViewDelegate, NSTextContentStorageDelegate, NSTextLayoutManagerDelegate {
    var parent: MarkdownEditor
    var selectedRanges: [NSValue] = []
    
    var selections: [NSTextSelection] = []
    
    var updatingNSView = false

    init(_ parent: MarkdownEditor) {
      self.parent = parent
    }
    
        
    public func textDidChange(_ notification: Notification) {
      
      guard let textView = notification.object as? MarkdownTextView,
            !updatingNSView
      else { return }
      
      self.parent.text = textView.string
      self.selectedRanges = textView.selectedRanges
      
      print("`func textDidChange` — at \(Date.now)")
      
      Task { @MainActor in
        await textView.applyMarkdownStyles()
      }
      
      /// I have learned, and need to remember, that this `Coordinator` is
      /// a delegate, for my ``MarkdownTextView``. Which means I can take
      /// full advantage of methods here, just like I can with overrides in `MarkdownTextView`. They often have different functionalities to
      /// experiment with.
      //      Task {
      //        textView.processingTime = await textView.processFullDocumentWithTiming(textView.string)
      //      }
      
    }
    
    public func textViewDidChangeSelection(_ notification: Notification) {
      guard let textView = notification.object as? MarkdownTextView,
            !updatingNSView
      else { return }
      
      self.selectedRanges = textView.selectedRanges
      
    }
    
    /// From LLM, not sure if true:
    /// This method (`textLayoutManager`, defined on protocol `NSTextLayoutManagerDelegate`) is called by the system when it needs to create a layout fragment for a specific portion of text. It gives you an opportunity to provide a custom NSTextLayoutFragment subclass for different parts of your text.
    ///
    /// The method the framework calls to give the delegate an opportunity to return a custom text layout fragment.
    ///
//    public func textLayoutManager(
//      _ textLayoutManager: NSTextLayoutManager,
//      textLayoutFragmentFor location: NSTextLocation,
//      in textElement: NSTextElement
//    ) -> NSTextLayoutFragment {
//      
//      let fragment = CodeBlockBackground(
//        textElement: textElement,
//        range: textElement.elementRange,
//        paragraphStyle: .default
//      )
//      return fragment
//    }
    
    
//    public func textLayoutManager(_ textLayoutManager: NSTextLayoutManager, textLayoutFragmentFor location: NSTextLocation, in textElement: NSTextElement) -> NSTextLayoutFragment {
      
      

//      let fragment = CodeBlockBackground(
//        textElement: textElement,
//        range: textElement.elementRange,
//        paragraphStyle: .default
//      )
//      return fragment
//      
//      
//      if let markdownElement = textElement as? MarkdownElement {
        
//        switch markdownElement.syntax {
//          case .codeBlock:
//            return CodeBlockBackground(textElement: markdownElement, range: markdownElement.elementRange, paragraphStyle: .default)
//          default:
//            return NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
//        }
        
//        switch markdownElement.type {
//          case .codeBlock:
//            return CodeBlockLayoutFragment(textElement: textElement, range: textElement.elementRange)
//          case .blockQuote:
//            return BlockQuoteLayoutFragment(textElement: textElement, range: textElement.elementRange)
//          case .heading(let level):
//            return HeadingLayoutFragment(textElement: textElement, range: textElement.elementRange, level: level)
//          case .paragraph:
//            return NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
//        }
//      }
//      return NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
//    }
    
    
    
    
  }
}

