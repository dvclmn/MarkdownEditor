//
//  Settings.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 13/8/2024.
//

import SwiftUI
import TextCore

extension MarkdownTextView {

  func textViewSetup() {
    
    isEditable = self.configuration.isEditable
    
    if self.configuration.isScrollable {
      
      /// *Scrolling* version
      isVerticallyResizable = true
      isHorizontallyResizable = true
      
      autoresizingMask = [.width, .height]
      
      textContainer?.widthTracksTextView = true
      textContainer?.heightTracksTextView = false
      
    } else {
      
      /// *NON-scrolling* version
      
      /// Setting `isVerticallyResizable` to false seems to make a huge difference,
      /// and SwiftUI just seems to take care of the height stuff. KEEP THIS FALSE for
      /// (seemingly) predictable, normal, horizontal text reflow.
      isVerticallyResizable = false
      isHorizontallyResizable = false
      
      autoresizingMask = [.width, .height]
      
      textContainer?.widthTracksTextView = true
      textContainer?.heightTracksTextView = false
      
    }
    
    isSelectable = true
    drawsBackground = false
    allowsUndo = true
    isRichText = false
    smartInsertDeleteEnabled = false
    
//    let max = CGFloat.greatestFiniteMagnitude
    
//    minSize = NSSize.zero
//    maxSize = NSSize(width: max, height: max)
    
    
    
    

    
//    textContainer?.containerSize = NSSize(width: bounds.width, height: max)

    self.applyConfiguration()
  }
  
  
  func applyConfiguration() {
    
    self.insertionPointColor = NSColor(self.configuration.theme.insertionPointColour)
    //
    textContainer?.lineFragmentPadding = self.configuration.insets
    textContainerInset = NSSize(width: 0, height: self.configuration.insets)
    
    self.font = NSFont.systemFont(ofSize: self.configuration.theme.fontSize)
    
    //
//        typingAttributes = self.configuration.defaultTypingAttributes
    
//    let defaultAttributes: Attributes = [.foregroundColor: NSColor.textColor.withAlphaComponent(0.9)]
    
//    let defaults = self.configuration.defaultTypingAttributes
    
//    let nsString = self.string as NSString
    
    self.defaultParagraphStyle = self.configuration.defaultParagraphStyle
    
//    self.textStorage?.setAttributes(defaults, range: NSRange(location: 0, length: nsString.length))
    
    
  }

  
}
