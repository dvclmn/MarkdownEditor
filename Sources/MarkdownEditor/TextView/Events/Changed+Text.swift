//
//  TextChanged.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI
import BaseStyles


extension MarkdownTextView {
  
  
  
  public override func didChangeText() {
    
    super.didChangeText()
    
    Task { @MainActor in
      await parsingDebouncer.processTask { [weak self] in
        await self?.parseAllCases()
        await self?.styleMarkdown()
      }
    }

    onAppearAndTextChange()
    
  }
  
  
}

