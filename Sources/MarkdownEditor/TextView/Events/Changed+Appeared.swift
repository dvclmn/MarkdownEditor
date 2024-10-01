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
    
    //    if configuration.isScrollable {
    //      setupScrollObservation()
    //    }
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
    
    DispatchQueue.main.async { [weak self] in
      
      guard let self = self,
            let tlm = self.textLayoutManager,
            let tcm = tlm.textContentManager,
            let ts = self.textStorage
      else {
        print("Text layout manager setup failed")
        return
      }
      
        
        let text = self.string
        guard !text.isEmpty else {
//          print("Text is empty, nothing to process")
          return
        }
        
      tcm.performEditingTransaction {
        
//        let nsString = self.string as NSString
        
  //        let documentNSRange = NSRange(location: 0, length: nsString.length)
        
        let paragraphNSRange = self.currentParagraph.range
        
        ts.removeAttribute(.foregroundColor, range: paragraphNSRange)
        ts.removeAttribute(.backgroundColor, range: paragraphNSRange)
        
        ts.addAttributes(AttributeSet.white.attributes, range: paragraphNSRange)
        
        
        
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
          
          guard let pattern = syntax.regex else { continue }
          
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
            
            
            let attachment = NSTextAttachment()
            let cell = BoxDrawingAttachmentCell()
            attachment.attachmentCell = cell
            
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
            
            //              if syntax == .codeBlock {
            
            //                let blockStart: Int = self.string.distance(from: self.string.startIndex, to: match.range.lowerBound)
            //
            
            //                print(blockStart)
            
            
            
            //              }
            
            
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
  
  
  //  func setupScrollObservation() {
  //
  //    NotificationCenter.default.addObserver(
  //      self,
  //      selector: #selector(handleScrollViewDidScroll),
  //      name: NSView.boundsDidChangeNotification,
  //      object: enclosingScrollView?.contentView
  //    )
  //
  //  }
  
  
}



class BoxDrawingAttachmentCell: NSTextAttachmentCell {
  var cornerRadius: CGFloat = 5.0
  var borderColor: NSColor = .orange
  var backgroundColor: NSColor = .lightGray.withAlphaComponent(0.9)
  
  override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
    let path = NSBezierPath(roundedRect: cellFrame, xRadius: cornerRadius, yRadius: cornerRadius)
    backgroundColor.setFill()
    path.fill()
    borderColor.setStroke()
    path.stroke()
  }
  
  override func cellSize() -> NSSize {
    return NSSize(width: 100, height: 100) // The cell itself doesn't have a size
  }
}
