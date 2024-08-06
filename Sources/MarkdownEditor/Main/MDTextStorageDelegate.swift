//
//  File.swift
//
//
//  Created by Dave Coleman on 5/8/2024.
//

import SwiftUI


// MARK: -
// MARK: Delegate class

class MDTextStorageDelegate: NSObject, NSTextStorageDelegate {
    
    private var tokeniser: Tokeniser?
    
    /// Hook to propagate changes to the text store upwards in the view hierarchy.
    ///
    let setText: (String) -> Void
    
    private(set) var lineMap = LineMap<LineInfo>(string: "")
    
    private(set) var lastInvalidatedLineIndices: [Int] = []
    
    private var lastTypedToken: Tokeniser.Token?
    
    var skipNextChangeNotificationToRenderer: Bool = false
    
    private(set) var processingStringReplacement: Bool = false
    private(set) var processingOneCharacterAddition: Bool = false
    
    private(set) var tokenInvalidationRange: NSRange? = nil
    private(set) var tokenInvalidationLines: Int? = nil
    
    init(setText: @escaping (String) -> Void) {
        self.tokeniser = Tokeniser()
        self.setText = setText
        super.init()
    }
    
    
    
    func textStorage(
        _ textStorage: NSTextStorage,
        willProcessEditing editedMask: NSTextStorageEditActions,
        range editedRange: NSRange,
        changeInLength delta: Int)
    {
      tokenInvalidationRange = nil
      tokenInvalidationLines = nil
      guard let textStorage = textStorage as? MDTextStorage else { return }

      // If only attributes change, the line map and syntax highlighting remains the same => nothing for us to do
      guard editedMask.contains(.editedCharacters) else { return }


      // Determine the ids of message bundles that are invalidated by this edit.
      let lines = lineMap.linesAffected(by: editedRange, changeInLength: delta)


      let endColumn = if let beforeLine     = lines.last,
                         let beforeLineInfo = lineMap.lookup(line: beforeLine)
                      {
                         editedRange.max - delta - beforeLineInfo.range.location
                      } else { 0 }

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

//    // MARK: Delegate methods
//    
//    func textStorage(
//        _ textStorage: NSTextStorage,
//        willProcessEditing editedMask: NSTextStorageEditActions,
//        range editedRange: NSRange,
//        changeInLength delta: Int
//    ) {
//        guard editedMask.contains(.editedCharacters) else { return }
//        
//        processingOneCharacterAddition = delta == 1 && editedRange.length == 1
//        processingStringReplacement = editedRange.length > 1 || delta != 1
//        
//        updateLineMap(for: textStorage, editedRange: editedRange, changeInLength: delta)
//        retokenizeAffectedLines(in: textStorage, editedRange: editedRange)
//        
//        if !skipNextChangeNotificationToRenderer {
//            // Notify renderer of changes
//            // This would be implemented based on your rendering mechanism
//        }
//        
//        skipNextChangeNotificationToRenderer = false
//        processingOneCharacterAddition = false
//        processingStringReplacement = false
//        setText(textStorage.string)
//        
//    }
    
    
}



// MARK: -
// MARK: Tokenisation

extension MDTextStorageDelegate {
    
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
        func tokeniseAndUpdateInfo<Tokens: Collection<Tokeniser.Token>> (
            for line: Int,
            tokens: Tokens
        ) {
            
            guard let lineRange = lineMap.lookup(line: line)?.range else {
                return
            }

            let localisedTokens = tokens.map{ $0.shifted(by: -lineRange.location) }
            
            var lineInfo = LineInfo(
                tokens: localisedTokens
            )
            

            
            // Retain computed line information
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
        
        
//        // Set the token attribute in range.
//        let tokens = textStorage
//            .string[stringRange]
//            .map{ $0.shifted(by: range.location) }       // adjust tokens to be relative to the whole `string`
        
        
        // For all lines in range, collect the tokens line by line, while keeping track of nested comments
        //
        // - `lastCommentStart` keeps track of the last start of an *outermost* nested comment.
        //
//        var commentDepth = initialCommentDepth
//        var lastCommentStart = initialCommentDepth > 0 ? lineMap.lookup(line: lines.startIndex)?.range.location : nil
//        var remainingTokens  = tokens
        
//        for line in lines {
//            
//            guard let lineRange = lineMap.lookup(line: line)?.range else { continue }
//            let thisLinesTokens = remainingTokens.prefix(while: { $0.range.location < lineRange.max })
//            tokeniseAndUpdateInfo(for: line,
//                                  tokens: thisLinesTokens,
//                                  commentDepth: &commentDepth,
//                                  lastCommentStart: &lastCommentStart)
//            remainingTokens.removeFirst(thisLinesTokens.count)
//            
//        }
        
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
            
           let tokens = textStorage
                .string[lineEntryRange]
//                .tokenise(with: tokeniser, state: initialTokeniserState)
//                .map{ $0.shifted(by: lineEntry.range.location) } // adjust tokens to be relative to the whole `string`
            
            // Collect the tokens and update line info
//            tokeniseAndUpdateInfo(
//                for: currentLine,
//                tokens: tokens
//                
//            )
//            
            // Keep track of the trailing range to report back to the caller.
            highlightingRange = NSUnionRange(highlightingRange, lineEntry.range)
            highlightingLines += 1
            
        } // END line entry
        
        currentLine += 1
    }
        

        return (affectedRange: highlightingRange, lines: highlightingLines)
        
    } // END tokenise
    
}
