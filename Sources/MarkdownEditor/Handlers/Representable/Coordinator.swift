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
    
    private enum ParsingState {
      case normal
      case inCodeBlock(startLocation: NSTextLocation)
    }
    private var parsingState: ParsingState = .normal
    
    
    
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
    
    
    
    public func textLayoutManager(_ textLayoutManager: NSTextLayoutManager, textLayoutFragmentFor location: NSTextLocation, in textElement: NSTextElement) -> NSTextLayoutFragment {
      
      guard let tcm = textLayoutManager.textContentManager,
            let textRange = textElement.elementRange else {
        return NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
      }
      
      let text = tcm.attributedString(in: textRange)?.string ?? ""
      
      switch parsingState {
        case .normal:
          if text.trimmingCharacters(in: .whitespacesAndNewlines) == "```" {
            parsingState = .inCodeBlock(startLocation: location)
            // Return a regular fragment for the opening ```
            return NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
          }
          // Apply normal styling
          return NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
          
        case .inCodeBlock(let startLocation):
          if text.trimmingCharacters(in: .whitespacesAndNewlines) == "```" {
            // End of code block found
            parsingState = .normal

            // Return a regular fragment for the closing ```
            return NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
          }
          
          let fragment = CodeBlockBackground(
            textElement: textElement,
            range: textElement.elementRange,
            paragraphStyle: .default
          )
          return fragment
          
      }
//    }
    
    }
    
//    private func applyCodeBlockStyling(
//      _ textLayoutManager: NSTextLayoutManager,
//      from startLocation: NSTextLocation,
//      to endLocation: NSTextLocation
//    ) {
//      
//      guard let tcm = textLayoutManager.textContentManager,
//            let range = NSTextRange(location: startLocation, end: endLocation) else {
//        return
//      }
//      
//      // Apply code block styling attributes
//      tcm.performEditingTransaction {
//        let attributes: [NSAttributedString.Key: Any] = [
//          .foregroundColor: NSColor.systemBlue,
////          .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
//        ]
//        tcm.primaryTextLayoutManager?.setRenderingAttributes(attributes, for: range)
//      }
//    }
    
    
    
    
    
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

