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


public struct Tokeniser {
    
    
    public struct Token: Equatable {
        
        let type: MarkdownSyntax
        public var range: NSRange
        
        public init(type: MarkdownSyntax, range: NSRange) {
            self.type = type
            self.range = range
        }
        
        /// Produce a copy with an adjusted location of the token by shifting it by the given amount.
        ///
        /// - Parameter amount: The amount by which to shift the token. (Positive amounts shift to the right and negative
        ///     ones to the left.)
        ///
        public func shifted(by amount: Int) -> Token {
          return Token(
            type: type,
            range: NSRange(
                location: max(0, range.location + amount),
                length: range.length)
          )
        }
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
                
                let nextTokenStart = findNextTokenStart(in: remainingSubstring)
                let endIndex = nextTokenStart ?? input.endIndex
                let range = NSRange(currentIndex..<endIndex, in: input)
                tokens.append(Token(type: .body, range: range))
                currentIndex = endIndex
            }
        }
        
        return tokens
    }
    
    private func findFirstMatch(in substring: Substring) -> (match: Regex<Substring>.Match, syntax: MarkdownSyntax)? {
        for syntax in MarkdownSyntax.allCases {
            if let match = try? syntax.regex.firstMatch(in: substring) {
                return (match, syntax)
            }
        }
        return nil
    }
    
    private func findNextTokenStart(in substring: Substring) -> String.Index? {
        for syntax in MarkdownSyntax.allCases {
            if let match = try? syntax.regex.firstMatch(in: substring) {
                return match.range.lowerBound
            }
        }
        return nil
    }
}
