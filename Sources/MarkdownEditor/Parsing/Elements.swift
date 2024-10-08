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


public struct Markdown {
  
  struct Element: Hashable {
    var string: String
    var syntax: Markdown.Syntax
    var range: NSRange
    var rect: NSRect
  }
  
}

