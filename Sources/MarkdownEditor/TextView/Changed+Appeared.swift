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
        
        guard let paragraphRange = paragraph.elementRange
        else {
          print("Returned false: \(string)")
          return false
        }
        
        let nsRange = NSRange(paragraphRange, provider: tcm)
        
        
        
        
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
