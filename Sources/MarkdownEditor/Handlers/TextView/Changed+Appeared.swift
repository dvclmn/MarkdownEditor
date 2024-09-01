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
    
    onAppearAndTextChange()

  }
  
  
  
}
