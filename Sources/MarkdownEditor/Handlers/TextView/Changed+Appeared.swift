//
//  Changed+Appeared.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import SwiftUI

extension MarkdownTextView {
  
  public override func viewDidMoveToWindow() {
    
    super.viewDidMoveToWindow()
    
    
    setupViewportLayoutController()
    setupViewportObservation()
    
    onAppearAndTextChange()
    

  }
  
  func setupViewportObservation() {
    
    print("Running viewport observation")
    
    guard let textLayoutManager = self.textLayoutManager else { return }
    
    viewportObservation = textLayoutManager.textViewportLayoutController.observe(\.viewportBounds) { [weak self] (controller, change) in
      guard let self = self else {
        print("Self couldn't equal self")
        return
      }
      
      
      // Handle viewport bounds change
      let newBounds = controller.viewportBounds
      
      print("Bounds: \(controller.viewportBounds)")
      
      DispatchQueue.main.async {
        self.handleViewportChange(newBounds: newBounds)
      }
    }
  }

  func handleViewportChange(newBounds: CGRect) {
    // Update your data or UI based on the new viewport bounds
    // For example:
    // 1. Update visible elements
    // 2. Trigger re-rendering of specific parts
    // 3. Update editor info
    
    // Example: Update editor info
//    editorInfo.viewportBounds = newBounds
//    onInfoUpdate(editorInfo)
    
    print("New visible bounds: \(newBounds)")
    
    // You might want to call your parsing or rendering logic here
    // if it depends on the visible area
  }
  
 

  
}
