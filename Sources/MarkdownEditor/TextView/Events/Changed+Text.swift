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
    
    
    updateFrameDebounced()
    
    parseMarkdownDebounced()
    
    updateElementSummary()
//    styleMarkdownDebounced()
    
    
    //    updateParagraphInfo(firstSelected: nil)
    
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
  
  /// Initiates a series of delegate messages (and general notifications) to determine
  /// whether modifications can be made to the characters and attributes of the receiver’s text.
  ///
  /// true to allow the change, false to prohibit it.
  ///
  /// This method checks with the delegate as needed using
  /// `textShouldBeginEditing(_:)`and `textView(_:shouldChangeTextIn:replacementString:)`.
  ///
  /// This method must be invoked at the start of any sequence of user-initiated editing changes.
  /// If your subclass of NSTextView implements methods that modify the text, make sure to
  /// invoke this method to determine whether the change should be made. If the change is allowed,
  /// complete the change by invoking the didChangeText() method.
  ///
  /// Special Considerations
  /// If you override this method, you must call super at the beginning of the override.
  /// If the receiver is not editable, this method automatically returns false. This result prevents
  /// instances in which a text view could be changed by user actions even though it had
  /// been set to be non-editable.
  ///
  /// In macOS 10.4 and later, if there are multiple selections, this method acts on the
  /// first selected subrange.
  ///
//  public override func shouldChangeText(
//    in affectedCharRange: NSRange,
//    replacementString: String?
//  ) -> Bool {
//    super.shouldChangeText(in: affectedCharRange, replacementString: replacementString)
//    
//    //    print("`Should change text` \(Date.now)")
//
//    
//    return true
//  } // END shouldChangeText
  

}

