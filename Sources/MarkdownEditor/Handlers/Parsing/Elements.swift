//
//  Elements.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 2/9/2024.
//

import Foundation
import AppKit
import BaseHelpers
import TextCore


extension MarkdownTextView {
  
  
  func addMarkdownElement(_ element: Markdown.Element) {
    elements.append(element)
    needsDisplay = true
  }


}
