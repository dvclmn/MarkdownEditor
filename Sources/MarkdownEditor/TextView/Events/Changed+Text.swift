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
    
    onAppearAndTextChange()
    
  }
  
  func updateElementSummary() {
    
//    var totalElementSummary: String {
//      self.elements.map { element in
//        let result = """
//        Total count: \(element.)
//        """
//      }
//    }
    
    Task { @MainActor in
      await self.infoDebouncer.processTask {
        
        let newInfo: String = await self.elements.count.string
        self.infoHandler.updateMetric(keyPath: \.elementSummary, value: newInfo)
      }
    }
  }
  

}

