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
            //            let fullAttrString = tcs.textStorage?.attributedSubstring(from: NSRange(tlm.documentRange, in: tcm)),
            let textRange = textElement.elementRange
              
      else { return defaultFragment }
      
      //      let text = fullAttrString.string
      
      if let textView = textView, let shortcut = textView.shortcutPressed {
        
        wrapSelection(in: shortcut, tlm: tlm, textView: textView)
      }
      
      let finder = MarkdownSyntaxFinder(text: paragraph.attributedString.string, provider: tcm)
      let boldRanges = finder.findSyntaxRanges(for: .inlineCode, in: textRange)
      
      
      tlm.removeRenderingAttribute(.foregroundColor, for: textRange)
      
      for range in boldRanges {
        
        
        tlm.setRenderingAttributes(Markdown.Syntax.inlineCode.contentRenderingAttributes, for: range)
        
        
        //        print("NSTextRange: \(range)")
        //        print("---")
        
        
        
        
        
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


extension MarkdownEditor.Coordinator {
  
  func wrapSelection(
    in syntax: MarkdownSyntax,
    tlm: NSTextLayoutManager,
    textView: MarkdownTextView
  ) {
    
    guard let tcm = tlm.textContentManager,
          let tcs = textView.textContentStorage,
          let selection = tlm.textSelections.first,
          let selectedRange = selection.textRanges.first,
          let selectedText = tcs.attributedString?.string
    else { return }
    
    let leading: String = syntax.leadingCharacters
    let trailing: String = syntax.trailingCharacters
    
    
    print("Selected text: \(selectedText)")
    
    let newText = syntax.leadingCharacters + selectedText + syntax.trailingCharacters
    let newAttrString = NSAttributedString(string: newText)
    
    tcm.performEditingTransaction {
      tcm.replaceContents(
        in: selectedRange,
        with: [NSTextParagraph(attributedString: newAttrString)]
      )
    }
  }
  
  //      // Update the selection to exclude the new wrapper characters
  //      let newSelectionRange = NSRange(location: range.location + wrapper.count, length: range.length)
  //      setSelectedRange(newSelectionRange)
  
}
