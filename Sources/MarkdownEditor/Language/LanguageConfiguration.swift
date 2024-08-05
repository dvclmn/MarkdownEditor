////
////  LanguageConfiguration.swift
////
////
////  Created by Manuel M T Chakravarty on 03/11/2020.
////
////  Language configurations determine the linguistic characteristics that are important for the editing and display of
////  code in the respective languages, such as comment syntax, bracketing syntax, and syntax highlighting
////  characteristics.
////
////  We adopt a two-stage approach to syntax highlighting. In the first stage, basic context-free syntactic constructs
////  are being highlighted. In the second stage, contextual highlighting is performed on top of the highlighting from
////  stage one. The second stage relies on information from a code analysis subsystem, such as SourceKit.
////
////  Curent support here is only for the first stage.
//
//import RegexBuilder
//import os
//
//import SwiftUI
//
///// Specifies the language-dependent aspects of a code editor.
/////
//public struct LanguageConfiguration: Sendable {
//    
//    
//    
//    /// Supported kinds of tokens.
//    ///
//    public enum Token: Equatable {
//        case roundBracketOpen
//        case roundBracketClose
//        case squareBracketOpen
//        case squareBracketClose
//        case curlyBracketOpen
//        case curlyBracketClose
//        //        case string
//        //        case character
//        //        case number
//        //        case identifier
//        //        case `operator`
//        //        case keyword
//        //        case symbol
//        //        case regexp
//        
//        public var name: String {
//            let mirror = Mirror(reflecting: self)
//            return mirror.children.first?.label ?? String(describing: self)
//        }
//        
//        public var isOpenBracket: Bool {
//            switch self {
//                case .roundBracketOpen, .squareBracketOpen, .curlyBracketOpen:
//                    return true
//                default:
//                    return false
//            }
//        }
//        
//        public var isCloseBracket: Bool {
//            switch self {
//                case .roundBracketClose, .squareBracketClose, .curlyBracketClose:
//                    return true
//                default:                                                                               
//                    return false
//            }
//        }
//        
//        public var matchingBracket: Token? {
//            switch self {
//                case .roundBracketOpen:   return .roundBracketClose
//                case .squareBracketOpen:  return .squareBracketClose
//                case .curlyBracketOpen:   return .curlyBracketClose
//                case .roundBracketClose:  return .roundBracketOpen
//                case .squareBracketClose: return .squareBracketOpen
//                case .curlyBracketClose:  return .curlyBracketOpen
//                default:                  return nil
//            }
//        }
//        
//    }
//    
//    /// Yields the lexeme of the given token under this language configuration if the token has got a unique lexeme.
//    ///
//    public func lexeme(of token: Token) -> String? {
//        switch token {
//            case .roundBracketOpen:     return "("
//            case .roundBracketClose:    return ")"
//            case .squareBracketOpen:    return "["
//            case .squareBracketClose:   return "]"
//            case .curlyBracketOpen:     return "{"
//            case .curlyBracketClose:    return "}"
//        }
//    }
//}
//
//@MainActor
//extension LanguageConfiguration {
//    
//    // General purpose numeric literals
//    public static let binaryLit: Regex<Substring>   = /(?:[01]_*)+/
//    public static let octalLit: Regex<Substring>    = /(?:[0-7]_*)+/
//    public static let decimalLit: Regex<Substring>  = /(?:[0-9]_*)+/
//    public static let hexalLit: Regex<Substring>    = /(?:[0-9A-Fa-f]_*)+/
//    public static let optNegation: Regex<Substring> = /(?:\B-|\b)/
//    
//    public static let exponentLit = Regex {
//        /[eE](?:[+-])?/
//        decimalLit
//    }
//
//    public static let hexponentLit: Regex<Substring> = Regex {
//        /[pP](?:[+-])?/
//        decimalLit
//    }
//    
//}
//
//
///// Tokeniser generated on the basis of a language configuration.
/////
//typealias LanguageConfigurationTokenDictionary = TokenDictionary<LanguageConfiguration.Token, LanguageConfiguration.State>
//
///// Tokeniser generated on the basis of a language configuration.
/////
//public typealias LanguageConfigurationTokeniser = Tokeniser<LanguageConfiguration.Token, LanguageConfiguration.State>
//
//extension LanguageConfiguration {
//    
//    /// Tokeniser generated on the basis of a language configuration.
//    ///
//    public typealias Tokeniser = LanguageSupport.Tokeniser<LanguageConfiguration.Token, LanguageConfiguration.State>
//    
//    /// Token dictionary generated on the basis of a language configuration.
//    ///
//    public typealias TokenDictionary = LanguageSupport.TokenDictionary<LanguageConfiguration.Token, LanguageConfiguration.State>
//    
//    /// Token action generated on the basis of a language configuration.
//    ///
//    public typealias TokenAction = LanguageSupport.TokenAction <LanguageConfiguration.Token, LanguageConfiguration.State>
//    
//    func token(
//        _ token: LanguageConfiguration.Token
//    ) -> (token: LanguageConfiguration.Token, transition: ((LanguageConfiguration.State) -> LanguageConfiguration.State)?)
//    {
//        return (token: token, transition: nil)
//    }
//    
//    func incNestedComment(state: LanguageConfiguration.State) -> LanguageConfiguration.State {
//        switch state {
//            case .tokenisingCode:           return .tokenisingComment(1)
//            case .tokenisingComment(let n): return .tokenisingComment(n + 1)
//        }
//    }
//    
//    func decNestedComment(state: LanguageConfiguration.State) -> LanguageConfiguration.State {
//        switch state {
//            case .tokenisingCode:          return .tokenisingCode
//            case .tokenisingComment(let n)
//                where n > 1:             return .tokenisingComment(n - 1)
//            case .tokenisingComment(_):    return .tokenisingCode
//        }
//    }
//
//    public var tokenDictionary: TokenDictionary {
//        
//        
//        var markdownTokens = [
//            
//            TokenDescription(regex: /\(/, singleLexeme: "(", action: token(.roundBracketOpen)),
//            TokenDescription(regex: /\)/, singleLexeme: ")", action: token(.roundBracketClose))
//            
//        ]
//        
//        // Populate the token dictionary for the code state (tokenising plain code)
//        //
//        var codeTokens = [
//            TokenDescription(regex: /\(/, singleLexeme: "(", action: token(.roundBracketOpen)),
//            TokenDescription(regex: /\)/, singleLexeme: ")", action: token(.roundBracketClose))
//        ]
//        
//        
//        
//        if supportsSquareBrackets {
//            codeTokens.append(contentsOf: [
//                TokenDescription(regex: /\[/, singleLexeme: "[", action: token(.squareBracketOpen)),
//                TokenDescription(regex: /\]/, singleLexeme: "]", action: token(.squareBracketClose))
//            ])
//        }
//        if supportsCurlyBrackets {
//            codeTokens.append(contentsOf: [
//                TokenDescription(regex: /{/, singleLexeme: "{", action: token(.curlyBracketOpen)),
//                TokenDescription(regex: /}/, singleLexeme: "}", action: token(.squareBracketClose))
//            ])
//        }
//        
//        
//        if let regex = stringRegex { codeTokens.append(TokenDescription(regex: regex, action: token(.string))) }
//        if let regex = characterRegex { codeTokens.append(TokenDescription(regex: regex, action: token(.character))) }
//        if let regex = numberRegex { codeTokens.append(TokenDescription(regex: regex, action: token(.number))) }
//        
//        
//        if let lexeme = singleLineComment {
//            codeTokens.append(TokenDescription(regex: Regex{ lexeme },
//                                               singleLexeme: lexeme,
//                                               action: token(Token.singleLineComment))
//            )
//        }
//        if let lexemes = nestedComment {
//            codeTokens.append(TokenDescription(regex: Regex{ lexemes.open },
//                                               singleLexeme: lexemes.open,
//                                               action: (token: .nestedCommentOpen, transition: incNestedComment)))
//            codeTokens.append(TokenDescription(regex: Regex{ lexemes.close },
//                                               singleLexeme: lexemes.close,
//                                               action: (token: .nestedCommentClose, transition: decNestedComment)))
//        }
//        
//        if let regex = identifierRegex { codeTokens.append(TokenDescription(regex: regex, action: token(.identifier(nil)))) }
//        if let regex = operatorRegex { codeTokens.append(TokenDescription(regex: regex, action: token(.operator(nil)))) }
//        
//        for reserved in reservedIdentifiers {
//            codeTokens.append(TokenDescription(regex: Regex{ Anchor.wordBoundary; reserved; Anchor.wordBoundary },
//                                               singleLexeme: reserved,
//                                               action: token(.keyword)))
//        }
//        
//        for markdownSyntax in self.markdownSyntax {
//            
//            markdownTokens.append(TokenDescription(
//                regex: markdownSyntax.regex,
//                action: token(.markdown(markdownSyntax))
//            ))
//        }
//        
//        for reserved in reservedOperators {
//            codeTokens.append(TokenDescription(regex: Regex{ Anchor.wordBoundary; reserved; Anchor.wordBoundary },
//                                               singleLexeme: reserved,
//                                               action: token(.symbol)))
//        }
//        
//        // Populate the token dictionary for the comment state (tokenising within a nested comment)
//        
//        let commentTokens: [TokenDescription<LanguageConfiguration.Token, LanguageConfiguration.State>]
//        = if let lexemes = nestedComment {
//            [ TokenDescription(regex: Regex{ lexemes.open },
//                               singleLexeme: lexemes.open,
//                               action: (token: .nestedCommentOpen, transition: incNestedComment))
//              , TokenDescription(regex: Regex{ lexemes.close },
//                                 singleLexeme: lexemes.close,
//                                 action: (token: .nestedCommentClose, transition: decNestedComment))
//            ]
//        } else { [] }
//        
//        // return type: [StateType.StateTag: [TokenDescription<TokenType, StateType>]]
//        return [
//            //            .markdown: markdownTokens,
//            .tokenisingCode: codeTokens,
//            .tokenisingComment: commentTokens
//        ]
//    } // END token dictionary
//} // END extension LanguageConfiguration
