////
////  Tokeniser.swift
////
////
////  Created by Manuel M T Chakravarty on 03/11/2020.
//
//import os
//#if os(iOS) || os(visionOS)
//import UIKit
//#elseif os(macOS)
//import AppKit
//#endif
//
//import RegexBuilder
//
//import Rearrange
//
//
//private let logger = Logger(subsystem: "org.justtesting.MarkdownEditorView", category: "Tokeniser")
//
//public enum EditorMode {
//    case markdown
//    case code(language: LanguageConfiguration)
//    
//}
//
//
//// MARK: -
//// MARK: Regular expression-based tokenisers with explicit state management for context-free constructs
//
///// Actions taken in response to matching a token
/////
///// The `token` component determines the token type of the matched pattern and `transition` determines the state
///// transition implied by the matched token. If the `transition` component is `nil`, the tokeniser stays in the current
///// state.
/////
////public typealias TokenAction = (token: TokenType, transition: ((StateType) -> StateType)?)
//
///// Token descriptions
/////
//public struct TokenDescription {
//    
//    /// The regex to match the token.
//    ///
//    public let regex: Regex<Substring>
//    
//    ///
//    public let singleLexeme: String?
//    
//    /// The action to take when the token gets matched.
//    ///
////    public let action: TokenAction
//    
//    public init(
//        regex: Regex<Substring>,
//        singleLexeme: String? = nil
////        action: TokenAction<TokenType, StateType>
//    ) {
//        self.regex = regex
//        self.singleLexeme = singleLexeme
////        self.action = action
//    }
//    
//}
//
//
///// For each possible state tag of the underlying tokeniser state, a mapping from token patterns to token kinds and
///// maybe a state transition to determine a new tokeniser state.
/////
///// The matching of single lexeme tokens takes precedence over tokens with multiple lexemes. Within each category
///// (single or multiple lexeme tokens), the order of the token description in the array indicates the order of matching
///// preference; i.e., earlier elements take precedence.
/////
//
//
//public typealias TokenDictionary = [TokenDescription]
//
//
//
///// Pre-compiled regular expression tokeniser.
/////
///// The `TokenType` identifies the various tokens that can be recognised by the tokeniser.
/////
//public struct Tokeniser {
//    
//    /// The tokens produced by the tokensier.
//    ///
//    public struct Token: Equatable {
//        
//        /// The range in the tokenised string where the token occurred.
//        ///
//        public var range: NSRange
//        
//        public init(
//            range: NSRange
//        ) {
//            self.range = range
//        }
//        
//        /// Produce a copy with an adjusted location of the token by shifting it by the given amount.
//        ///
//        /// - Parameter amount: The amount by which to shift the token. (Positive amounts shift to the right and negative
//        ///     ones to the left.)
//        ///
//        public func shifted(by amount: Int) -> Token {
//            return Token(range: NSRange(location: max(0, range.location + amount), length: range.length))
//        }
//    } // END struct Token
//    
//
//    /// Create a tokeniser from the given token dictionary.
//    ///
//    /// - Parameters:
//    ///   - tokenMap: The token dictionary determining the lexemes to match and their token type.
//    /// - Returns: A tokeniser that matches all lexemes contained in the token dictionary.
//    ///
//    /// The tokeniser is based on an eager regular expression matcher. Hence, it will match the first matching alternative
//    /// in a sequence of alternatives. To deal with string patterns, where some patterns may be a prefix of another, the
//    /// string patterns are turned into regular expression alternatives longest string first. However, patterns consisting
//    /// of regular expressions are tried in an indeterminate order. Hence, no pattern should have as a full match a prefix
//    /// of another pattern's full match, to avoid indeterminate results. Moreover, strings match before patterns that
//    /// cover the same lexeme.
//    ///
//    /// For each token that has got a multi-character lexeme, the tokeniser attributes the first character of that lexeme
//    /// with a token attribute marked as being the lexeme head character. All other characters of the lexeme —what we call
//    /// the token body— are marked with the same token attribute, but without being identified as a lexeme head. This
//    /// distinction is crucial to be able to distinguish the boundaries of multiple successive tokens of the same type.
//    ///
//    public init?(for tokenMap: TokenDictionary)
//    {
//        
//        func combine(alternatives: [TokenDescription]) -> Regex<Substring>? {
//            switch alternatives.count {
//            case 0:  return nil
//            case 1:  return alternatives[0].regex
//            default: return alternatives[1...].reduce(alternatives[0].regex) { (regex, alternative) in
//                Regex { ChoiceOf { regex; alternative.regex } }
//            }
//            }
//        }
//        
//        
//        func combineWithCapture(alternatives: [TokenDescription]) -> Regex<AnyRegexOutput>? {
//            switch alternatives.count {
//            case 0:  return nil
//            case 1:  return Regex(Regex { Capture { alternatives[0].regex } })
//            default: return alternatives[1...].reduce(Regex(Regex { Capture { alternatives[0].regex } })) { (regex, alternative) in
//                Regex(Regex { ChoiceOf { regex; Capture { alternative.regex } } })
//            }
//            }
//        }
//        
//        
//        func longestFirst(lhs: TokenDescription, rhs: TokenDescription) -> Bool
//        {
//            (lhs.singleLexeme ?? "").count >= (rhs.singleLexeme ?? "").count
//        }
//        
//        
//        
//        
//        
//        func tokeniser(for stateMap: [TokenDescription]) -> Tokeniser?
//        {
//            
//            // NB: The list of single lexeme tokens need to be from longest to shortest, to ensure that the longer one is
//            //     chosen if the lexeme of one token is a prefix of another token's lexeme.
//            let singleLexemeTokens = stateMap.filter {
//                $0.singleLexeme != nil
//            }.sorted(by: longestFirst)
//                
//            let multiLexemeTokens = stateMap.filter {
//                $0.singleLexeme == nil
//            }
//            let singleLexemeTokensRegex = combine(alternatives: singleLexemeTokens)
//            
//            let multiLexemeTokensRegex = combineWithCapture(alternatives: multiLexemeTokens)
//            
//            let regex: Regex<AnyRegexOutput>? = switch (singleLexemeTokensRegex, multiLexemeTokensRegex) {
//            case (nil, nil):
//                nil
//            case (.some(let single), nil):
//                Regex(Regex { Capture { single } })
//            case (nil, .some(let multi)):
//                multi
//            case (.some(let single), .some(let multi)):
//                Regex(Regex { ChoiceOf {
//                    Capture { single }
//                    multi
//                }})
//            }
//            return if let regex {
//                
//                Tokeniser.State(
//                    regex: regex,
//                    stringTokenTypes: [String: TokenAction<TokenType, StateType>](stringTokenTypes){ (left, right) in return left },
//                    patternTokenTypes: patternTokenTypes,
//                    markdownTokenTypes: markdownTokenTypes
//                )
//                
//            } else { nil }
//        }
//        
//        states = tokenMap.compactMapValues{ tokeniser(for: $0) }
//        if states.isEmpty { logger.debug("failed to compile regexp"); return nil }
//    }
//    
//}
//      
//extension StringProtocol {
//    
//    /// Tokenise `self` and return the encountered tokens.
//    ///
//    /// - Parameters:
//    ///   - tokeniser: Pre-compiled tokeniser.
//    ///   - startState: Starting state of the tokeniser.
//    /// - Returns: The sequence of the encountered tokens.
//    ///
//    /// NB: If this function is applied to a `Substring`, the ranges of the tokens are relative to the start of the
//    ///     `Substring` (and not of the `String` of which this `Substring` is a part).
//    ///
//    public func tokenise<TokenType, StateType>(
//        with tokeniser: Tokeniser<TokenType, StateType>,
//        state startState: StateType
//    ) -> [Tokeniser<TokenType, StateType>.Token] {
//        var state        = startState
//        var currentStart = startIndex
//        var tokens       = [] as [Tokeniser<TokenType, StateType>.Token]
//        
//        // Tokenise and set appropriate attributes
//        while currentStart < endIndex {
//            
//            guard let stateTokeniser = tokeniser.states[state.tag],
//                  let currentSubstring = self[currentStart...] as? Substring,
//                  let result = try? stateTokeniser.regex.firstMatch(in: currentSubstring)
//            else { break }  // no more match => stop
//            
//            logger.log("Hello it's a log: \(currentSubstring)")
//            // We are going to look for the next lexeme from just after the one we just found
//            currentStart = result.range.upperBound
//            
//            // New
//            var tokenAction: TokenAction<TokenType, StateType>?
//            if result[1].range != nil {
//                tokenAction = stateTokeniser.stringTokenTypes[String(self[result.range])]
//            } else {
//                for i in 2..<result.count {
//                    if result[i].range != nil {
//                        if i - 2 < stateTokeniser.patternTokenTypes.count {
//                            tokenAction = stateTokeniser.patternTokenTypes[i - 2]
//                        } else {
//                            let markdownIndex = i - 2 - stateTokeniser.patternTokenTypes.count
//                            tokenAction = stateTokeniser.markdownTokenTypes[markdownIndex]
//                        }
//                        break
//                    }
//                }
//            }
//            
//            if let action = tokenAction, !result.range.isEmpty {
//                
//                tokens.append(.init(type: action.token, range: NSRange(result.range, in: self)))
//                
//                // If there is an associated state transition function, apply it to the tokeniser state
//                if let transition = action.transition { state = transition(state) }
//                
//            }
//        }
//        return tokens
//    }
//}
//
