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
    
    let height = self.generateEditorHeight()
    let textInfo = self.generateTextInfo()
    let selectionInfo = self.generateSelectionInfo()
    
    Task { @MainActor in
      await infoHandler.update(textInfo)
      await infoHandler.update(selectionInfo)
      await infoHandler.update(height)
    }
    
    
    //    self.testStyles()
    
    //    self.markdownBlocks = self.processMarkdownBlocks(highlight: true)
    
//    self.didChangeScroll() // Just to nudge it
    
    Task {
      let executionTime = await self.parser.processFullDocumentWithTiming(self.string)
    }
    
  }
  
}
