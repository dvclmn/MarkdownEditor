//
//  Styling.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 8/10/2024.
//

import AppKit
//import Highlightr
import Glyph

extension MarkdownTextView {
  
  func styleInlineMarkdown() {
    
    
    
    guard configuration.isStyling else {
      print("Styling is switched OFF in configuration.")
      return
    }
    
    let currentSelection = self.selectedRange
    
    self.styleElements()
    //              self.needsDisplay = true
    
    self.setSelectedRange(currentSelection)
    
  } // END style debounced
  
  
  func styleElements() {
    
    guard let tcmTemp = self.textLayoutManager?.textContentManager else {
      print("Issue getting the text content manager")
      return
    }
    
    guard let textStorage = self.textStorage else {
      fatalError("Issue getting the text storage")
    }
    
    
    let opacity: CGFloat = 0.15
    
    let leadingTestColour = NSColor.orange.withAlphaComponent(opacity)
    let contentTestColour = NSColor.blue.withAlphaComponent(opacity)
    let trailingTestColour = NSColor.green.withAlphaComponent(opacity)
    
    tcmTemp.performEditingTransaction {
      
      for case let syntax in Markdown.Syntax.allCases where syntax.type == .inline {
        
        guard let nsRegex = syntax.nsRegex else {
          //      print("Don't need to perform a parse for \(syntax.name), no regex found.")
          continue
        }
        
        let matches: [NSTextCheckingResult] = nsRegex.matches(in: self.string, range: documentNSRange)
        
        for match in matches {
          
          let captureGroupCount: Int = match.numberOfRanges - 1
          
          guard captureGroupCount == 3 else {
            continue
          }
          
//          print("The number of ranges (aka capture groups?) for \(syntax.name) is \(captureGroupCount)")
          
//          let nsRangeLeading: NSRange = match.range(at: 1)
//          let nsRangeContent: NSRange = match.range(at: 2)
//          let nsRangeTrailing: NSRange = match.range(at: 3)
//          
//          guard let rangeLeading = NSTextRange(nsRangeLeading),
//          let rangeContent = NSTextRange(nsRangeContent),
//                let rangeTrailing = NSTextRange(nsRangeTrailing) else {
//            print("Issue creating NSTextRange from the above")
//            return
//          }
//          
//          tlm.setRenderingAttributes([.backgroundColor : leadingTestColour], for: rangeLeading)
//          tlm.setRenderingAttributes([.backgroundColor : contentTestColour], for: rangeContent)
//          tlm.setRenderingAttributes([.backgroundColor : trailingTestColour], for: rangeTrailing)
//          
//          textStorage.addAttribute(.backgroundColor, value: leadingTestColour, range: rangeLeading)
//          textStorage.addAttribute(.backgroundColor, value: contentTestColour, range: rangeContent)
//          textStorage.addAttribute(.backgroundColor, value: trailingTestColour, range: rangeTrailing)
          
        } // END match loop
        
      } // END syntax loop
      
      
      
      
      /// I think (for now) the first thing to do would be to remove all existing styles?
      /// Even just to get more repsonsive formatting working
      ///
      //      textStorage.removeAttribute(.foregroundColor, range: documentNSRange)
      //      textStorage.removeAttribute(.backgroundColor, range: documentNSRange)
      
      /// Then ensure defaults are added:
      //      textStorage.addAttribute(.foregroundColor, value: configuration.theme.textColour, range: documentNSRange)
      
      
      //      for element in self.elements where element.syntax.type == .inline {
      
      /// This is a bit silly, I'm writing this as if the user has pressed Return
      /// (i.e., departed one paragraph and arrived at another)
      ///
      //        let rangeToRemoveDeparted: NSRange = self.paragraphHandler.previousParagraph.range
      //        let rangeToRemoveArrived: NSRange = self.paragraphHandler.currentParagraph.range
      //
      //        /// Remove stale attributes
      //        textStorage.removeAttribute(.foregroundColor, range: rangeToRemoveDeparted)
      //        textStorage.removeAttribute(.foregroundColor, range: rangeToRemoveArrived)
      //
      //        textStorage.removeAttribute(.backgroundColor, range: rangeToRemoveDeparted)
      //        textStorage.removeAttribute(.backgroundColor, range: rangeToRemoveArrived)
      //
      //        /// Add default styles
      //        textStorage.setAttributes(configuration.defaultTypingAttributes, range: rangeToRemoveArrived)
      //        textStorage.setAttributes(configuration.defaultTypingAttributes, range: rangeToRemoveDeparted)
      //
      
      
      
      //        textStorage.addAttribute(.backgroundColor, value: leadingTestColour, range: element.ranges.leading)
      //        textStorage.addAttribute(.backgroundColor, value: contentTestColour, range: element.ranges.content)
      //        textStorage.addAttribute(.backgroundColor, value: trailingTestColour, range: element.ranges.trailing)
      
      
      
      
      //        if element.syntax == .codeBlock {
      //
      //          textStorage.addAttribute(.font, value: configuration.theme.codeFont, range: element.ranges.all)
      //
      
      
      //          guard let highlightedCode: NSAttributedString = highlightr.highlight(element.string, as: nil) else {
      //            print("Couldn't get the Highlighted string")
      //            return
      //          }
      //
      //          highlightedCode.enumerateAttribute(.foregroundColor, in: documentNSRange) { value, range, stop in
      //
      //            if let color = value as? NSColor {
      //              textStorage.addAttribute(.foregroundColor, value: color, range: range)
      //            }
      //
      //          }
      //        } else {
      
      
      
      //          textStorage.addAttributes(element.syntax.contentAttributes(with: self.configuration).attributes, range: element.ranges.content)
      //
      //          textStorage.addAttributes(element.syntax.syntaxAttributes(with: self.configuration).attributes, range: element.ranges.leading)
      //          textStorage.addAttributes(element.syntax.syntaxAttributes(with: self.configuration).attributes, range: element.ranges.trailing)
      
      //        }
      
      
      //          textStorage.replaceCharacters(in: element.range, with: highlightedCode)
      
      //      } // END elements loop
      
      
    } // END perform editing
    
    
  } // END styling
  
}
