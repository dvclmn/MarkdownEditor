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
    
#if DEBUG
    // TODO: This is an expensive operation, and is only here temporarily for debugging.
    self.processMarkdownBlocks(highlight: true)
#endif
    
    Task { @MainActor in
      
      do {
        
        /// Adding this line seems to have been the difference between this function straight
        /// up not working on appear, to working correctly. This seems hacky though.
        ///
        /// The aim of this code here is to prompt the EditorInfo to populate with actual data
        /// when the view is initialised, without waiting for text/selection to change.
        try await Task.sleep(for: .seconds(0.1))
        
//        self.processingTime = await self.processFullDocumentWithTiming(self.string)
        
        
        
        let textInfo = self.generateTextInfo()
        let selectionInfo = self.generateSelectionInfo()
        await infoHandler.update(textInfo)
        await infoHandler.update(selectionInfo)
        
      } catch {
        
      }
    }
    
  }
  
}
