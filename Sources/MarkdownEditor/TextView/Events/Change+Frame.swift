//
//  Change+Frame.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 7/10/2024.
//

import AppKit

extension MarkdownTextView {
  
  /// IMPORTANT:
  ///
  /// Trying to use a `layout` override, as a way to trigger parsing/styling/frame
  /// changes, is a BAD idea, and results in such messages as
  /// `attempted layout while textStorage is editing. It is not valid to cause the layoutManager to do layout while the textStorage is editing` etc
  ///
  //  public override func layout() {
  //    super.layout()
  
    public override var frame: NSRect {
      didSet {
        //      print("The text view's frame changed. Width: `\(frame.width)`, Height: `\(frame.height)`")
        //
        //
        //
        //    }
        //  } // END frame override
        
        /// IMPORTANT
        ///
        /// It's finally occured to me; watching changes to the frame or layout etc here *absolutely*
        /// causes loops and leaks etc, because I am sending this information back to SwiftUI,
        /// which is applying the information to it's `.frame()`, which in turn *affects the frame here*
        ///
        //  public override func layout() {
        //    super.layout()
        
        updateFrameDebounced()
        parseAndRedraw()
        // Do things in here when layout changes
      }
  }
  
  
  func updateFrameDebounced() {
    
    guard !isUpdatingFrame else {
      print("Let's let the previous frame adjustment happen, before starting another.")
      return
    }
    
    let newFrame = updateEditorHeight()
    
    // Check if the height has actually changed
    guard newFrame.height != lastSentHeight else {
//      print("Height unchanged. No update needed.")
      return
    }
    
    isUpdatingFrame = true
    
    Task {
      await frameDebouncer.processTask {
        Task { @MainActor in
          await self.infoHandler.update(newFrame)
          self.lastSentHeight = newFrame.height
          
          
          
          self.isUpdatingFrame = false
        }
      }
    }
    
    
  } // END update frame debounced
  
  
  
  func updateEditorHeight() -> EditorInfo.Frame {
    let extraHeightBuffer: CGFloat = configuration.isScrollable ? 0 : configuration.bottomSafeArea
    
    // Calculate the required height based on the text content
    var requiredHeight: CGFloat = 0
    if let layoutManager = self.layoutManager, let textContainer = self.textContainer {
      layoutManager.ensureLayout(for: textContainer)
      let usedRect = layoutManager.usedRect(for: textContainer)
      requiredHeight = ceil(usedRect.height) + extraHeightBuffer
    } else {
      requiredHeight = frame.height // Fallback if layoutManager or textContainer is unavailable
    }
    
    // Ensure the new height is at least a minimum value to avoid collapsing
    let minimumHeight: CGFloat = 50 // Adjust as needed
    let newHeight = max(requiredHeight, minimumHeight)
    
    return EditorInfo.Frame(
      width: frame.width,
      height: newHeight
    )
    
  }
  
}


