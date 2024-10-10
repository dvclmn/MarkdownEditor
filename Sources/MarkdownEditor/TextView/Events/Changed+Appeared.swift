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
  
  public override func viewDidMoveToWindow() {
    
    super.viewDidMoveToWindow()
    
    /// This allows a quick parse on load, and then the debounced
    /// parsing is over in `Changed+Text.swift`
    DispatchQueue.main.async {
      self.parseAllCases()
      self.styleMarkdown()
    }
    
    onAppearAndTextChange()
    
    let codeFontSize: CGFloat = 13
    
    highlightr.theme.setCodeFont(NSFont.monospacedSystemFont(ofSize: codeFontSize, weight: .medium))
    
    //    parseMarkdownDebounced()
    //    styleMarkdownDebounced()
    
    //        exploreTextSegments()
    
    
    //    basicInlineMarkdown()
    
  }
  
  func onAppearAndTextChange() {
    
    Task { @MainActor in
      
      let newSize = self.updatedEditorHeight()
      let newLines: Int = countLinesTK2()
      
      
      infoUpdater.update(\.elementSummary, value: self.elementsSummary)
      
      infoUpdater.update(\.size, value: newSize)
      infoUpdater.update(\.lineCount, value: newLines)
      
    }
    
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
  
  
  
}
