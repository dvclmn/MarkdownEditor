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
    
//    Task { @MainActor in
//      await self.infoDebouncer.processTask {
//        
//        let newInfo = "Updated metrics or debugging info"
//        self.infoHandler.updateMetric(keyPath: \.testMessage, value: newInfo)
//      }
//    }
//
    
//    onAppearAndTextChange()
    
    /// I have observed this only working if I place this directly here in `viewDidMoveToWindow`.
    /// Nesting it in another function, then calling that function here, seems not to work?
    Task { @MainActor in
      
      let newSize = self.updatedEditorHeight()
      let newInfo = self.elements.count.string

      await infoUpdater.updateSize(newSize)
//      await infoUpdater.updateMetric(\.elementSummary, value: newInfo)
    }
    
//    Task {
//      await parsingDebouncer.processTask {
//        
//        /// I learned that `Task { @MainActor in` is `async`,
//        /// whereas `await MainActor.run {` is synchronous.
//        ///
//        //        await MainActor.run {
//        Task { @MainActor in
//          for syntax in Markdown.Syntax.testCases {
//            self.parseSyntax(syntax)
//          }
//        }
//      }
//    }
    

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
  
  func onAppearAndTextChange() {
    
    parseMarkdownDebounced()
    
    displayTypingAttributes()
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
