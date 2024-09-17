//
//  Changed+Appeared.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import SwiftUI
import TextCore
//import Rearrange
import BaseHelpers
//import STTextKitPlus

extension MarkdownTextView {
  
  public override func viewDidMoveToSuperview() {
    super.viewDidMoveToSuperview()
    
    setupScrollObservation()
  }
  
  public override func viewDidMoveToWindow() {
    
    super.viewDidMoveToWindow()
    
    setupViewportLayoutController()
    
    Task { @MainActor in
      let heightUpdate = self.updateEditorHeight()
      await self.infoHandler.update(heightUpdate)
    }
    
//        exploreTextSegments()
    
    basicInlineMarkdown()
    
    
  }
  
  /// Just realised; for inline Markdown elements, I *should* be safe to only perform
  /// the 'erase-and-re-apply styles' process on a paragraph-by-paragraph basis.
  ///
  /// Because inline elements shouldn't be extending past that anyway.
  ///
  func basicInlineMarkdown() {
    
    Task {
      DispatchQueue.main.async {
        
        guard let tlm = self.textLayoutManager,
              let tcm = tlm.textContentManager
        else { return }
        
        tcm.performEditingTransaction {
          
          let text = self.string
          let nsString = self.string as NSString
          
          let documentNSRange = NSRange(location: 0, length: nsString.length)
          
          let paragraphNSRange = self.currentParagraph.range
          
          self.textStorage?.removeAttribute(.foregroundColor, range: paragraphNSRange)
          self.textStorage?.removeAttribute(.backgroundColor, range: paragraphNSRange)
          
          self.textStorage?.addAttributes(AttributeSet.white.attributes, range: paragraphNSRange)
          
          
          
          
//          self.textStorage?.setAttributes(defaultAttributes, range: fullRange)
          
//          tlm.removeRenderingAttribute(.foregroundColor, for: tlm.documentRange)
//          tlm.removeRenderingAttribute(.backgroundColor, for: tlm.documentRange)
          
  //        guard let pattern = Markdown.Syntax.inlineCode.regex else { return }
          
          //            let nsString = self.string as NSString
          //            let fullRange = NSRange(location: 0, length: nsString.length)
          
          
          //            let attributedString = NSMutableAttributedString(string: text)
          
          //            text.enumerateSubstrings(in: text.startIndex..<text.endIndex, options: .) {
          //              (substring, substringRange, _, _) in
          
          
          for syntax in Markdown.Syntax.testCases {
            
            guard let pattern = syntax.regex else { break }
            
            let matches = text.matches(of: pattern)
            
            for match in matches {
              
//              let nsRange = NSRange(match.range, in: text)

              let syntaxRange: NSRange = .init(match.range, in: text)
//              let syntaxRange: NSRange =
              
              let leadingCount = match.output.leading.count
              let trailingCount = match.output.trailing.count
              
              let contentRange: NSRange = .init(location: syntaxRange.location + leadingCount, length: syntaxRange.length - (leadingCount + trailingCount))
              
              
//              let leadingRange: NSRange = nsString.range(of: String(match.output.leading))
//              let trailingRange: NSRange = nsString.range(of: String(match.output.trailing))
              
              self.textStorage?.addAttributes(syntax.syntaxAttributes(with: self.configuration).attributes, range: syntaxRange)
              self.textStorage?.addAttributes(syntax.contentAttributes(with: self.configuration).attributes, range: contentRange)
//              self.textStorage?.addAttributes(syntax.syntaxRenderingAttributes, range: syntaxRange)
//              self.textStorage?.addAttributes(AttributeSet.highlighter.attributes, range: trailingRange)
              
              
  //            print("""
  //              Syntax: \(syntax.name)
  //              Text: \(match.output.0)
  //              Match NSRange: \(nsRange)
  //
  //              """)
              
//              guard let nsTextRange = NSTextRange(nsRange, provider: tcm) else {
//                print("Issue creating the `NSTextRange`.")
//                break
//              }
              
//              self.setNeedsDisplay(self.visibleRect)
//              tlm.ensureLayout(for: tlm.documentRange)

//              tlm.invalidateRenderingAttributes(for: nsTextRange)
              
//              tlm.setRenderingAttributes(syntax.contentRenderingAttributes, for: nsTextRange)
              
              
              
              
            } // END matches
            
            
          } // END loop syntaxes
          
          
            
        } // END perform edit
        
      } // END dispatch
    }
    
  } // END basicInlineMarkdown
  
  
  
  
  
//  func exploreTextSegments() {
//    
//    guard let tlm = self.textLayoutManager,
//          let tcm = tlm.textContentManager
//    else { return }
//    
    
//    tcm.performEditingTransaction {
      
//      tlm.enumerateTextLayoutFragments(from: tlm.documentRange.location) { fragment in
//        
//        guard let paragraph = fragment.textElement as? NSTextParagraph else { return false }
//        
//        let string = paragraph.attributedString.string
//        
//        guard let paragraphRange = paragraph.elementRange
//        else {
//          print("Returned false: \(string)")
//          return false
//        }
//        
//        let nsRange = NSRange(paragraphRange, provider: tcm)
//        
        
        
        
//        return true
        //
//      } // END enumerate fragments
//      
//    } // END perform edit
//  }
  
  
  func setupScrollObservation() {
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleScrollViewDidScroll),
      name: NSView.boundsDidChangeNotification,
      object: enclosingScrollView?.contentView
    )
    
  }
  
  
}
