//
//  Changed+Appeared.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import SwiftUI
//import Rearrange
//import STTextKitPlus

extension MarkdownTextView {
  
  public override func viewDidMoveToSuperview() {
    super.viewDidMoveToSuperview()
    
    setupScrollObservation()
  }
  
  public override func viewDidMoveToWindow() {
    
    super.viewDidMoveToWindow()
    
    
    setupViewportLayoutController()
    
    
    //    self.parseAndStyleMarkdownLite(trigger: .appeared)
    
    //    self.styleElements(trigger: .appeared)
    
    Task { @MainActor in
      let heightUpdate = self.updateEditorHeight()
      await self.infoHandler.update(heightUpdate)
    }
    
    exploreTextSegments()
    
    
  }
  
  
  
  func exploreTextSegments() {
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager
    else { return }
    
    
    tcm.performEditingTransaction {
      
      tlm.enumerateTextLayoutFragments(from: tlm.documentRange.location) { fragment in
        
        guard let paragraph = fragment.textElement as? NSTextParagraph else { return false }
        
        let string = paragraph.attributedString.string
        
        guard let paragraphRange = paragraph.elementRange,
              let nsRange = tcm.range(for: paragraphRange)
                
        else {
          print("Returned false: \(string)")
          return false
        }
        
        return true
        //
      } // END enumerate fragments
      //
    } // END perform edit
  }
  
  
  func setupScrollObservation() {
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleScrollViewDidScroll),
      name: NSView.boundsDidChangeNotification,
      object: enclosingScrollView?.contentView
    )
    
  }
  
  
}


extension NSTextContentManager {
  func range(for textRange: NSTextRange) -> NSRange? {
    let location = offset(from: documentRange.location, to: textRange.location)
    let length = offset(from: textRange.location, to: textRange.endLocation)
    if location == NSNotFound || length == NSNotFound { return nil }
    return NSRange(location: location, length: length)
  }
  
  func textRange(for range: NSRange) -> NSTextRange? {
    guard let textRangeLocation = location(documentRange.location, offsetBy: range.location),
          let endLocation = location(textRangeLocation, offsetBy: range.length) else { return nil }
    return NSTextRange(location: textRangeLocation, end: endLocation)
  }
}
