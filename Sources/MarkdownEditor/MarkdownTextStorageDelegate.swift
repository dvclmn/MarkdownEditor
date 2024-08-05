//
//  File.swift
//  
//
//  Created by Dave Coleman on 5/8/2024.
//

import SwiftUI


struct LineInfo {
    /// The tokens extracted from the text on this line.
    ///
    /// NB: The ranges contained in the tokens are relative to the *start of the line* and 0-based.
    ///
//    var tokens: [LanguageConfiguration.Tokeniser.Token]
}


// MARK: -
// MARK: Delegate class

class MarkdownTextStorageDelegate: NSObject, NSTextStorageDelegate {
    

//    private var tokeniser: LanguageConfiguration.Tokeniser?  // cache the tokeniser
    
    /// Hook to propagate changes to the text store upwards in the view hierarchy.
    ///
    let setText: (String) -> Void
    
    private(set) var lineMap = LineMap<LineInfo>(string: "")
    
    /// If the last text change was a one-character addition, which completed a token, then that token is remembered here
    /// together with its range until the next text change.
    ///
//    private var lastTypedToken: LanguageConfiguration.Tokeniser.Token?
    
    /// Indicates whether the current editing round is for a wholesale replacement of the text.
    ///
    private(set) var processingStringReplacement: Bool = false
    
    
    /// Indicates whether the current editing round is for a one-character addition to the text.
    ///
    private(set) var processingOneCharacterAddition: Bool = false
    
    /// Contains the range of characters whose token information was invalidated by the last editing operation.
    ///
    private(set) var tokenInvalidationRange: NSRange? = nil
    
    
    /// Contains the number of lines affected by `tokenInvalidationRange`.
    ///
    private(set) var tokenInvalidationLines: Int? = nil
    
    
    // MARK: Initialisers
    
    init(
        setText: @escaping (String) -> Void
    ) {

//        self.tokeniser = Tokeniser(for: LanguageConfiguration.markdown().tokenDictionary)
//        self.tokeniser = Tokeniser(for: language.tokenDictionary)
        self.setText = setText
        super.init()
    }
    
    
    // MARK: Updates
    
    /// Change the language for a specific range in the code storage.
    ///
    /// - Parameters:
    ///   - language: The new language configuration.
    ///   - codeStorage: The code storage to update.
    ///   - range: The range to apply the new language to.
//    func change(language: LanguageConfiguration, for codeStorage: MarkdownTextStorage, in range: NSRange) async throws {
//        
//        codeBlockManager?.updateCodeBlock(at: range, newLanguage: language)
//        
//        self.tokeniser = Tokeniser(for: language.tokenDictionary)
//        let _ = tokenise(range: NSRange(location: 0, length: codeStorage.length), in: codeStorage)
//    }
    
    
    // MARK: Delegate methods
    
    func textStorage(
        _ textStorage: NSTextStorage,
        willProcessEditing editedMask: NSTextStorageEditActions,
        range editedRange: NSRange,
        changeInLength delta: Int
    ) {
        tokenInvalidationRange = nil
        tokenInvalidationLines = nil
        guard let codeStorage = textStorage as? MarkdownTextStorage else { return }
        
        // If only attributes change, the line map and syntax highlighting remains the same => nothing for us to do
        guard editedMask.contains(.editedCharacters) else { return }
        
        lineMap.updateAfterEditing(string: textStorage.string, range: editedRange, changeInLength: delta)
        var (affectedRange: highlightingRange, lines: highlightingLines) = tokenise(range: editedRange, in: textStorage)
        
        processingStringReplacement = editedRange == NSRange(location: 0, length: textStorage.length)
        
        // If a single character was added, process token-level completion steps (and remember that we are processing a
        // one character addition).
        processingOneCharacterAddition = delta == 1 && editedRange.length == 1
        
        var editedRange = editedRange
        var delta       = delta
        
        // The range within which highlighting has to be re-rendered.
        tokenInvalidationRange = highlightingRange
        tokenInvalidationLines = highlightingLines
        
//        if visualDebugging {
//            textStorage.addAttribute(.backgroundColor, value: visualDebuggingEditedColour, range: editedRange)
//        }
        
        // MARK: [Note Propagating text changes into SwiftUI]
        // We need to trigger the propagation of text changes via the binding passed to the `CodeEditor` view here and *not*
        // in the `NSTextViewDelegate` or `UITextViewDelegate`. The reason for this is the composition of characters with
        // diacritics using muliple key strokes. Until the composition is complete, the already entered composing characters
        // are indicated by marked text and do *not* lead to the signaling of text changes by `NSTextViewDelegate` or
        // `UITextViewDelegate`, although they *do* alter the text storage. However, the methods of `NSTextStorageDelegate`
        // are invoked at each step of the composition process, faithfully representing the state changes of the text
        // storage.
        //
        // Why is this important? Because `CodeEditor.updateNSView(_:context:)` and `CodeEditor.updateUIView(_:context:)`
        // compare the current contents of the text binding with the current contents of the text storage to determine
        // whether the latter needs to be updated. If the text storage changes without propagating the change to the
        // binding, this check inside `CodeEditor.updateNSView(_:context:)` and `CodeEditor.updateUIView(_:context:)` will
        // suggest that the text storage needs to be overwritten by the contents of the binding, incorrectly removing any
        // entered composing characters (i.e., the marked text).
        
        setText(textStorage.string)
        
    }
    
    
}



// MARK: -
// MARK: Tokenisation

extension MarkdownTextStorageDelegate {
    
    /// Tokenise the substring of the given text storage that contains the specified lines and store tokens as part of the
    /// line information.
    ///
    /// - Parameters:
    ///   - originalRange: The character range that contains all characters that have changed.
    ///   - textStorage: The text storage that contains the changed characters.
    /// - Returns: The range of text affected by tokenisation together with the number of lines the range spreads over.
    ///     This can be more than the `originalRange` as changes in commenting and the like might affect large portions of
    ///     text.
    ///
    /// Tokenisation happens at line granularity. Hence, the range is correspondingly extended. Moreover, tokens must not
    /// span across lines as they will always only associated with the line on which they start.
    ///
    
    // MARK: Tokenization
    
    
    func tokenise(range originalRange: NSRange, in textStorage: NSTextStorage) -> (affectedRange: NSRange, lines: Int) {
        
        // NB: The range property of the tokens is in terms of the entire text (not just `line`).
        func tokeniseAndUpdateInfo<Tokens: Collection<Tokeniser<LanguageConfiguration.Token, LanguageConfiguration.State>.Token>> (
            for line: Int,
            tokens: Tokens,
            commentDepth: inout Int,
            lastCommentStart: inout Int?
        ) {
            
            guard let lineRange = lineMap.lookup(line: line)?.range else {
                return
            }
            
//            if visualDebugging {
//                
//                for token in tokens {
//                    textStorage.addAttribute(.underlineColor, value: visualDebuggingTokenColour, range: range)
//                    if token.range.length > 0 {
//                        textStorage.addAttribute(.underlineStyle,
//                                                 value: NSNumber(value: NSUnderlineStyle.double.rawValue),
//                                                 range: NSRange(location: token.range.location, length: 1))
//                    }
//                    if token.range.length > 1 {
//                        textStorage.addAttribute(.underlineStyle,
//                                                 value: NSNumber(value: NSUnderlineStyle.single.rawValue),
//                                                 range: NSRange(location: token.range.location + 1,
//                                                                length: token.range.length - 1))
//                    }
//                }
//            }
            
            let localisedTokens = tokens.map{ $0.shifted(by: -lineRange.location) }
            
            var lineInfo = LineInfo(
                commentDepthStart: commentDepth,
                commentDepthEnd: 0,
                roundBracketDiff: 0,
                squareBracketDiff: 0,
                curlyBracketDiff: 0,
                tokens: localisedTokens,
                commentRanges: []
            )
            
        tokenLoop: for token in localisedTokens {
            
            switch token.type {
                
            case .roundBracketOpen:
                lineInfo.roundBracketDiff += 1
                
            case .roundBracketClose:
                lineInfo.roundBracketDiff -= 1
                
            case .squareBracketOpen:
                lineInfo.squareBracketDiff += 1
                
            case .squareBracketClose:
                lineInfo.squareBracketDiff -= 1
                
            case .curlyBracketOpen:
                lineInfo.curlyBracketDiff += 1
                
            case .curlyBracketClose:
                lineInfo.curlyBracketDiff -= 1
                
            case .singleLineComment:  // set comment attribute from token start token to the end of this line
                let commentStart = token.range.location
                lineInfo.commentRanges.append(NSRange(location: commentStart, length: lineRange.length - commentStart))
                break tokenLoop   // the rest of the tokens are ignored as they are commented out and we'll rescan on change
                
            case .nestedCommentOpen:
                if commentDepth == 0 { lastCommentStart = token.range.location }    // start of an outermost nested comment
                commentDepth += 1
                
            case .nestedCommentClose:
                if commentDepth > 0 {
                    
                    commentDepth -= 1
                    
                    // If we just closed an outermost nested comment, attribute the comment range
                    if let start = lastCommentStart, commentDepth == 0
                    {
                        lineInfo.commentRanges.append(NSRange(location: start, length: token.range.max - start))
                        lastCommentStart = nil
                    }
                }
                
            default:
                break
            }
        }  // END token loop
            
            // If the line ends while we are still in an open comment, we need a comment attribute up to the end of the line
            if let start = lastCommentStart, commentDepth > 0 {
                
                lineInfo.commentRanges.append(NSRange(location: start, length: lineRange.length - start))
                lastCommentStart = 0
            }
            
            // Retain computed line information
            lineInfo.commentDepthEnd = commentDepth
            lineMap.setInfoOf(line: line, to: lineInfo)
            
        } // END tokeniseAndUpdateInfo
        
        
        guard let tokeniser = tokeniser else { return (affectedRange: originalRange, lines: 1) }
        
        // Extend the range to line boundaries. Because we cannot parse partial tokens, we at least need to go to word
        // boundaries, but because we have line bounded constructs like comments to the end of the line and it is easier to
        // determine the line boundaries, we use those.
        let lines = lineMap.linesContaining(range: originalRange),
            range = lineMap.charRangeOf(lines: lines)
        
        guard let stringRange = Range<String.Index>(range, in: textStorage.string)
        else { return (affectedRange: originalRange, lines: lines.count) }
        

        // Set the token attribute in range.
        let initialTokeniserState: LanguageConfiguration.State = initialCommentDepth > 0 ? .tokenisingComment(initialCommentDepth) : .tokenisingCode,
        tokens = textStorage
            .string[stringRange]
            .map{ $0.shifted(by: range.location) }       // adjust tokens to be relative to the whole `string`
        
        
        // For all lines in range, collect the tokens line by line, while keeping track of nested comments
        //
        // - `lastCommentStart` keeps track of the last start of an *outermost* nested comment.
        //
        var commentDepth = initialCommentDepth
        var lastCommentStart = initialCommentDepth > 0 ? lineMap.lookup(line: lines.startIndex)?.range.location : nil
        var remainingTokens  = tokens
        
        for line in lines {
            
            guard let lineRange = lineMap.lookup(line: line)?.range else { continue }
            let thisLinesTokens = remainingTokens.prefix(while: { $0.range.location < lineRange.max })
            tokeniseAndUpdateInfo(for: line,
                                  tokens: thisLinesTokens,
                                  commentDepth: &commentDepth,
                                  lastCommentStart: &lastCommentStart)
            remainingTokens.removeFirst(thisLinesTokens.count)
            
        }
        
        // Continue to re-process line by line until there is no longer a change in the comment depth before and after
        // re-processing
        //
        var currentLine = lines.endIndex
        var highlightingRange = range
        var highlightingLines = lines.count
        
        
    trailingLineLoop: while currentLine < lineMap.lines.count {
        
        if let lineEntry = lineMap.lookup(line: currentLine), let lineEntryRange = Range<String.Index>(lineEntry.range, in: textStorage.string) {
            
            // If this line has got a line info entry and the expected comment depth at the start of the line matches
            // the current comment depth, we reached the end of the range of lines affected by this edit => break the loop
            if let depth = lineEntry.info?.commentDepthStart, depth == commentDepth { break trailingLineLoop }
            
            let initialTokeniserState: LanguageConfiguration.State
            = commentDepth > 0 ? .tokenisingComment(commentDepth) : .tokenisingCode,
            tokens = textStorage
                .string[lineEntryRange]
                .tokenise(with: tokeniser, state: initialTokeniserState)
                .map{ $0.shifted(by: lineEntry.range.location) } // adjust tokens to be relative to the whole `string`
            
            // Collect the tokens and update line info
            tokeniseAndUpdateInfo(
                for: currentLine,
                tokens: tokens,
                commentDepth: &commentDepth,
                lastCommentStart: &lastCommentStart
            )
            
            // Keep track of the trailing range to report back to the caller.
            highlightingRange = NSUnionRange(highlightingRange, lineEntry.range)
            highlightingLines += 1
            
        } // END line entry
        
        currentLine += 1
    }
        
        if visualDebugging {
            textStorage.addAttribute(.backgroundColor, value: visualDebuggingTrailingColour, range: highlightingRange)
            textStorage.addAttribute(.backgroundColor, value: visualDebuggingLinesColour, range: range)
        }
        
        return (affectedRange: highlightingRange, lines: highlightingLines)
        
    } // END tokenise
    
}
