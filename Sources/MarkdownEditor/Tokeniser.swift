//
//  Tokeniser.swift
//
//
//  Created by Manuel M T Chakravarty on 03/11/2020.

import os
#if os(iOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

import RegexBuilder

import Rearrange



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
            TokenPattern(regex: /^>\s.*$/, tokenType: .blockQuote)
//            TokenPattern(regex: /^([-*_]){3,}$/, tokenType: .horizontalRule)
        ]
    }
}


public struct Tokeniser {
    private let configuration: MarkdownConfiguration

    public init(configuration: MarkdownConfiguration = MarkdownConfiguration()) {
        self.configuration = configuration
    }

    public func tokenise(_ input: String) -> [Token] {
        var tokens: [Token] = []
        var currentIndex = input.startIndex

        while currentIndex < input.endIndex {
            let remainingSubstring = input[currentIndex...]
            
            if let (match, tokenType) = findFirstMatch(in: remainingSubstring) {
                let range = NSRange(match.range, in: input)
                tokens.append(Token(type: tokenType, range: range))
                currentIndex = match.range.upperBound
            } else {
                // Handle plain text
                let nextTokenStart = findNextTokenStart(in: remainingSubstring)
                let endIndex = nextTokenStart ?? input.endIndex
                let range = NSRange(currentIndex..<endIndex, in: input)
                tokens.append(Token(type: .plainText, range: range))
                currentIndex = endIndex
            }
        }

        return tokens
    }

    private func findFirstMatch(in substring: Substring) -> (match: Regex<Substring>.Match, tokenType: MarkdownConfiguration.Token)? {
        for pattern in configuration.tokenPatterns {
            if let match = try? pattern.regex.firstMatch(in: substring) {
                return (match, pattern.tokenType)
            }
        }
        return nil
    }

    private func findNextTokenStart(in substring: Substring) -> String.Index? {
        for pattern in configuration.tokenPatterns {
            if let match = try? pattern.regex.firstMatch(in: substring) {
                return match.range.lowerBound
            }
        }
        return nil
    }

    public struct Token {
        public let type: MarkdownConfiguration.Token
        public let range: NSRange
    }
}
