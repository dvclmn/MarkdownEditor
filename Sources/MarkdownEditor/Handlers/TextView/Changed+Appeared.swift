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
    
    self.onTextChange(self.calculateTextInfo())
    
    self.onEditorHeightChange(self.editorHeight)
    
    setupViewportLayoutController()
    
    //    self.testStyles()
    
    //    self.markdownBlocks = self.processMarkdownBlocks(highlight: true)
    
    self.didChangeScroll() // Just to nudge it
    
    Task {
      let executionTime = await self.parser.processFullDocumentWithTiming(self.string)
    }
    
  }
  
}
