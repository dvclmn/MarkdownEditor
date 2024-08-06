
//
//  SwiftConfiguration.swift
//
//
//  Created by Manuel M T Chakravarty on 10/01/2023.
//

import Foundation
import RegexBuilder


//extension LanguageConfiguration {
    
    
    
//    public struct MarkdownOptions {
//        public var headingRegex: Regex<Substring>? = nil
//        public var listRegex: Regex<Substring>? = nil
//        public var blockquoteRegex: Regex<Substring>? = nil
//        public var horizontalRuleRegex: Regex<Substring>? = nil
//        public var linkRegex: Regex<Substring>? = nil
//        public var imageRegex: Regex<Substring>? = nil
//        public var emphasisRegex: Regex<Substring>? = nil
//        public var strongEmphasisRegex: Regex<Substring>? = nil
//        public var codeBlockRegex: Regex<Substring>? = nil
//        public var inlineCodeRegex: Regex<Substring>? = nil
//        
//        public var supportsInlineHTML: Bool = false
//        public var supportsTableSyntax: Bool = false
//        public var supportsTaskLists: Bool = false
//        
//        public var emphasisPairs: [BracketPair] = []  // For *, _, **, __, etc.
//        public var linkPairs: BracketPair? = nil        // For [](url)
//        public var imagePairs: BracketPair? = nil       // For ![](url)
//    }
//}

//
//private let markdownReservedIdentifiers = [
//    "# ", "## ", "### ", "#### ", "##### ", "###### ", // Headers
//    "- ", "* ", "+ ",                                  // Unordered list markers
//    "1. ", "2. ", "3. ",                               // Ordered list markers (example)
//    "> ",                                              // Blockquote
//    "```", "~~~",                                      // Code block delimiters
//    "---", "***", "___"                                // Horizontal rules
//]

//private let markdownReservedOperators = [
//    "*", "_", "**", "__", "~~",                        // Emphasis and strikethrough
//    "`", "![", "]", "[", "](",                         // Inline code and links
//    "<", ">",                                          // HTML tags
//    "|",                                               // Table separator
//    "\\",                                              // Escape character
//]
//
//
//extension LanguageConfiguration {
//    
//    /// Language configuration for Markdown
//    ///
//    public static func markdown() -> LanguageConfiguration {
////        let headingRegex = Regex {
////            OneOrMore("#")
////            " "
////            ZeroOrMore(.any)
////        }
////        
////        let listRegex = Regex {
////                    ChoiceOf {
////                        Regex { ChoiceOf { "*"; "-"; "+" }; " " }
////                        Regex { OneOrMore(.digit); "."; " " }
////                    }
////                }
////        
////        let linkRegex = Regex {
////            "["
////            ZeroOrMore(.any)
////            "]("
////            ZeroOrMore(.any)
////            ")"
////        }
////        
//        let emphasisRegex = Regex {
//            ChoiceOf {
//                Regex { "**"; ZeroOrMore(.any); "**" }
//                Regex { "__"; ZeroOrMore(.any); "__" }
//                Regex { "*"; ZeroOrMore(.any); "*" }
//                Regex { "_"; ZeroOrMore(.any); "_" }
//            }
//        }
////        
////        let inlineCode = Regex {
////            Regex { "`"; ZeroOrMore(.any); "`" }
////        }
////        
////        let codeBlockRegex = Regex {
////            ChoiceOf {
////                Regex { "```"; ZeroOrMore(.any); "```" }
////                Regex { "~~~"; ZeroOrMore(.any); "~~~" }
////            }
////        }
//
//        return LanguageConfiguration(
//            name: "Markdown",
//            supportsSquareBrackets: true,
//            supportsCurlyBrackets: false
////            stringRegex: emphasisRegex
////            characterRegex: nil,
////            numberRegex: nil,  // Markdown doesn't have special number formatting
////            singleLineComment: nil,  // Markdown doesn't have traditional comments
////            nestedComment: nil,
////            identifierRegex: Regex { OneOrMore(.word) },
////            operatorRegex: Regex { "*"; "_"; "~"; "`"; "["; "]"; "("; ")"; "<"; ">"; "|"; "\\" }
////            reservedIdentifiers: markdownReservedIdentifiers,
////            reservedOperators: markdownReservedOperators
//        )
//    }
//}
