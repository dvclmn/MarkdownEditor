//
//  DataModel.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import SwiftUI
import RegexBuilder


extension Regex<Substring>: @unchecked @retroactive Sendable {
  
}

extension NSTextRange: @unchecked @retroactive Sendable {
  
}

extension NSParagraphStyle: @unchecked @retroactive Sendable {
  
}

public typealias MarkdownRegexOutput = Regex<Substring>

public struct Markdown {

}
