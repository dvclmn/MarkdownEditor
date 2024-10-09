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
  
//  public override func viewDidMoveToSuperview() {
//    super.viewDidMoveToSuperview()
//    
//    //    if configuration.isScrollable {
//    //      setupScrollObservation()
//    //    }
//  }
  
  public override func viewDidMoveToWindow() {
    
    super.viewDidMoveToWindow()
    
//    setupViewportLayoutController()
    
    Task {
      await self.infoDebouncer.processTask {
        
        let newInfo = "Updated metrics or debugging info"
        await self.infoHandler.updateInfo(newInfo)
      }
    }
    
    updateFrameDebounced()

//    let codeFontSize: CGFloat = 13

//    highlightr.setTheme(to: "xcode-dark")
//    
//    highlightr.theme.codeFont = NSFont.monospacedSystemFont(ofSize: codeFontSize, weight: .medium)
//    highlightr.theme.boldCodeFont = NSFont.monospacedSystemFont(ofSize: codeFontSize, weight: .bold)
    
    
//    parseMarkdownDebounced()
//    styleMarkdownDebounced()
    
    //        exploreTextSegments()
    
    
//    basicInlineMarkdown()
    
  }
  
//  func lineCount() {
//    
//  }
 
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
  

  
}
