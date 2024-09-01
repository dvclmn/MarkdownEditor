//
//  Changed+Appeared.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import SwiftUI

extension MarkdownTextView {
  
  public override func viewDidMoveToWindow() {
    
    super.viewDidMoveToWindow()
    
    setupViewportLayoutController()
    
    Task {
      await runMainMarkdownParse()
    }
    
    
  }
  
  func runMainMarkdownParse() async {
    Task { @MainActor in
      
      /// Adding this line seems to have been the difference between this function straight
      /// up not working on appear, to working correctly. This seems hacky though.
      ///
      /// The aim of this code here is to prompt the EditorInfo to populate with actual data
      /// when the view is initialised, without waiting for text/selection to change.
      
      await self.applyMarkdownStyles()
      
      let textInfo = self.generateTextInfo()
      let selectionInfo = self.generateSelectionInfo()
      await infoHandler.update(textInfo)
      await infoHandler.update(selectionInfo)
      
    } // END Task
    
    await self.parseMarkdown()
    
  }
  
  
}
