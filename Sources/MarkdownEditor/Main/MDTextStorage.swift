//
//  MDTextStorage.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 29/7/2024.
//

import SwiftUI


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
    
    public override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        beginEditing()
        textStorage.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
    private func performRegularReplacement(range: NSRange, with str: String) {
        textStorage.replaceCharacters(in: range, with: str)
        edited(.editedCharacters, range: range, changeInLength: (str as NSString).length - range.length)
    }
}


extension NSAttributedString.Key {
    
    /// Attribute to indicate that an attribute run has the default styling and not a token-specific styling.
    ///
    static let hideInvisibles: NSAttributedString.Key = .init("hideInvisibles")
}

extension MDTextStorage {
    
    /// Returns the theme colour for a line token.
    ///
    /// - Parameter linetoken: The line token whose colour is desired.
    /// - Returns: The theme colour of the given line token.
    ///
    func colour(for linetoken: LineToken) -> NSColor {
        switch linetoken.type {
            case .body:
                NSColor.textColor
            case .inlineCode:
                NSColor.red
            default:
                NSColor.purple
        }
    }
    
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
            layoutManager.setRenderingAttributes([.foregroundColor: NSColor.systemPink, .hideInvisibles: ()],
                                                 for: textRange)
        }
        enumerateTokens(in: range) { lineToken in
            
            if let documentRange = lineToken.range.intersection(range),
               let textRange     = contentStorage.textRange(for: documentRange)
            {
                let colour = colour(for: lineToken)
                layoutManager.setRenderingAttributes([.foregroundColor: colour], for: textRange)
            }
        }
    }
}


// MARK: -
// MARK: Token attributes

extension MDTextStorage {
    
    /// Yield the token at the given position (column index) on the given line, if any.
    ///
    /// - Parameters:
    ///   - line: The line where we are looking for a token.
    ///   - position: The column index of the location of interest (0-based).
    /// - Returns: The token at the given position, if any, and the effective range of the token or token-free space,
    ///     respectively, in the entire text. (The range in the token is its line range, whereas the `effectiveRange`
    ///     is relative to the entire text storage.)
    ///
    func token(
        on line: Int,
        at position: Int
    ) -> (token: Tokeniser.Token?, effectiveRange: NSRange)? {
        guard let lineMap  = (delegate as? MDTextStorageDelegate)?.lineMap,
              let lineInfo = lineMap.lookup(line: line),
              let tokens   = lineInfo.info?.tokens
        else { return nil }
        
        // FIXME: This is fairly naive, especially for very long lines...
        var previousToken: Tokeniser.Token? = nil
        for token in tokens {
            
            if position < token.range.location {
                
                // `token` is already after `column`
                let afterPreviousTokenOrLineStart = previousToken?.range.max ?? 0
                return (token: nil, effectiveRange: NSRange(location: lineInfo.range.location + afterPreviousTokenOrLineStart,
                                                            length: token.range.location - afterPreviousTokenOrLineStart))
                
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
    func token(at location: Int) -> (token: Tokeniser.Token?, effectiveRange: NSRange) {
        if let lineMap  = (delegate as? MDTextStorageDelegate)?.lineMap,
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
    func tokenOnly(at location: Int) -> Tokeniser.Token? {
        let tokenWithEffectiveRange = token(at: location)
        var token = tokenWithEffectiveRange.token
        token?.range = tokenWithEffectiveRange.effectiveRange
        return token
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
        
        // Enumerate the comemnt ranges and tokens on one line and optionally skip everything before a given start
        // location. We can have tokens inside comment ranges. These tokens are being skipped. (We don't highlight inside
        // comments, so far.) If a token and a comment begin at the same location, the comment takes precedence.
        func enumerate(tokens: [Tokeniser.Token],
                       lineStart: Int,
                       startLocation: Int?)
        -> Bool
        {
            var skipUntil: Int? = startLocation  // tokens from this location onwards (even in part) are enumerated
            
            var tokens        = tokens
            while !tokens.isEmpty {
                
                if let token = tokens.first {
                    
                    if skipUntil ?? 0 <= token.range.max - 1,
                       let range = token.range.shifted(by: lineStart)
                    {
                        let doContinue = block(LineToken(range: range, column: token.range.location, type: token.type))
                        if !doContinue { return false }
                    }
                    tokens.removeFirst()
                    
                }
            }
            return true
        }
        
        guard let lineMap   = (delegate as? MDTextStorageDelegate)?.lineMap,
              let startLine = lineMap.lineContaining(index: location)
        else { return }
        
        let firstLine = lineMap.lines[startLine]
        if let info = firstLine.info {
            
            let doContinue = enumerate(tokens: info.tokens,
                                       lineStart: firstLine.range.location,
                                       startLocation: location - firstLine.range.location)
            if !doContinue { return }
            
        }
        
        for line in lineMap.lines[startLine + 1 ..< lineMap.lines.count] {
            
            if let info = line.info {
                
                let doContinue = enumerate(tokens: info.tokens,
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
}
