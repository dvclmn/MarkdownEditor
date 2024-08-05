//
//  LanguageConfiguration.swift
//
//
//  Created by Manuel M T Chakravarty on 03/11/2020.
//
//  Language configurations determine the linguistic characteristics that are important for the editing and display of
//  code in the respective languages, such as comment syntax, bracketing syntax, and syntax highlighting
//  characteristics.
//
//  We adopt a two-stage approach to syntax highlighting. In the first stage, basic context-free syntactic constructs
//  are being highlighted. In the second stage, contextual highlighting is performed on top of the highlighting from
//  stage one. The second stage relies on information from a code analysis subsystem, such as SourceKit.
//
//  Curent support here is only for the first stage.

import RegexBuilder
import os

import SwiftUI


public struct MarkdownConfiguration {
    public enum Token: Equatable {
        case header(level: Int)
        case bold
        case italic
        case link
        case codeBlock
        case inlineCode
        case listItem
        case blockQuote
        case horizontalRule
        case plainText
    }

    public let name: String = "Markdown"
    public let tokenPatterns: [TokenPattern]

    public struct TokenPattern {
        let regex: Regex<Substring>
        let tokenType: Token
    }

    public init() {
        self.tokenPatterns = [
            TokenPattern(regex: /^#{1,6}\s.*$/, tokenType: .header(level: 1)), // Simplified, actual implementation would determine level
            TokenPattern(regex: /\*\*.*?\*\*/, tokenType: .bold),
            TokenPattern(regex: /\*.*?\*/, tokenType: .italic),
            TokenPattern(regex: /\[.*?\]\(.*?\)/, tokenType: .link),
            TokenPattern(regex: /```[\s\S]*?```/, tokenType: .codeBlock),
            TokenPattern(regex: /`[^`\n]+`/, tokenType: .inlineCode),
            TokenPattern(regex: /^-\s.*$/, tokenType: .listItem),
            TokenPattern(regex: /^>\s.*$/, tokenType: .blockQuote),
            TokenPattern(regex: /^([-*_]){3,}$/, tokenType: .horizontalRule)
        ]
    }
}
