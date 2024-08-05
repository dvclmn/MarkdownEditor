//
//  MarkdownTextStorage.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 29/7/2024.
//

import SwiftUI


///
/// A subclass of `NSTextStorage`, which is the fundamental storage mechanism of TextKit that contains the text managed by the system.
///
public class MarkdownTextStorage: NSTextStorage {
    
    
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


extension MarkdownTextStorage {
    
    /// Returns the theme colour for a line token.
    ///
    /// - Parameter linetoken: The line token whose colour is desired.
    /// - Returns: The theme colour of the given line token.
    ///
    func colour(for linetoken: LineToken) -> OSColor {
        
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
            
            print("Current line token: \(lineToken.kind.name)")
            
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


// MARK: -
// MARK: Token attributes

extension MarkdownTextStorage {
    
    /// Yield the token at the given position (column index) on the given line, if any.
    ///
    /// - Parameters:
    ///   - line: The line where we are looking for a token.
    ///   - position: The column index of the location of interest (0-based).
    /// - Returns: The token at the given position, if any, and the effective range of the token or token-free space,
    ///     respectively, in the entire text. (The range in the token is its line range, whereas the `effectiveRange`
    ///     is relative to the entire text storage.)
    ///
    func token(on line: Int, at position: Int) -> (token: LanguageConfiguration.Tokeniser.Token?, effectiveRange: NSRange)? {
        guard let lineMap  = (delegate as? MarkdownTextStorageDelegate)?.lineMap,
              let lineInfo = lineMap.lookup(line: line),
              let tokens   = lineInfo.info?.tokens
        else { return nil }
        
        // FIXME: This is fairly naive, especially for very long lines...
        var previousToken: LanguageConfiguration.Tokeniser.Token? = nil
        for token in tokens {
            
            if position < token.range.location {
                
                // `token` is already after `column`
                let afterPreviousTokenOrLineStart = previousToken?.range.max ?? 0
                return (token: nil, effectiveRange: NSRange(
                    location: lineInfo.range.location + afterPreviousTokenOrLineStart,
                    length: token.range.location - afterPreviousTokenOrLineStart
                ))
                
            } else if token.range.contains(position),
                      let effectiveRange = token.range.shifted(by: lineInfo.range.location)
            {
                // `token` includes `column`
                return (token: token, effectiveRange: effectiveRange)
            }
            previousToken = token
        }
        
        // `column` is after any tokens (if any) on this line
        let afterPreviousTokenOrLineStart = previousToken?.range.max ?? 0
        return (token: nil, effectiveRange: NSRange(location: lineInfo.range.location + afterPreviousTokenOrLineStart,
                                                    length: lineInfo.range.length - afterPreviousTokenOrLineStart))
    }
    
    /// Yield the token at the given storage index.
    ///
    /// - Parameter location: Character index into the text storage.
    /// - Returns: The token at the given position, if any, and the effective range of the token or token-free space,
    ///     respectively, in the entire text. (The range in the token is its line range, whereas the `effectiveRange`
    ///     is relative to the entire text storage.)
    ///
    /// NB: Token spans never exceed a line.
    ///
    func token(at location: Int) -> (token: LanguageConfiguration.Tokeniser.Token?, effectiveRange: NSRange) {
        if let lineMap  = (delegate as? MarkdownTextStorageDelegate)?.lineMap,
           let line     = lineMap.lineContaining(index: location),
           let lineInfo = lineMap.lookup(line: line),
           let result   = token(on: line, at: location - lineInfo.range.location)
        {
            return result
        }
        else { return (token: nil, effectiveRange: NSRange(location: location, length: 1)) }
    }
    
    /// Convenience wrapper for `token(at:)` that returns only tokens, but with a range in terms of the entire text
    /// storage (not line-local).
    ///
    func tokenOnly(at location: Int) -> LanguageConfiguration.Tokeniser.Token? {
        let tokenWithEffectiveRange = token(at: location)
        var token = tokenWithEffectiveRange.token
        token?.range = tokenWithEffectiveRange.effectiveRange
        return token
    }
    
    /// Determine whether the given location is inside a comment and, if so, return the range of the comment (clamped to
    /// the current line).
    ///
    /// - Parameter location: Character index into the text storage.
    /// - Returns: If `location` is inside a comment, return the range of the comment, clamped to line bounds, but in
    ///     terms of teh entire text.
    ///
    func comment(at location: Int) -> NSRange? {
        guard let lineMap       = (delegate as? MarkdownTextStorageDelegate)?.lineMap,
              let line          = lineMap.lineContaining(index: location),
              let lineInfo      = lineMap.lookup(line: line),
              let commentRanges = lineInfo.info?.commentRanges
        else { return nil }
        
        let column = location - lineInfo.range.location
        for commentRange in commentRanges {
            if column < commentRange.location { return nil }
            else if commentRange.contains(column) { return commentRange.shifted(by: lineInfo.range.location) }
        }
        return nil
    }
    
    /// Token representation for token enumeration, which includes simple tokens and comment spans.
    ///
    /// NB: In this representation tokens and comments never extend across lines.
    ///
    struct LineToken {
        
        enum Kind {
            case comment
            case token(LanguageConfiguration.Token)
            
            var name: String {
                switch self {
                case .comment:
                    "Comment"
                case .token(let token):
                    "Token: \(token.name)"
                }
            }
        }
        
        /// Token range, relative to the start of the document.
        ///
        let range: NSRange
        
        /// Token start position, relative to the line on which the token is located.
        ///
        let column: Int
        
        /// The kind of token.
        ///
        let kind: Kind
        
        /// Whether the line token represents a comment.
        ///
        var isComment: Bool {
            switch kind {
            case .comment: true
            default:       false
            }
        }
    }
    
    /// Enumerate tokens and comment spans from the given location onwards.
    ///
    /// - Parameters:
    ///   - location: The location where the enumeration starts.
    ///   - block: A block invoked for every token that also determines if the enumeration finishes early.
    ///
    /// The first enumerated token may have a starting location smaller than `location` (but it will extent until at least
    /// `location`). Enumeration proceeds until the end of the document or until `block` returns `false`.
    ///
    func enumerateTokens(from location: Int, using block: (LineToken) -> Bool) {
        
        // Enumerate the comment ranges and tokens on one line and optionally skip everything before a given start
        // location. We can have tokens inside comment ranges. These tokens are being skipped. (We don't highlight inside
        // comments, so far.) If a token and a comment begin at the same location, the comment takes precedence.
        func enumerate(
            tokens: [LanguageConfiguration.Tokeniser.Token],
            commentRanges: [NSRange],
            lineStart: Int,
            startLocation: Int?
        ) -> Bool {
            
            var skipUntil: Int? = startLocation  // tokens from this location onwards (even in part) are enumerated
            
            var tokens = tokens
            var commentRanges = commentRanges
            
            while !tokens.isEmpty || !commentRanges.isEmpty {
                
                let token = tokens.first
                let commentRange = commentRanges.first
                
                print("Will I see this")
                
                if let token, (commentRange?.location ?? Int.max) > token.range.location {
                    
                    if skipUntil ?? 0 <= token.range.max - 1,
                       let range = token.range.shifted(by: lineStart)
                    {
                        let doContinue = block(LineToken(range: range, column: token.range.location, kind: .token(token.type)))
                        if !doContinue { return false }
                    }
                    tokens.removeFirst()
                    
                } else if let commentRange {
                    
                    if skipUntil ?? 0 <= commentRange.max - 1,
                       let range = commentRange.shifted(by: lineStart)
                    {
                        let doContinue = block(LineToken(range: range, column: commentRange.location, kind: .comment))
                        if !doContinue { return false }
                        skipUntil = commentRange.max      // skip tokens within the comment range
                    }
                    commentRanges.removeFirst()
                }
                
            } // END check tokens or comments aren't empty
            
            return true
        }
        
        guard let lineMap   = (delegate as? MarkdownTextStorageDelegate)?.lineMap,
              let startLine = lineMap.lineContaining(index: location)
        else { return }
        
        let firstLine = lineMap.lines[startLine]
        if let info = firstLine.info {
            
            let doContinue = enumerate(
                tokens: info.tokens,
                commentRanges: info.commentRanges,
                lineStart: firstLine.range.location,
                startLocation: location - firstLine.range.location
            )
            
            if !doContinue { return }
            
        }
        
        for line in lineMap.lines[startLine + 1 ..< lineMap.lines.count] {
            
            if let info = line.info {
                
                let doContinue = enumerate(tokens: info.tokens,
                                           commentRanges: info.commentRanges,
                                           lineStart: line.range.location,
                                           startLocation: nil)
                if !doContinue { return }
                
            }
        }
    }
    
    /// Enumerate tokens and comment spans in the given range.
    ///
    /// - Parameters:
    ///   - range: The range whose tokens are being enumerated. The first and last token may extend left and right
    ///       outside the given range.
    ///   - block: A block invoked foro every range.
    ///
    func enumerateTokens(in range: NSRange, using block: (LineToken) -> Void) {
        
        enumerateTokens(from: range.location) { token in
            print("Token: \(token.kind.name)")
            block(token)
            return token.range.max < range.max
        }
    }
    
    /// Return all tokens in the given range.
    ///
    /// - Parameter range: The range whose tokens are returned.
    /// - Returns: An array containing the tokens in the range, where first and last token may extend left and right
    ///     outside the given range.
    ///
    func tokens(in range: NSRange) -> [LineToken] {
        var tokens: [LineToken] = []
        enumerateTokens(in: range) { tokens.append($0) }
        return tokens
    }
    
    /// If the given location is just past a bracket, return its matching bracket's token range if it exists and the
    /// matching bracket is within the given range of lines.
    ///
    /// - Parameters:
    ///   - location: Location just past (i.e., to the right of) the original bracket (maybe opening or closing).
    ///   - lines: Range of lines to consider for the matching bracket.
    /// - Returns: Character range of the lexeme of the matching bracket if it exists in the given line range `lines`.
    ///
    func matchingBracket(at location: Int, in lines: Range<Int>) -> NSRange? {
        guard let markdownTextStorageDelegate = delegate as? MarkdownTextStorageDelegate,
              let lineAndPosition     = markdownTextStorageDelegate.lineMap.lineAndPositionOf(index: location),
              lineAndPosition.position > 0,                 // we can't be *past* a bracket on the rightmost column
              let token               = token(on: lineAndPosition.line, at: lineAndPosition.position - 1)?.token,
              token.range.max == lineAndPosition.position,  // we need to be past the bracket, even if it is multi-character
              token.type.isOpenBracket || token.type.isCloseBracket
        else { return nil }
        
        let matchingBracketTokenType = token.type.matchingBracket,
            searchForwards           = token.type.isOpenBracket,
            allTokens                = markdownTextStorageDelegate.lineMap.lookup(line: lineAndPosition.line)?.info?.tokens ?? []
        
        var currentLine = lineAndPosition.line
        var tokens      = searchForwards ? Array(allTokens.drop(while: { $0.range.location <= lineAndPosition.position }))
        : Array(allTokens.prefix(while: { $0.range.max < lineAndPosition.position }).reversed())
        var level       = 1
        
        while lines.contains(currentLine) {
            
            for currentToken in tokens {
                
                if currentToken.type == token.type { level += 1 }         // nesting just got deeper
                else if currentToken.type == matchingBracketTokenType {    // matching bracket found
                    
                    if level > 1 { level -= 1 }     // but we are not yet at the topmost nesting level
                    else {                          // this is the one actually matching the original bracket
                        
                        if let lineStart = markdownTextStorageDelegate.lineMap.lookup(line: currentLine)?.range.location {
                            return currentToken.range.shifted(by: lineStart)
                        } else { return nil }
                        
                    }
                }
            }
            
            // Get the tokens on the next (forwards or backwards) line and reverse them if we search backwards.
            currentLine += searchForwards ? 1 : -1
            tokens = markdownTextStorageDelegate.lineMap.lookup(line: currentLine)?.info?.tokens ?? []
            if !searchForwards { tokens = tokens.reversed() }
            
        }
        return nil
    }
}





