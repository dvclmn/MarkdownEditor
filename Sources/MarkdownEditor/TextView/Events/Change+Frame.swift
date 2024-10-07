//
//  Change+Frame.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 7/10/2024.
//

import AppKit

extension MarkdownTextView {
  
  
  public override var frame: NSRect {
    didSet {
      print("The text view's frame changed. Width: `\(frame.width)`, Height: `\(frame.height)`")
      
      updateFrameDebounced()
      
      //        onFrameChange()
    }
  } // END frame override
  
//  public override func layout() {
//    super.layout()
//    
//    // Do things in here when layout changes
//    
//  }
  
  func updateFrameDebounced() {
    
    guard !isUpdatingFrame else {
      print("Let's let the previous frame adjustment happen, before starting another.")
      return
    }
    
    isUpdatingFrame = true

    guard let container = textContainer else {
      print("Couldn't get text container")
      return
    }
    
    
    container.lineFragmentPadding = self.horizontalInsets
    
    Task {
      await adjustWidthDebouncer.processTask {
        Task { @MainActor in
          
          let heightUpdate = self.updateEditorHeight()
          await self.infoHandler.update(heightUpdate)
          
          self.isUpdatingFrame = false
          
        }
      } // END debounce process task
    } // END outer task
    
    
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


