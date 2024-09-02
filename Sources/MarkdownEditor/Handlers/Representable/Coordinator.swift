//
//  Coordinator.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI
import TextCore

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
      
      let defaultFragment = NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
      
      let tlm = textLayoutManager
      
      guard let tcm = tlm.textContentManager,
              let textRange = textElement.elementRange
      else { return defaultFragment }
      
      let text = tcm.attributedString(in: textRange)?.string ?? "nil"

      
      if text.hasPrefix("# ") {
        
        let fragment = CodeBlockBackground(
          textElement: textElement,
          range: textElement.elementRange,
          paragraphStyle: .default,
          isActive: false
        )
        
        guard let newMarkdownRange = Markdown.Element.markdownNSTextRange(
          textRange,
          in: text,
          syntax: .heading(level: 1),
          tcm: tcm
        ) else { return defaultFragment }
        
        let newElement = Markdown.Element(syntax: .heading(level: 1), range: newMarkdownRange)
        
        
        DispatchQueue.main.async { [weak self] in
          
          guard let self = self else { return }
          
          self.textView?.addMarkdownElement(newElement)

        }
        
        
        /// Attempt to 'highlight' the drawn background, if selected.
        /// Didn't work, leaving for now.
        ///
//        if let currentSelection = textLayoutManager.insertionPointLocations.first {
//          
//          if textRange.contains(currentSelection) {
//            fragment.isActive = true
//          } else {
//            fragment.isActive = false
//          }
//        }
        
        
        print("Text as defined by `tcm.attributedString(in: textRange)?.string`: \(text)")
        
        return fragment
      } else {
        return defaultFragment
        
      }

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
    
    
    
    
    
    
  }
}

