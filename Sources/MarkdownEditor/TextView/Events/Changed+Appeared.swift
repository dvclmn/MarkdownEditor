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
    
    //    guard let layoutManager = self.layoutManager else {
    //      fatalError("Layout mananaager is nil")
    //    }
    
    onAppearAndTextChange()
    
    //    onAppearAndSelectionChanged()

    exploreTextSegments()
    
    
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
  
  //  func onAppearAndSelectionChanged() {
  //
  //    Task { @MainActor in
  //
  //      await self.paragraphDebouncer.processTask { [weak self] in
  //
  //        guard let self else { return }
  //
  //        await MainActor.run {
  //          self.infoUpdater.update(\.paragraph, value: self.paragraphHandler.currentParagraph.description)
  //
  //        } // END synchronous run
  //
  //      }
  //
  //    }
  //  }
  
  
  func exploreTextSegments() {
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager
    else { return }
    
    var paraCount: Int = 0
    
    tcm.performEditingTransaction {
      
      tlm.enumerateTextLayoutFragments(from: tlm.documentRange.location) { fragment in
        
        paraCount += 1
        guard let paragraph = fragment.textElement as? NSTextParagraph else { return false }
        
        let string = paragraph.attributedString.string
        
        guard let paragraphRange = paragraph.elementRange else {
          print("Returned false: \(string)")
          return false
        }
        
        let nsRange = NSRange(paragraphRange, provider: tcm)
        
        
        
        return true
        
      } // END enumerate fragments
      
      print("`enumerateTextLayoutFragments` found \(paraCount) paragraphs.")
      
    } // END perform edit
  }
  
  
  
}
