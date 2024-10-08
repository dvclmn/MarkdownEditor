//
//  Settings.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 13/8/2024.
//

import SwiftUI
import TextCore
import Highlightr

extension MarkdownTextView {

  func textViewSetup() {
    
    print("How often does text view setup get called?")
    
    isEditable = self.configuration.isEditable

//    highlightr.setTheme(to: "xcode-dark")
    
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
   
    self.applyConfiguration()
    
  }
  
  
  func applyConfiguration() {
    
    print("How often does the apply config get called?")
    
    self.insertionPointColor = NSColor(self.configuration.theme.insertionPointColour)
    //
    textContainer?.lineFragmentPadding = configuration.insets
//    textContainer?.lineFragmentPadding = self.horizontalInsets

    textContainerInset = NSSize(width: 0, height: self.configuration.insets)
    
    self.font = NSFont.systemFont(ofSize: self.configuration.theme.fontSize)
    
    
    
//    let defaultAttributes: Attributes = [.foregroundColor: NSColor.textColor.withAlphaComponent(0.9)]
    
//    let defaults = self.configuration.defaultTypingAttributes
    
//    let nsString = self.string as NSString
    
    /// Typing attributes need to be set, otherwise important things like paragraph
    /// line spacing will be wrong, when I type new characters somewhere.
    ///
    self.typingAttributes = self.configuration.defaultTypingAttributes
    self.defaultParagraphStyle = self.configuration.defaultParagraphStyle
    
//    self.textStorage?.setAttributes(defaults, range: NSRange(location: 0, length: nsString.length))
    
    
  }

  
}
