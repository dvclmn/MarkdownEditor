//
//  TextView+Computed.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 10/10/2024.
//

import AppKit
import Glyph
import Rearrange

extension MarkdownTextView {
  
  var documentNSRange: NSRange {
    guard let tcm = self.textLayoutManager?.textContentManager else { return .notFound }
    return NSRange(tcm.documentRange, provider: tcm)
  }
  
}
