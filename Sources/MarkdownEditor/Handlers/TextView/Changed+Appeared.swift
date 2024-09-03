//
//  Changed+Appeared.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import SwiftUI

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
    
    
    
    tlm.enumerateTextLayoutFragments(from: tlm.documentRange.location) { fragment in
      
      guard let paragraph = fragment.textElement as? NSTextParagraph else { return false }
      
      let string = paragraph.attributedString.string
      
      guard let paragraphRange = paragraph.elementRange,
            let range = NSTextRange(location: paragraphRange.location, end: paragraphRange.endLocation)
              
      else {
        print("Returned false: \(string)")
        return false
      }
      
      tcm.performEditingTransaction {
        
        
        for syntax in Markdown.Syntax.allCases {
          
          guard let regex = syntax.regex else { continue }
          
          if string.contains(regex) {
            print(string)
            
            tlm.setRenderingAttributes(syntax.contentRenderingAttributes, for: range)
            
          } else {
//            tlm.removeRenderingAttribute(.foregroundColor, for: range)
          }
          
        }
        

      } // END perform edit

      
//      for lineFragment in fragment.textLineFragments {
//        print("Line fragment: \(lineFragment)")
        
//        lineFragment
//      }
      
//      print("\(paragraph.attributedString)")
      
//      print("I want to know what a text segment is: \(fragment.)")
      
      return true

    }
    
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
