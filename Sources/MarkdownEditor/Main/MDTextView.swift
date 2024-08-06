//
//  MarkdownEditor.swift
//  Banksia
//
//  Created by Dave Coleman on 19/4/2024.
//

#if os(macOS)

import Foundation
import SwiftUI
import Highlightr
import OSLog


@MainActor
public class MDTextView: NSTextView {

    // Delegates
    fileprivate let markdownTextViewDelegate = MDTextViewDelegate()
    fileprivate var markdownTextStorageDelegate: MDTextStorageDelegate
    
    var currentLineHighlightView: BackgroundHighlightView?
    
    var insertionPoint: Int? {
      if let selection = selectedRanges.first as? NSRange, selection.length == 0 { return selection.location }
      else { return nil }
    }

    
    // Notification observer
    private var frameChangedNotificationObserver: NSObjectProtocol?
    private var didChangeNotificationObserver:    NSObjectProtocol?
    
    var oldLastLineOfInsertionPoint: Int? = 1
    
    var editorHeight: CGFloat
    var configuration: MarkdownEditorConfiguration
    var isShowingFrames: Bool
    var isShowingSyntax: Bool
    let highlightr = Highlightr()
    var textHighlighter = TextHighlighter()
    var editorMetrics: String = ""
    var searchText: String
    
    init(
        frame: NSRect,
        editorHeight: CGFloat = .zero,
        configuration: MarkdownEditorConfiguration,
        isShowingFrames: Bool,
        isShowingSyntax: Bool,
        searchText: String,
        textContainer: NSTextContainer?,
        setText: @escaping (String) -> Void
    ) {
        
        self.editorHeight = editorHeight
        self.configuration = configuration
        self.isShowingFrames = isShowingFrames
        self.isShowingSyntax = isShowingSyntax
        self.searchText = searchText

        
        markdownTextStorageDelegate = MDTextStorageDelegate(setText: setText)
        
        super.init(frame: frame, textContainer: textContainer)
        
        self.textHighlighter.textStorage = textContentStorage?.textStorage
        
        isRichText                           = false
        isAutomaticQuoteSubstitutionEnabled  = false
        isAutomaticLinkDetectionEnabled      = false
        smartInsertDeleteEnabled             = false
        isContinuousSpellCheckingEnabled     = false
        isGrammarCheckingEnabled             = false
        isAutomaticDashSubstitutionEnabled   = false
        isAutomaticDataDetectionEnabled      = false
        isAutomaticSpellingCorrectionEnabled = false
        isAutomaticTextReplacementEnabled    = false
        usesFontPanel                        = false
        
        // Line wrapping
        isHorizontallyResizable             = false
        isVerticallyResizable               = true
        textContainerInset                  = .zero
        textContainer?.widthTracksTextView  = false   // we need to be able to control the size (see `tile()`)
        textContainer?.heightTracksTextView = false
        textContainer?.lineBreakMode        = .byWordWrapping
        
        // FIXME: properties that ought to be configurable
        usesFindBar                   = true
        isIncrementalSearchingEnabled = true
        
        // Enable undo support
        allowsUndo = true
        
        // Add the view delegate
        self.delegate = markdownTextViewDelegate
        
        // Add a text storage delegate that maintains a line map
        textContentStorage?.textStorage?.delegate = markdownTextStorageDelegate
        
        let currentLineHighlightView = BackgroundHighlightView(color: NSColor.green)
        addBackgroundSubview(currentLineHighlightView)
        self.currentLineHighlightView = currentLineHighlightView
        
        
    } // END CodeView init
    
    
    
    deinit {
        if let observer = frameChangedNotificationObserver { NotificationCenter.default.removeObserver(observer) }
        if let observer = didChangeNotificationObserver { NotificationCenter.default.removeObserver(observer) }
    }
    
    
    
    
    // MARK: Overrides
    
    public override func setSelectedRanges(
        _ ranges: [NSValue],
        affinity: NSSelectionAffinity,
        stillSelecting stillSelectingFlag: Bool
    ) {
        let oldSelectedRanges = selectedRanges
        super.setSelectedRanges(ranges, affinity: affinity, stillSelecting: stillSelectingFlag)
        
        // Updates only if there is an actual selection change.
        if oldSelectedRanges != selectedRanges {
            
            
            updateBackgroundFor(oldSelection: combinedRanges(ranges: oldSelectedRanges),
                                newSelection: combinedRanges(ranges: ranges))
            
        }
    }

    /// The `required init?(coder: NSCoder)` is necessary for classes that inherit from `NSView`
    /// (which `NSTextView` does). This initializer is used when the view is loaded from a storyboard or XIB file.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
} // END markdown editor




extension MDTextView {
    

    func calculateEditorHeight() -> CGFloat {
        
        let textStorageHeight: CGFloat = self.textStorage?.size().height ?? .zero
        let paddingHeight: CGFloat = self.configuration.paddingY * 2
        let extraForGoodMeasure: CGFloat = 40
        
        return textStorageHeight + paddingHeight + extraForGoodMeasure
    }
    
    
    public override func draw(_ rect: NSRect) {
        super.draw(rect)
        
        if isShowingFrames {
            let border:NSBezierPath = NSBezierPath(rect: bounds)
            let borderColor = NSColor.red.withAlphaComponent(0.3)
            borderColor.set()
            border.lineWidth = 1.0
            border.stroke()
        }
    }
    
} // END Markdown editor extension


#endif






// MARK: -
// MARK: Shared code

extension MDTextView {
    
    // MARK: Background highlights
    
    /// Update the code background for the given selection change.
    ///
    /// - Parameters:
    ///   - oldRange: Old selection range.
    ///   - newRange: New selection range.
    ///
    /// This includes both invalidating rectangle for background redrawing as well as updating the frames of background
    /// (highlighting) views.
    ///
    func updateBackgroundFor(oldSelection oldRange: NSRange, newSelection newRange: NSRange) {
        guard let textContentStorage = textContentStorage else { return }
        
        let lineOfInsertionPoint = insertionPoint.flatMap { optLineMap?.lineOf(index: $0) }
        
        // If the insertion point changed lines, we need to redraw at the old and new location to fix the line highlighting.
        // NB: We retain the last line and not the character index as the latter may be inaccurate due to editing that let
        //     to the selected range change.
        if lineOfInsertionPoint != oldLastLineOfInsertionPoint {
            
            if let textLocation = textContentStorage.textLocation(for: oldRange.location) {
                
            }
            
            if let textLocation = textContentStorage.textLocation(for: newRange.location) {
                updateCurrentLineHighlight(for: textLocation)
                
            }
        }
        oldLastLineOfInsertionPoint = lineOfInsertionPoint
        

        
    }
    
    func updateCurrentLineHighlight(for location: NSTextLocation) {
        guard let textLayoutManager = textLayoutManager else { return }
        
        ensureLayout(includingMinimap: false)
        
        // The current line highlight view needs to be visible if we have an insertion point (and not a selection range).
        currentLineHighlightView?.isHidden = insertionPoint == nil
        
        // The insertion point is inside the body of the text
        if let fragmentFrame = textLayoutManager.textLayoutFragment(for: location)?.layoutFragmentFrameWithoutExtraLineFragment,
           let highlightRect = lineBackgroundRect(y: fragmentFrame.minY, height: fragmentFrame.height)
        {
            currentLineHighlightView?.frame = highlightRect
        } else
        // OR the insertion point is behind the end of the text, which ends with a trailing newline (=> extra line fragement)
        if let previousLocation = textContentStorage?.location(location, offsetBy: -1),
           let fragmentFrame    = textLayoutManager.textLayoutFragment(for: previousLocation)?.layoutFragmentFrameExtraLineFragment,
           let highlightRect    = lineBackgroundRect(y: fragmentFrame.minY, height: fragmentFrame.height)
        {
            currentLineHighlightView?.frame = highlightRect
        } else
        // OR the insertion point is behind the end of the text, which does NOT end with a trailing newline
        if let previousLocation = textContentStorage?.location(location, offsetBy: -1),
           let fragmentFrame    = textLayoutManager.textLayoutFragment(for: previousLocation)?.layoutFragmentFrame,
           let highlightRect    = lineBackgroundRect(y: fragmentFrame.minY, height: fragmentFrame.height)
        {
            currentLineHighlightView?.frame = highlightRect
        }
    }
    
    
    
    // MARK: Tiling
    
    /// Ensure that layout of the viewport region is complete.
    ///
    func ensureLayout(includingMinimap: Bool = true) {
        if let textLayoutManager {
            textLayoutManager.ensureLayout(for: textLayoutManager.textViewportLayoutController.viewportBounds)
        }
    }


    
}



// MARK: Selection change management

/// Common code view actions triggered on a selection change.
///
@MainActor func selectionDidChange(_ textView: MDTextView) {
//    guard let textStorage = textView.textStorage,
//          let visibleLines = textView.documentVisibleLines
//    else { return }
    
}


// MARK: NSRange

/// Combine selection ranges into the smallest ranges encompassing them all.
///
private func combinedRanges(ranges: [NSValue]) -> NSRange {
    let actualranges = ranges.compactMap{ $0 as? NSRange }
    return actualranges.dropFirst().reduce(actualranges.first ?? .zero) {
        NSUnionRange($0, $1)
    }
}


extension MarkdownEditor {
    
    func setUpTextViewOptions(for textView: MDTextView) {
        
        //        guard let textContainer = textView.textContainer else { return }
        
        //        textContainer.containerSize = CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)
        
        /// If this is set to false, then the text tends to be allowed to run off the right edge,
        /// and less width-related calculations seem to be neccesary
        //        textContainer.widthTracksTextView = true
        //        textContainer.heightTracksTextView = false
        
        //        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        
        textView.isAutomaticSpellingCorrectionEnabled = true
        textView.isAutomaticTextCompletionEnabled = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = true
        
        //        textView.wantsScrollEventsForSwipeTracking(on: .none)
        //        textView.wantsForwardedScrollEvents(for: .none)
        
        
        
        textView.isRichText = false
        textView.importsGraphics = false
        
        textView.insertionPointColor = NSColor(configuration.insertionPointColour)
        
        textView.smartInsertDeleteEnabled = false
        
        //        textView.usesFindBar = true
        
        textView.textContainer?.lineFragmentPadding = configuration.paddingX
        textView.textContainerInset = NSSize(width: 0, height: configuration.paddingY)
        
        
        //        textView.maxSize = NSSize(width: self.maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        
        
        /// When the text field has an attributed string value, the system ignores the textColor, font, alignment, lineBreakMode, and lineBreakStrategy properties. Set the foregroundColor, font, alignment, lineBreakMode, and lineBreakStrategy properties in the attributed string instead.
        textView.font = NSFont.systemFont(ofSize: configuration.fontSize, weight: configuration.fontWeight)
        
        textView.textColor = NSColor.textColor.withAlphaComponent(MarkdownDefaults.fontOpacity)
        
        textView.isEditable = self.isEditable
        
        textView.drawsBackground = false
        textView.allowsUndo = true
        //        textView.setNeedsDisplay(textView.bounds)
        //                textView.setNeedsDisplay(NSRect(x: 0, y: 0, width: self.editorWidth ?? 200, height: 200))
    }
    
}
