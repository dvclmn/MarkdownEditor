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

  
  public override var intrinsicContentSize: NSSize {
    guard let container = textContainer,
          let layoutManager = layoutManager else {
      return super.intrinsicContentSize
    }
    
    layoutManager.ensureLayout(for: container)

    let usedRect = layoutManager.usedRect(for: container).size

    return usedRect

  }
  
  
  
  func updateFrameDebounced() {
    
    Task {
      await frameDebouncer.processTask {
        Task { @MainActor in
          
          let newHeight = self.updatedEditorHeight()
          
          
          
          await self.infoHandler.update(newHeight)
        }
      }
    } // END Task
  } // END update frame debounced
  
  
  
  func updatedEditorHeight() -> EditorInfo.Frame {
    
    invalidateIntrinsicContentSize()
    
    let newSize = intrinsicContentSize
    let extraHeightBuffer: CGFloat = configuration.isScrollable ? 0 : configuration.bottomSafeArea
    let minHeight: CGFloat = 80
    
    let adjustedHeight: CGFloat = newSize.height + extraHeightBuffer

    let finalHeight = max(adjustedHeight, minHeight)
    
    return EditorInfo.Frame(
      width: newSize.width,
      height: finalHeight
    )
    
  }
  
}


