//
//  Change+Frame.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 7/10/2024.
//

import AppKit

extension MarkdownTextView {
  
  public override func layout() {
    super.layout()
    
    // Prevent processing if already updating frame
    if isUpdatingFrame { return }

    
    // Check if the frame has changed
    if self.frame != lastFrame {
      lastFrame = self.frame
      frameDidChange()
    }
    
  }
  
  func updateFrameDebounced() {
    
    Task {
      await adjustWidthDebouncer.processTask {
        Task { @MainActor in
          let heightUpdate = self.updateEditorHeight()
          await self.infoHandler.update(heightUpdate)
          
          // Reset the guard flag after updates
          self.isUpdatingFrame = false
        }
      } // END debounce process task
    } // END outer task
  }
  
  
  func frameDidChange() {
    
    print("Frame size changed. Width: `\(self.frame.size.width)`, Height: `\(self.frame.size.height)`")
    
    guard let container = textContainer else {
      print("Couldn't get text container")
      return
    }
    
    // Set the guard flag before making changes
    isUpdatingFrame = true
    
    container.lineFragmentPadding = self.horizontalInsets
    
    updateFrameDebounced()
     
  }
  
  func updateEditorHeight() -> EditorInfo.Frame {
    //    guard let tlm = self.textLayoutManager else {
    //      print("Couldn't get the tlm, need to try another way")
    //      return .init()
    //    }
    
    guard let lm = self.layoutManager else {
      print("Couldn't get the lm")
      
      fatalError("Couldn't get the layout manager, and need this frame to work, so I've crashed.")
      //      return .init()
    }
    
    guard let container = self.textContainer else {
      fatalError("Couldn't get the text container.")
    }
    
    let extraHeightBuffer: CGFloat = configuration.isScrollable ? 0 : configuration.bottomSafeArea
    
    let newHeight = lm.usedRect(for: container).size.height + extraHeightBuffer
    
    if newHeight != frame.height {
      
      let editorFrame = EditorInfo.Frame(
        width: frame.width,
        height: newHeight
      )
      
      print("Editor height updated to: \(editorFrame.height), width: \(editorFrame.width)")
      
      self.invalidateIntrinsicContentSize()
      self.needsLayout = true
      self.needsDisplay = true
      
      return editorFrame
      
    } else {
      // No change needed
      return EditorInfo.Frame(
        width: frame.width,
        height: frame.height
      )
    }
  }

}


