//
//  MDTextStorage.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 29/7/2024.
//

import SwiftUI


extension MDTextStorage {

   
    func token(at location: Int) -> (token: LineToken?, effectiveRange: NSRange) {
        guard let lineMap = (delegate as? MDTextStorageDelegate)?.lineMap,
              let line = lineMap.lineContaining(index: location),
              let lineInfo = lineMap.lookup(line: line) else {
            return (token: nil, effectiveRange: NSRange(location: location, length: 1))
        }

        let column = location - lineInfo.range.location
        for token in lineInfo.tokens where token.range.contains(column) {
            return (token: token, effectiveRange: token.range.shifted(by: lineInfo.range.location) ?? NSRange(location: location, length: 1))
        }

        // If no token found, return plain text token
        let remainingRange = NSRange(location: location, length: lineInfo.range.max - location)
        return (token: LineToken(range: remainingRange, column: column, type: .plainText), effectiveRange: remainingRange)
    }

    func enumerateTokens(from location: Int, using block: (LineToken) -> Bool) {
        guard let lineMap = (delegate as? MDTextStorageDelegate)?.lineMap,
              let startLine = lineMap.lineContaining(index: location) else { return }

        for lineIndex in startLine..<lineMap.lines.count {
            guard let line = lineMap.lookup(line: lineIndex) else { continue }
            
            for token in line.tokens {
                let globalRange = token.range.shifted(by: line.range.location) ?? token.range
                if globalRange.max > location {
                    let shouldContinue = block(token)
                    if !shouldContinue { return }
                }
            }
        }
    }

    func tokens(in range: NSRange) -> [LineToken] {
        var tokens: [LineToken] = []
        enumerateTokens(from: range.location) { token in
            if token.range.intersection(range) != nil {
                tokens.append(token)
            }
            return token.range.max < range.max
        }
        return tokens
    }

    func matchingMarkdownElement(at location: Int) -> NSRange? {
        guard let token = self.token(at: location).token else { return nil }

        switch token.type {
        case .header, .codeBlock, .blockQuote:
            // For block elements, return the entire line range
            return (delegate as? MDTextStorageDelegate)?.lineMap.lookup(line: location)?.range
        case .bold, .italic, .link, .inlineCode:
            // For inline elements, find the matching closing marker
            return findMatchingInlineElement(for: token)
        default:
            return nil
        }
    }

    private func findMatchingInlineElement(for token: LineToken) -> NSRange? {
        // Implement logic to find matching inline elements (e.g., closing ** for bold)
        // This would depend on the specific Markdown rules you're implementing
        // Return the range of the entire element if found
        return nil
    }
}


///
/// A subclass of `NSTextStorage`, which is the fundamental storage mechanism of TextKit that contains the text managed by the system.
///
public class MDTextStorage: NSTextStorage {
    
    
    fileprivate let textStorage: NSTextStorage = NSTextStorage()
    
    public override var string: String { textStorage.string }
    
    
    public override var fixesAttributesLazily: Bool { true }
    
    
    
    
 
    public override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        return textStorage.attributes(at: location, effectiveRange: range)
    }
    
    public override func replaceCharacters(in range: NSRange, with str: String) {
        
        beginEditing()
        
        // Check if we're deleting a single character
        guard range.length == 1 && str.isEmpty else {
            performRegularReplacement(range: range, with: str)
            endEditing()
            return
        }
        
        guard let deletedToken = token(at: range.location).token else {
            performRegularReplacement(range: range, with: str)
            endEditing()
            return
        }
        
        let isOpenBracket = deletedToken.type.isOpenBracket
        let isWithinTextBounds = range.location + 1 < length
        
        let isSingleCharBracket = true
//        let isSingleCharBracket = language.lexeme(of: deletedToken.type)?.count == 1
        
        let nextTokenIsMatchingBracket = token(at: range.location + 1).token?.type == deletedToken.type.matchingBracket
        
        guard isOpenBracket && isWithinTextBounds && isSingleCharBracket && nextTokenIsMatchingBracket else {
            performRegularReplacement(range: range, with: str)
            endEditing()
            return
        }
        
        // Delete both the opening and closing brackets
        let extendedRange = NSRange(location: range.location, length: 2)
        textStorage.replaceCharacters(in: extendedRange, with: "")
        edited(.editedCharacters, range: extendedRange, changeInLength: -2)
        
        endEditing()
    }
    
    private func performRegularReplacement(range: NSRange, with str: String) {
        textStorage.replaceCharacters(in: range, with: str)
        edited(.editedCharacters, range: range, changeInLength: (str as NSString).length - range.length)
    }
    
    public override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        beginEditing()
        textStorage.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
}


extension MDTextStorage {
    
    /// Returns the theme colour for a line token.
    ///
    /// - Parameter linetoken: The line token whose colour is desired.
    /// - Returns: The theme colour of the given line token.
    ///
    func colour(for linetoken: LineToken) -> NSColor {
        
        return .blue
//        switch linetoken.kind {
//        case .comment: theme.commentColour
//        case .token(let token):
//            switch token {
//            case .string:     theme.stringColour
//            case .character:  theme.characterColour
//            case .number:     theme.numberColour
//            case .identifier(let flavour):
//                switch flavour {
//                case .type:     theme.typeColour
//                case .property: theme.fieldColour
//                case .enumCase: theme.caseColour
//                default:        theme.identifierColour
//                }
//            case .operator(let flavour):
//                switch flavour {
//                case .type:     theme.typeColour
//                case .property: theme.fieldColour
//                case .enumCase: theme.caseColour
//                default:        theme.operatorColour
//                }
//            case .keyword:    theme.keywordColour
//            case .symbol:     theme.symbolColour
//            default:
//                theme.textColour
//            }
//        }
    }
    
//    func backgroundColour(for linetoken: LineToken) -> OSColor {
//        switch linetoken.kind {
//        case .comment: theme.commentColour
//        case .token(let token):
//            switch token {
//            case .string:     theme.stringColour
//            case .character:  theme.characterColour
//            case .number:     theme.numberColour
//            case .identifier(let flavour):
//                switch flavour {
//                case .type:     theme.typeColour
//                case .property: theme.fieldColour
//                case .enumCase: theme.caseColour
//                default:        theme.identifierColour
//                }
//            case .operator(let flavour):
//                switch flavour {
//                case .type:     theme.typeColour
//                case .property: theme.fieldColour
//                case .enumCase: theme.caseColour
//                default:        theme.operatorColour
//                }
//            case .keyword:    theme.keywordColour
//            case .symbol:     theme.symbolColour
//                //            default:          theme.textColour
//            case .roundBracketOpen:
//                OSColor.clear
//            case .roundBracketClose:
//                OSColor.clear
//            case .squareBracketOpen:
//                OSColor.clear
//            case .squareBracketClose:
//                OSColor.clear
//            case .curlyBracketOpen:
//                OSColor.clear
//            case .curlyBracketClose:
//                OSColor.clear
//            case .singleLineComment:
//                OSColor.clear
//            case .nestedCommentOpen:
//                OSColor.clear
//            case .nestedCommentClose:
//                OSColor.clear
//            case .regexp:
//                OSColor.clear
//            case .markdown(let syntax):
//                switch syntax {
//                case .bold:
//                    OSColor.clear
//                case .italic:
//                    OSColor.clear
//                case .inlineCode:
//                    OSColor.blue
//                case .codeBlock:
//                    OSColor.clear
//                }
//            }
//        }
//    }
    
    // FIXME: We might want to change the interface here to set attributes per line. This will also make token enumeration simpler.
    /// Set rendering attributes to implement token-based highlighting,
    ///
    /// - Parameters:
    ///   - range: The text range for which renderring attributes ought to be set.
    ///   - layoutManager: The layout manager on which the rendering attributes need to be set.
    ///
    ///   NB: The `range` shouldn't be to large as this is a fairly expensive operation. The text system has a bias
    ///       towards performing the setting of attributes on a line by line bases (or rather a text layout fragment per
    ///       text layout fragment basis).
    ///
    func setHighlightingAttributes(for range: NSRange, in layoutManager: NSTextLayoutManager)
    {
        guard let contentStorage = layoutManager.textContentManager as? NSTextContentStorage
        else { return }
        
        if let textRange = contentStorage.textRange(for: range) {
            layoutManager.setRenderingAttributes(
                [
                    .foregroundColor: NSColor.red,
                    //                    .backgroundColor: OSColor.red
                ], for: textRange
            )
            
            
            
        } // if let textRange = contentStorage...
        
        enumerateTokens(in: range) { lineToken in
            
//            print("Current line token: \(lineToken.kind.name)")
            
            if let documentRange = lineToken.range.intersection(range),
               let textRange = contentStorage.textRange(for: documentRange)
            {
                let colour = colour(for: lineToken)
//                let backgroundColour = backgroundColour(for: lineToken)
                
                layoutManager.setRenderingAttributes([
                    .foregroundColor: colour,
//                    .backgroundColor: backgroundColour
                ], for: textRange)
                
                
            }
        }
    }
}
