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



public struct MarkdownTokeniser {
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


// MARK: -
// MARK: Regular expression-based tokenisers with explicit state management for context-free constructs

/// Actions taken in response to matching a token
///
/// The `token` component determines the token type of the matched pattern and `transition` determines the state
/// transition implied by the matched token. If the `transition` component is `nil`, the tokeniser stays in the current
/// state.
///
//public typealias TokenAction = (token: TokenType, transition: ((StateType) -> StateType)?)

/// Token descriptions
///

//enum MarkdownTokenType: Sendable {
//    case header
//    case bold
//    case italic
//    case link
//    case codeBlock
//    case listItem
//    case blockQuote
//    case plainText
//}
//
//let markdownPatterns: [MarkdownTokenDescription] = [
//    MarkdownTokenDescription(regex: /^#{1,6}\s.*$/, tokenType: .header),
//    MarkdownTokenDescription(regex: /\*\*.*?\*\*/, tokenType: .bold),
//    MarkdownTokenDescription(regex: /\*.*?\*/, tokenType: .italic),
//    MarkdownTokenDescription(regex: /\[.*?\]\(.*?\)/, tokenType: .link),
//    MarkdownTokenDescription(regex: /```[\s\S]*?```/, tokenType: .codeBlock),
//    MarkdownTokenDescription(regex: /^-\s.*$/, tokenType: .listItem),
//    MarkdownTokenDescription(regex: /^>\s.*$/, tokenType: .blockQuote)
//]

//let tokeniser = MarkdownTokeniser(tokenDescriptions: markdownPatterns)
//let tokens = tokeniser.tokenise(markdownText)


struct MarkdownTokenDescription {
    let regex: Regex<Substring>
    let tokenType: MarkdownTokenType
}


struct MarkdownTokeniser {
    let tokenDescriptions: [MarkdownTokenDescription]
    
    func tokenise(_ input: String) -> [Token] {
        var tokens: [Token] = []
        var currentIndex = input.startIndex
        
        while currentIndex < input.endIndex {
            let remainingSubstring = input[currentIndex...]
            
            if let (match, tokenType) = findFirstMatch(in: remainingSubstring) {
                let range = NSRange(match.range, in: input)
                tokens.append(Token(token: tokenType, range: range))
                currentIndex = match.range.upperBound
            } else {
                // Handle plain text
                let nextSpecialChar = findNextSpecialChar(in: remainingSubstring)
                let endIndex = nextSpecialChar?.startIndex ?? input.endIndex
                let range = NSRange(currentIndex..<endIndex, in: input)
                tokens.append(Token(token: .plainText, range: range))
                currentIndex = endIndex
            }
        }
        
        return tokens
    }
    
    private func findFirstMatch(in substring: Substring) -> (match: Regex<Substring>.Match, tokenType: MarkdownTokenType)? {
        for description in tokenDescriptions {
            if let match = try? description.regex.firstMatch(in: substring) {
                return (match, description.tokenType)
            }
        }
        return nil
    }
    
    private func findNextSpecialChar(in substring: Substring) -> String.Index? {
        // Implement logic to find the next Markdown special character
    }
}


/// For each possible state tag of the underlying tokeniser state, a mapping from token patterns to token kinds and
/// maybe a state transition to determine a new tokeniser state.
///
/// The matching of single lexeme tokens takes precedence over tokens with multiple lexemes. Within each category
/// (single or multiple lexeme tokens), the order of the token description in the array indicates the order of matching
/// preference; i.e., earlier elements take precedence.
///


      
extension StringProtocol {
    
    /// Tokenise `self` and return the encountered tokens.
    ///
    /// - Parameters:
    ///   - tokeniser: Pre-compiled tokeniser.
    ///   - startState: Starting state of the tokeniser.
    /// - Returns: The sequence of the encountered tokens.
    ///
    /// NB: If this function is applied to a `Substring`, the ranges of the tokens are relative to the start of the
    ///     `Substring` (and not of the `String` of which this `Substring` is a part).
    ///
    public func tokenise<TokenType, StateType>(
        with tokeniser: Tokeniser<TokenType, StateType>,
        state startState: StateType
    ) -> [Tokeniser<TokenType, StateType>.Token] {
        var state        = startState
        var currentStart = startIndex
        var tokens       = [] as [Tokeniser<TokenType, StateType>.Token]
        
        // Tokenise and set appropriate attributes
        while currentStart < endIndex {
            
            guard let stateTokeniser = tokeniser.states[state.tag],
                  let currentSubstring = self[currentStart...] as? Substring,
                  let result = try? stateTokeniser.regex.firstMatch(in: currentSubstring)
            else { break }  // no more match => stop
            
            logger.log("Hello it's a log: \(currentSubstring)")
            // We are going to look for the next lexeme from just after the one we just found
            currentStart = result.range.upperBound
            
            // New
            var tokenAction: TokenAction<TokenType, StateType>?
            if result[1].range != nil {
                tokenAction = stateTokeniser.stringTokenTypes[String(self[result.range])]
            } else {
                for i in 2..<result.count {
                    if result[i].range != nil {
                        if i - 2 < stateTokeniser.patternTokenTypes.count {
                            tokenAction = stateTokeniser.patternTokenTypes[i - 2]
                        } else {
                            let markdownIndex = i - 2 - stateTokeniser.patternTokenTypes.count
                            tokenAction = stateTokeniser.markdownTokenTypes[markdownIndex]
                        }
                        break
                    }
                }
            }
            
            if let action = tokenAction, !result.range.isEmpty {
                
                tokens.append(.init(type: action.token, range: NSRange(result.range, in: self)))
                
                // If there is an associated state transition function, apply it to the tokeniser state
                if let transition = action.transition { state = transition(state) }
                
            }
        }
        return tokens
    }
}

