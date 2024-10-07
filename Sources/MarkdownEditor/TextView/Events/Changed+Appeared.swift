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
    
//    setupViewportLayoutController()
    
    
    parseAndRedraw()
    
    //        exploreTextSegments()
    
    
//    basicInlineMarkdown()
    
  }
  
  func lineCount() {
    
  }
 
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
