//
//  ContentStorage.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 13/8/2024.
//

import SwiftUI
import STTextKitPlus

final class MarkdownContentStorage: NSTextContentStorage {

}

class MarkdownBlock: NSTextElement {
  
  let range: NSTextRange
  let syntax: Markdown.Syntax
  
  init(
    range: NSTextRange,
    syntax: Markdown.Syntax
  ) {
    self.range = range
    self.syntax = syntax
    super.init()
  }
}
