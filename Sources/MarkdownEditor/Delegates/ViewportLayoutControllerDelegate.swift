//
//  MarkdownViewportDelegate.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI

class MarkdownViewportDelegate: NSObject, @preconcurrency  NSTextViewportLayoutControllerDelegate {
  weak var textView: MarkdownTextView?
  
  var statusString: String = ""
  
  @MainActor func viewportBounds(for textViewportLayoutController: NSTextViewportLayoutController) -> CGRect {
    guard let textView = textView else {
      print("Couldn't get textView for viewportBounds")
      return .zero
    }
    return textView.visibleRect
  }
  
  // This method is called for each text layout fragment that needs to be rendered
  // Called when a new layout fragment enters the viewport
  func textViewportLayoutController(_ textViewportLayoutController: NSTextViewportLayoutController, configureRenderingSurfaceFor textLayoutFragment: NSTextLayoutFragment) {
    print("Rendering fragment: \(textLayoutFragment)")
  }
  
  // Called just before layout occurs
  func textViewportLayoutControllerWillLayout(_ textViewportLayoutController: NSTextViewportLayoutController) {
    
    self.statusString = "Layout process is about to begin"
  }
  
  // Called just after layout occurs
  func textViewportLayoutControllerDidLayout(_ textViewportLayoutController: NSTextViewportLayoutController) {
    
    self.statusString = "Layout process has completed"
  }
  
  func textViewportLayoutController(
    _ textViewportLayoutController: NSTextViewportLayoutController,
    viewportBoundsDidChange previousViewportBounds: CGRect
  ) {
    // Called when the viewport bounds change
  }

}
