//
//  Parsing.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import Foundation
import AppKit
import BaseHelpers
import TextCore

extension MarkdownTextView {
  
  /// Just realised; for inline Markdown elements, I *should* be safe to only perform
  /// the 'erase-and-re-apply styles' process on a paragraph-by-paragraph basis.
  ///
  /// Because inline elements shouldn't be extending past that anyway.
  ///
  func basicInlineMarkdown() {
    
    guard !configuration.isNeonEnabled else { return }
    
    DispatchQueue.main.async { [weak self] in
      
      guard let self = self,
            let ts = self.textStorage,
            !text.isEmpty
      else {
        print("Text layout manager setup failed")
        return
      }
      
      ts.beginEditing()
      
      let documentLength = (self.string as NSString).length
      let paragraphRange = self.currentParagraph.range
      
      // Ensure the paragraph range is within the document bounds
      let safeParagraphRange = NSRange(
        location: min(paragraphRange.location, documentLength),
        length: min(paragraphRange.length, documentLength - paragraphRange.location)
      )
      
      if safeParagraphRange.length > 0 {
        
        ts.removeAttribute(.foregroundColor, range: safeParagraphRange)
        ts.removeAttribute(.backgroundColor, range: safeParagraphRange)
        ts.addAttributes(AttributeSet.white.attributes, range: safeParagraphRange)
        
      } else {
        print("Invalid paragraph range")
      }
      
      
      for syntax in Markdown.Syntax.testCases {
        
        guard let pattern = syntax.regex else {
          print("There was an issue with the regex for this syntax: \(syntax.name)")
          continue
        }
        
        let matches = text.matches(of: pattern)
        
        for match in matches {
          
          let syntaxRange: NSRange = .init(match.range, in: text)

          let leadingCount = match.output.leading.count
          let trailingCount = match.output.trailing.count
          
          let contentRange: NSRange = .init(location: syntaxRange.location + leadingCount, length: syntaxRange.length - (leadingCount + trailingCount))
          
          if syntax == .codeBlock {
            
            //              self.drawRoundedRect(around: contentRange)
            //              self.highlightTextRange(contentRange)
            //              self.addRoundedRectHighlight(around: contentRange)
            
                          self.layoutManager?.drawBackground(forGlyphRange: contentRange, at: self.textContainerOrigin)
            
            
            
            
          }
          
          
          //              let leadingRange: NSRange = nsString.range(of: String(match.output.leading))
          //              let trailingRange: NSRange = nsString.range(of: String(match.output.trailing))
          
          
          
          
          //            guard let attrString = self.attributedSubstring(forProposedRange: safeParagraphRange, actualRange: nil) else {
          //              print("Couldn't get that text")
          //              return
          //            }
          
          
          
          
          
          //            let attachment = NSTextAttachment()
          //            let cell = BoxDrawingAttachmentCell()
          //            attachment.attachmentCell = cell
          
          //            let attachmentAttribute: AttributeSet = [
          //              .attachment: attachment
          //            ]
          
          //            let attributedString = NSAttributedString(string: "Hello", attributes: attachmentAttribute.attributes)
          
          //              ts.addAttributes(attachmentAttribute.attributes, range: contentRange)
          
          // Expand the attachment to cover the entire range
          //              let fullRange = NSRange(location: range.location, length: 1)
          //              textStorage.addAttribute(.expansion, value: NSNumber(value: Float(range.length)), range: fullRange)
          //
          //              let attr = self.attributedSubstring(forProposedRange: contentRange, actualRange: nil)
          
          //              print("""
          //              Attributed: \(attr)
          //              """)
          
          ts.addAttributes(syntax.syntaxAttributes(with: self.configuration).attributes, range: syntaxRange)
          ts.addAttributes(syntax.contentAttributes(with: self.configuration).attributes, range: contentRange)
          
          //              self.textStorage?.addAttributes(AttributeSet.highlighter.attributes, range: trailingRange)
          
          
          
  
          
          
        } // END matches
                
      } // END loop syntaxes

      ts.endEditing()
      
    } // END dispatch
    
  } // END basicInlineMarkdown
  
  
}


//public extension NSTextRange {
//  
//  convenience init?(
//    _ range: NSRange,
//    scopeRange: NSTextRange,
//    provider: NSTextElementProvider
//  ) {
//    let docLocation = scopeRange.location
//    
//    guard let start = provider.location?(docLocation, offsetBy: range.location) else {
//      return nil
//    }
//    
//    guard let end = provider.location?(start, offsetBy: range.length) else {
//      return nil
//    }
//    
//    self.init(location: start, end: end)
//  }
//
//}

