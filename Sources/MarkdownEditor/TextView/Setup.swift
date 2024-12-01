//
//  Settings.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 13/8/2024.
//

import SwiftUI
import BaseHelpers
//import Highlightr

extension MarkdownTextView {
  
  func textViewSetup() {
    
    isEditable = self.configuration.isEditable
    isSelectable = true
    drawsBackground = false
    allowsUndo = true
    isRichText = false
    smartInsertDeleteEnabled = false
    usesFindBar = true
    usesFindPanel = true
    
    self.applyConfiguration()
    
    //    highlightr.setTheme(to: "xcode-dark")
    
    if self.configuration.isScrollable, let scrollView = scrollView {
      
      /// *Scrolling* version
      
      scrollView.hasVerticalScroller = true
      scrollView.drawsBackground = false
      scrollView.documentView = self
      scrollView.additionalSafeAreaInsets.bottom = configuration.bottomSafeArea
      
      let contentSize = scrollView.contentSize
      
      textContainer?.containerSize = CGSize(width: contentSize.width, height: CGFloat.greatestFiniteMagnitude)
      
      minSize = CGSize(width: 0, height: 0)
      maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
      
      isVerticallyResizable = true
      isHorizontallyResizable = false
      
      autoresizingMask = [.width]
      
      textContainer?.widthTracksTextView = true
      textContainer?.heightTracksTextView = false
      
      
    } else {
      
      /// *NON-scrolling* version
      
      /// Setting `isVerticallyResizable` to false seems to make a huge difference,
      /// and SwiftUI just seems to take care of the height stuff. KEEP THIS FALSE for
      /// (seemingly) predictable, normal, horizontal text reflow.
      
      setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
      setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
      setContentHuggingPriority(.defaultLow, for: .horizontal)
      setContentHuggingPriority(.defaultHigh, for: .vertical)
      
      isVerticallyResizable = false
      isHorizontallyResizable = false
      
      autoresizingMask = [.width, .height]
      
      textContainer?.widthTracksTextView = true
      textContainer?.heightTracksTextView = false
      
    }
    
    
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
