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


/// ⚠️ In macOS 12 and later, if you explicitly call the layoutManager property on a text view or text container,
/// the framework reverts to a compatibility mode that uses NSLayoutManager. The text view also switches
/// to this compatibility mode when it encounters text content that’s not yet supported, such as NSTextTable.
/// Read more: https://developer.apple.com/documentation/appkit/nstextview
///
/// Either one of these statements makes text view switch to TextKit 1
/// `let layoutManager = textView. layoutManager`
/// `let containerLayoutManager = textView.textContainer. layoutManager`

@MainActor
public class MarkdownTextView: NSTextView {
    
    
    
    
    
    // Delegates
    fileprivate let markdownTextViewDelegate =                 MarkdownTextViewDelegate()
    fileprivate var markdownTextStorageDelegate:               MarkdownTextStorageDelegate
    
    
    
    var currentLineHighlightView: CodeBackgroundHighlightView?
    
    // Notification observer
    private var frameChangedNotificationObserver: NSObjectProtocol?
    private var didChangeNotificationObserver:    NSObjectProtocol?
    
    /// Designated initialiser for code views with a gutter.
    ///
    init(frame: CGRect,
         //         theme: Theme,
         setText: @escaping (String) -> Void
    )
    {
        //        self.theme       = theme
        
        
        // Use custom components that are gutter-aware and support code-specific editing actions and highlighting.
        let textLayoutManager = NSTextLayoutManager()
        let codeContainer = CodeContainer(size: frame.size)
        let codeStorage = MarkdownTextStorage(theme: theme)
        
        let textContentStorage = MarkdownTextContentStorage()
        
        textLayoutManager.textContainer = codeContainer
        textContentStorage.addTextLayoutManager(textLayoutManager)
        textContentStorage.primaryTextLayoutManager = textLayoutManager
        textContentStorage.textStorage = codeStorage
        
        
        markdownTextStorageDelegate = MarkdownTextStorageDelegate(codeBlockManager: nil, setText: setText)
        
        super.init(frame: frame, textContainer: codeContainer)
        
        codeContainer.textView = self
        
        textLayoutManager.setSafeRenderingAttributesValidator(with: markdownTextViewDelegate) { (textLayoutManager, layoutFragment) in
            guard let textContentStorage = textLayoutManager.textContentManager as? NSTextContentStorage else { return }
            
            codeStorage.setHighlightingAttributes(for: textContentStorage.range(for: layoutFragment.rangeInElement),
                                                  in: textLayoutManager)
        }.flatMap { observations.append($0) }
        
        
        // Set basic display and input properties
        //        font                                 = theme.font
        //        backgroundColor                      = theme.backgroundColour
        //        insertionPointColor                  = theme.cursorColour
        //        selectedTextAttributes               = [.backgroundColor: theme.selectionColour]
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
        delegate = markdownTextViewDelegate
        
        // Add a text storage delegate that maintains a line map
        codeStorage.delegate = markdownTextStorageDelegate
        
        
        let currentLineHighlightView = CodeBackgroundHighlightView(color: theme.currentLineColour)
        addBackgroundSubview(currentLineHighlightView)
        self.currentLineHighlightView = currentLineHighlightView
        
        
        
        // We need to re-tile the subviews whenever the frame of the text view changes.
        frameChangedNotificationObserver
        = NotificationCenter.default.addObserver(forName: NSView.frameDidChangeNotification,
                                                 object: enclosingScrollView,
                                                 queue: .main){ [weak self] _ in
            
            
        }
        
    } // END CodeView init
    
    
    
    deinit {
        if let observer = frameChangedNotificationObserver { NotificationCenter.default.removeObserver(observer) }
        if let observer = didChangeNotificationObserver { NotificationCenter.default.removeObserver(observer) }
    }
    
    
    
    
    // MARK: Overrides
    
    override func setSelectedRanges(
        _ ranges: [NSValue],
        affinity: NSSelectionAffinity,
        stillSelecting stillSelectingFlag: Bool
    ) {
        let oldSelectedRanges = selectedRanges
        super.setSelectedRanges(ranges, affinity: affinity, stillSelecting: stillSelectingFlag)
        
        // Updates only if there is an actual selection change.
        if oldSelectedRanges != selectedRanges {
            
            minimapView?.selectedRanges = selectedRanges    // minimap mirrors the selection of the main code view
            
            updateBackgroundFor(oldSelection: combinedRanges(ranges: oldSelectedRanges),
                                newSelection: combinedRanges(ranges: ranges))
            
        }
    }
    
    override func layout() {
        tile()
        adjustScrollPositionOfMinimap()
        super.layout()
        gutterView?.needsDisplay        = true
        minimapGutterView?.needsDisplay = true
    }
    
    
    
    
    
    
    
    
    
    
    var editorHeight: CGFloat
    var configuration: MarkdownEditorConfiguration
    var isShowingFrames: Bool
    var isShowingSyntax: Bool
    let highlightr = Highlightr()
    let styler = MarkdownStyleManager()
    var textHighlighter = TextHighlighter()
    var editorMetrics: String = ""
    var searchText: String
    
    init(
        frame: NSSize,
        editorHeight: CGFloat = .zero,
        configuration: MarkdownEditorConfiguration,
        isShowingFrames: Bool,
        isShowingSyntax: Bool,
        searchText: String,
        textContainer: NSTextContainer?
    ) {
        
        self.editorHeight = editorHeight
        self.configuration = configuration
        self.isShowingFrames = isShowingFrames
        self.isShowingSyntax = isShowingSyntax
        self.searchText = searchText
        
        super.init(frame: .zero, textContainer: textContainer)
        
        self.textHighlighter.textStorage = textContentStorage?.textStorage
        
    }
    
    
    /// The `required init?(coder: NSCoder)` is necessary for classes that inherit from `NSView`
    /// (which `NSTextView` does). This initializer is used when the view is loaded from a storyboard or XIB file.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyParagraphStyles(range: NSRange) {
        
        guard let textStorage = self.textContentStorage?.textStorage else { return }
        
        let globalParagraphStyle = NSMutableParagraphStyle()
        globalParagraphStyle.lineSpacing = MarkdownDefaults.lineSpacing
        globalParagraphStyle.paragraphSpacing = MarkdownDefaults.paragraphSpacing
        
        //        let attributedString = NSMutableAttributedString(string: textStorage.string, attributes: baseStyles)
        
    }
    
    
    func updateMarkdownStyling() {
        
        guard let textContentStorage = self.textContentStorage,
              let textLayoutManager = self.textLayoutManager,
              let textContentManager = textLayoutManager.textContentManager,
              let textStorage = textContentStorage.textStorage,
              let documentRange: NSRange = textContentStorage.range(for: textContentManager.documentRange)
        else { return }
        
        textContentStorage.performEditingTransaction {
            
            let currentSelectedRange = self.selectedRange()
            
            let globalParagraphStyles = NSMutableParagraphStyle()
            globalParagraphStyles.lineSpacing = MarkdownDefaults.lineSpacing
            globalParagraphStyles.paragraphSpacing = MarkdownDefaults.paragraphSpacing
            
            let baseStyles: [NSAttributedString.Key : Any] = [
                .font: NSFont.systemFont(ofSize: MarkdownDefaults.fontSize, weight: MarkdownDefaults.fontWeight),
                .foregroundColor: NSColor.textColor.withAlphaComponent(MarkdownDefaults.fontOpacity),
                .paragraphStyle: globalParagraphStyles
            ]
            
            
            let attributedString = NSMutableAttributedString(string: textStorage.string, attributes: baseStyles)
            
            
            
            
            for syntax in MarkdownSyntax.allCases {
                
                //            styler.applyStyleForPattern(syntax, in: textContentStorage.documentRange, textContentManager: textContentManager, textStorage: textStorage)
                applyStyleForPattern(
                    syntax,
                    in: textContentManager.documentRange,
                    withString: attributedString
                )
            }
            
            self.setSelectedRange(currentSelectedRange)
            
            // Update last styled ranges
            //            lastStyledRanges = [viewportRange]
            
        } // END performEditingTransaction
    }
    
    
    private func applyStyleForPattern(
        _ syntax: MarkdownSyntax,
        in nsTextRange: NSTextRange,
        withString attributedString: NSMutableAttributedString
    ) {
        
        guard let textLayoutManager = self.textLayoutManager else { return }
        guard let textContentManager = textLayoutManager.textContentManager else { return }
        guard let textContentStorage = self.textContentStorage else { return }
        guard let textStorage = textContentStorage.textStorage else { return }
        
        guard let range = textContentManager.range(for: nsTextRange) else { return }
        
        guard let regex = syntax.regex else { return }
        
        guard let documentRange: NSRange = textContentStorage.range(for: textContentManager.documentRange) else { return }
        
        
        let syntaxCharacterCount: Int = syntax.syntaxCharacters.count
        let isSyntaxSymmetrical: Bool = syntax.isSyntaxSymmetrical
        
        regex.enumerateMatches(in: string, options: [], range: range) { match, _, _ in
            
            guard let match = match else { return }
            
            let matchRange = match.range
            
            
            
            /// Content range
            let contentLocation: Int = max(range.location ,syntax == .codeBlock ?  range.location + syntaxCharacterCount + 1 : range.location + syntaxCharacterCount)
            let contentLength = min(range.length - (isSyntaxSymmetrical ? 2 : 1) * syntaxCharacterCount, attributedString.length - contentLocation)
            let contentRange = NSRange(location: contentLocation, length: contentLength)
            
            /// Opening syntax range
            let startSyntaxLocation = range.location
            let startSyntaxLength = min(syntax == .codeBlock ? syntaxCharacterCount + 1 : syntaxCharacterCount, attributedString.length - startSyntaxLocation)
            let startSyntaxRange = NSRange(location: startSyntaxLocation, length: startSyntaxLength)
            
            /// Closing syntax range
            let endSyntaxLocation = max(0, range.location + range.length - syntaxCharacterCount)
            let endSyntaxLength = min(syntax == .codeBlock ? syntaxCharacterCount + 1 : syntaxCharacterCount, attributedString.length - endSyntaxLocation)
            let endSyntaxRange = NSRange(location: endSyntaxLocation, length: endSyntaxLength)
            
            
            
            textContentStorage.performEditingTransaction {
                
                
                
                /// Apply attributes to opening and closing syntax
                if attributedString.length >= startSyntaxRange.upperBound {
                    
                    attributedString.addAttributes(syntax.syntaxAttributes, range: startSyntaxRange)
                }
                
                if attributedString.length >= endSyntaxRange.upperBound {
                    attributedString.addAttributes(syntax.syntaxAttributes, range: endSyntaxRange)
                }
                
                /// Apply attributes to content
                if attributedString.length >= contentRange.upperBound {
                    attributedString.addAttributes(syntax.contentAttributes, range: contentRange)
                    
                    if syntax == .inlineCode {
                        
                        let userCodeColour: [NSAttributedString.Key : Any] = [
                            .foregroundColor: NSColor(configuration.codeColour).withAlphaComponent(0.8),
                        ]
                        
                        
                        
                        attributedString.addAttributes(userCodeColour, range: contentRange)
                    }
                }
                
                if syntax == .codeBlock {
                    
                    if let highlightr = highlightr {
                        
                        highlightr.setTheme(to: "xcode-dark")
                        
                        highlightr.theme.setCodeFont(.monospacedSystemFont(ofSize: 14, weight: .medium))
                        
                        // Extract the substring for the code block
                        let codeString = attributedString.attributedSubstring(from: contentRange).string
                        
                        // Highlight the extracted code string
                        if let highlightedCode = highlightr.highlight(codeString, as: "swift") {
                            
                            //                        attributedString.replaceCharacters(in: contentRange, with: highlightedCode)
                            textStorage.replaceCharacters(in: contentRange, with: highlightedCode)
                            
                            let codeBackground: [NSAttributedString.Key : Any] = [.backgroundColor: NSColor.black.withAlphaComponent(MarkdownDefaults.backgroundCodeBlock)]
                            
                            //                        attributedString.addAttributes(codeBackground, range: contentRange)
                            attributedString.addAttributes(codeBackground, range: contentRange)
                            
                        }
                    } // END highlighter check
                    
                } // end code block check
                
                
                
                
                //
                //                attributedString.addAttributes(syntax.syntaxAttributes, range: startSyntaxRange)
                //                attributedString.addAttributes(syntax.syntaxAttributes, range: endSyntaxRange)
                //                attributedString.addAttributes(syntax.contentAttributes, range: contentRange)
                
                //                textLayoutManager.addRenderingAttribute(.foregroundColor, value: NSColor.green, for: range)
                
                //                textStorage.removeAttribute(.backgroundColor, range: documentRange)
                
                // Apply attributes
                //                                textStorage.setAttributes(syntax.syntaxAttributes, range: startSyntaxRange)
                //            textStorage.addAttributes(syntax.syntaxAttributes, range: startSyntaxRange)
                //                textStorage.setAttributes(syntax.syntaxAttributes, range: endSyntaxRange)
                
                //            textStorage.removeAttribute(.backgroundColor, range: contentRange)
                
                
                //                if syntax == .codeBlock {
                //
                //                    guard let highlightr = highlightr else { return }
                //
                //                    highlightr.setTheme(to: "xcode-dark")
                //
                //                    highlightr.theme.setCodeFont(.monospacedSystemFont(ofSize: 14, weight: .medium))
                //
                //                    // Extract the substring for the code block
                //
                //                    textStorage.addAttributes(syntax.syntaxAttributes, range: startSyntaxRange)
                //
                //
                //                    let codeString = textStorage.attributedSubstring(from: contentRange).string
                //
                //                    // Highlight the extracted code string
                //                    if let highlightedCode = highlightr.highlight(codeString, as: "swift") {
                //
                //                        textStorage.replaceCharacters(in: contentRange, with: highlightedCode)
                //
                //                        let codeBackground: [NSAttributedString.Key : Any] = [.backgroundColor: NSColor.black.withAlphaComponent(MarkdownDefaults.backgroundCodeBlock)]
                //
                //                        //                        textStorage.addAttribute(.paragraphStyle, value: globalParagraphStyles, range: range)
                //
                //                        //                        textStorage.addAttributes(codeBackground, range: contentRange)
                //                        //                        textStorage.addAttributes(codeBackground, range: contentRange)
                //
                //                    }
                //
                
                //                } // end code block check
                
                
                
                //                textStorage.setAttributes(syntax.contentAttributes, range: contentRange)
                
                //                textStorage.addAttributes(syntax.syntaxAttributes, range: startSyntaxRange)
                //                textStorage.addAttributes(syntax.syntaxAttributes, range: endSyntaxRange)
                
                
                textStorage.setAttributedString(attributedString)
                
            } // END editing transaction
            
            
            
        }
    } // END main styling thing
    
    
    public override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        self.updateMetrics(with: "`viewDidEndLiveResize`")
        updateMarkdownStyling()
    }
    
    private func calculateRange(
        for syntax: MarkdownSyntax,
        matchRange: NSRange,
        component: SyntaxComponent,
        in string: String
    ) -> NSRange {
        let syntaxCharacterCount = syntax.syntaxCharacterCount
        let isSyntaxSymmetrical = syntax.isSyntaxSymmetrical
        let isCodeBlock = syntax == .codeBlock
        
        let location: Int
        let length: Int
        
        switch component {
            case .open:
                location = matchRange.location
                length = isCodeBlock ? syntaxCharacterCount + 1 : syntaxCharacterCount
                
                
            case .content:
                location = isCodeBlock ? matchRange.location + syntaxCharacterCount + 1 : matchRange.location + syntaxCharacterCount
                length = matchRange.length - (isSyntaxSymmetrical ? 2 : 1) * syntaxCharacterCount
                
            case .close:
                location = matchRange.location + matchRange.length - syntaxCharacterCount
                length = isCodeBlock ? syntaxCharacterCount + 1 : syntaxCharacterCount
        }
        
        
        return NSRange(location: max(location, 0), length: min(length, string.count - location))
    }
    
    
} // END markdown editor




extension MarkdownTextView {
    
    public override func didChangeText() {
        super.didChangeText()
        
        //        invalidateIntrinsicContentSize()
        
        self.editorHeight = calculateEditorHeight()
        self.updateMarkdownStyling()
    }
    
    
    public func updateMetrics(with message: String) {
        
        if !self.editorMetrics.contains(message) {
            editorMetrics += message
        }
    }
    
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

extension MarkdownTextView {
    
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
        guard let textContentStorage = optTextContentStorage else { return }
        
        let lineOfInsertionPoint = insertionPoint.flatMap{ optLineMap?.lineOf(index: $0) }
        
        // If the insertion point changed lines, we need to redraw at the old and new location to fix the line highlighting.
        // NB: We retain the last line and not the character index as the latter may be inaccurate due to editing that let
        //     to the selected range change.
        if lineOfInsertionPoint != oldLastLineOfInsertionPoint {
            
            if let textLocation = textContentStorage.textLocation(for: oldRange.location) {
                minimapView?.invalidateBackground(forLineContaining: textLocation)
            }
            
            if let textLocation = textContentStorage.textLocation(for: newRange.location) {
                updateCurrentLineHighlight(for: textLocation)
                minimapView?.invalidateBackground(forLineContaining: textLocation)
            }
        }
        oldLastLineOfInsertionPoint = lineOfInsertionPoint
        
        // Needed as the selection affects line number highlighting.
        // NB: Invalidation of the old and new ranges needs to happen separately. If we were to union them, an insertion
        //     point (range length = 0) at the start of a line would be absorbed into the previous line, which results in
        //     a lack of invalidation of the line on which the insertion point is located.
        
        /// Dave edit
        gutterView?.invalidateGutter(for: oldRange)
        gutterView?.invalidateGutter(for: newRange)
        minimapGutterView?.invalidateGutter(for: oldRange)
        minimapGutterView?.invalidateGutter(for: newRange)
        
    }
    
    func updateCurrentLineHighlight(for location: NSTextLocation) {
        guard let textLayoutManager = optTextLayoutManager else { return }
        
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
        if let previousLocation = optTextContentStorage?.location(location, offsetBy: -1),
           let fragmentFrame    = textLayoutManager.textLayoutFragment(for: previousLocation)?.layoutFragmentFrameExtraLineFragment,
           let highlightRect    = lineBackgroundRect(y: fragmentFrame.minY, height: fragmentFrame.height)
        {
            currentLineHighlightView?.frame = highlightRect
        } else
        // OR the insertion point is behind the end of the text, which does NOT end with a trailing newline
        if let previousLocation = optTextContentStorage?.location(location, offsetBy: -1),
           let fragmentFrame    = textLayoutManager.textLayoutFragment(for: previousLocation)?.layoutFragmentFrame,
           let highlightRect    = lineBackgroundRect(y: fragmentFrame.minY, height: fragmentFrame.height)
        {
            currentLineHighlightView?.frame = highlightRect
        } else
        // OR the document is empty
        if text.isEmpty,
           let highlightRect = lineBackgroundRect(y: 0, height: font?.lineHeight ?? 0)
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
        if includingMinimap,
           let textLayoutManager = minimapView?.textLayoutManager
        {
            textLayoutManager.ensureLayout(for: textLayoutManager.textViewportLayoutController.viewportBounds)
        }
    }
    
    /// Position and size the gutter and minimap and set the text container sizes and exclusion paths. Take the current
    /// view layout in `viewLayout` into account.
    ///
    /// * The main text view contains three subviews: (1) the main gutter on its left side, (2) the minimap on its right
    ///   side, and (3) a divider in between the code view and the minimap gutter.
    /// * The main text view by way of `lineFragmentRect(forProposedRect:at:writingDirection:remaining:)`and the minimap
    ///   view (or rather their text container) by way of an exclusion path keep text out of the gutter view. The main
    ///   text view is moreover sized to avoid overlap with the minimap.
    /// * The minimap is a fixed factor `minimapRatio` smaller than the main text view and uses a correspondingly smaller
    ///   font accomodate exactly the same number of characters, so that line breaking procceds in the exact same way.
    ///
    /// NB: We don't use a ruler view for the gutter on macOS to be able to use the same setup on macOS and iOS.
    ///
    @MainActor
    private func tile() {
        guard let codeContainer = optTextContainer as? CodeContainer else { return }
        
#if os(macOS)
        // Add the floating views if they are not yet in the view hierachy.
        // NB: Since macOS 14, we need to explicitly set clipping; otherwise, views will draw outside of the bounds of the
        //     scroll view. We need to do this vor each view, as it is not guaranteed that they share a container view.
        
        /// Dave edit
        if let view = gutterView, view.superview == nil {
            
            enclosingScrollView?.addFloatingSubview(view, for: .horizontal)
            view.superview?.clipsToBounds = true
            
        }
        if let view = minimapDividerView, view.superview == nil {
            enclosingScrollView?.addFloatingSubview(view, for: .horizontal)
            view.superview?.clipsToBounds = true
        }
        if let view = minimapView, view.superview == nil {
            enclosingScrollView?.addFloatingSubview(view, for: .horizontal)
            view.superview?.clipsToBounds = true
        }
#endif
        
        // Compute size of the main view gutter
        //
        
        /// Dave: Consider implications of non-fixed-width fonts
        ///
        let theFont                 = font ?? OSFont.systemFont(ofSize: 0)
        let fontWidth               = theFont.maximumHorizontalAdvancement  // NB: we deal only with fixed width fonts
        let gutterWidthInCharacters = CGFloat(7)
        
        
        
        let gutterWidth: CGFloat             = .zero
        //        let gutterWidth             = (ceil(fontWidth * gutterWidthInCharacters))
        let minimumHeight           = max(contentSize.height, documentVisibleRect.height)
        let gutterSize              = CGSize(width: gutterWidth, height: minimumHeight)
        let lineFragmentPadding     = CGFloat(5)
        
        if gutterView?.frame.size != gutterSize { gutterView?.frame = CGRect(origin: .zero, size: gutterSize) }
        
        // Compute sizes of the minimap text view and gutter
        //
        let minimapFontWidth     = fontWidth / minimapRatio,
            minimapGutterWidth   = ceil(minimapFontWidth * gutterWidthInCharacters),
            dividerWidth         = CGFloat(1),
            minimapGutterRect    = CGRect(origin: CGPoint.zero,
                                          size: CGSize(width: minimapGutterWidth, height: minimumHeight)).integral,
            minimapExtras        = minimapGutterWidth + dividerWidth,
            gutterWithPadding    = gutterWidth + lineFragmentPadding,
            visibleWidth         = documentVisibleRect.width,
            widthWithoutGutters  = if viewLayout.showMinimap { visibleWidth - gutterWithPadding - minimapExtras  }
        else { visibleWidth - gutterWithPadding },
        compositeFontWidth   = if viewLayout.showMinimap { fontWidth + minimapFontWidth  } else { fontWidth },
        numberOfCharacters   = widthWithoutGutters / compositeFontWidth,
        codeViewWidth        = if viewLayout.showMinimap { gutterWithPadding + ceil(numberOfCharacters * fontWidth) }
        else { visibleWidth },
        minimapWidth         = visibleWidth - codeViewWidth,
        minimapX             = floor(visibleWidth - minimapWidth),
        minimapExclusionPath = OSBezierPath(rect: minimapGutterRect),
        minimapDividerRect   = CGRect(x: minimapX - dividerWidth, y: 0, width: dividerWidth, height: minimumHeight).integral
        
        minimapDividerView?.isHidden = !viewLayout.showMinimap
        minimapView?.isHidden        = !viewLayout.showMinimap
        if let minimapViewFrame = minimapView?.frame,
           viewLayout.showMinimap
        {
            
            if minimapDividerView?.frame != minimapDividerRect { minimapDividerView?.frame = minimapDividerRect }
            if minimapViewFrame.origin.x != minimapX || minimapViewFrame.width != minimapWidth {
                
                minimapView?.frame       = CGRect(x: minimapX,
                                                  y: minimapViewFrame.minY,
                                                  width: minimapWidth,
                                                  height: minimapViewFrame.height)
                minimapGutterView?.frame = minimapGutterRect
#if os(macOS)
                minimapView?.minSize     = CGSize(width: minimapFontWidth, height: visibleRect.height)
#endif
                
            }
        }
        
#if os(iOS) || os(visionOS)
        showsHorizontalScrollIndicator = !viewLayout.wrapText
        if viewLayout.wrapText && frame.size.width != visibleWidth { frame.size.width = visibleWidth }  // don't update frames in vain
#elseif os(macOS)
        enclosingScrollView?.hasHorizontalScroller = !viewLayout.wrapText
        isHorizontallyResizable                    = !viewLayout.wrapText
        if !isHorizontallyResizable && frame.size.width != visibleWidth { frame.size.width = visibleWidth }  // don't update frames in vain
#endif
        
        // Set the text container area of the main text view to reach up to the minimap
        // NB: We use the `excess` width to capture the slack that arises when the window width admits a fractional
        //     number of characters. Adding the slack to the code view's text container size doesn't work as the line breaks
        //     of the minimap and main code view are then sometimes not entirely in sync.
        /// Dave: The condition gutter width above should mean this doesn't impact the codeViewWidth
        let codeContainerWidth = if viewLayout.wrapText { codeViewWidth - gutterWidth } else { CGFloat.greatestFiniteMagnitude }
        if codeContainer.size.width != codeContainerWidth {
            codeContainer.size = CGSize(width: codeContainerWidth, height: CGFloat.greatestFiniteMagnitude)
        }
        
        codeContainer.lineFragmentPadding = lineFragmentPadding
#if os(macOS)
        if textContainerInset.width != gutterWidth {
            textContainerInset = CGSize(width: gutterWidth, height: 0)
        }
#elseif os(iOS) || os(visionOS)
        if textContainerInset.left != gutterWidth {
            textContainerInset = UIEdgeInsets(top: 0, left: gutterWidth, bottom: 0, right: 0)
        }
#endif
        
        // Set the width of the text container for the minimap just like that for the code view as the layout engine works
        // on the original code view metrics. (Only after the layout is done, we scale it down to the size of the minimap.)
        let minimapTextContainerWidth = codeContainerWidth
        let minimapTextContainer = minimapView?.textContainer
        if minimapWidth != minimapView?.frame.width || minimapTextContainerWidth != minimapTextContainer?.size.width {
            
            minimapTextContainer?.exclusionPaths      = [minimapExclusionPath]
            minimapTextContainer?.size                = CGSize(width: minimapTextContainerWidth,
                                                               height: CGFloat.greatestFiniteMagnitude)
            minimapTextContainer?.lineFragmentPadding = 0
            
        }
        
        // Only after tiling can we get the correct frame for the highlight views.
        if let textLocation = optTextContentStorage?.textLocation(for: selectedRange.location) {
            updateCurrentLineHighlight(for: textLocation)
        }
    }
    
    
    // MARK: Scrolling
    
    /// Sets the scrolling position of the minimap in dependence of the scroll position of the main code view.
    ///
    func adjustScrollPositionOfMinimap() {
        guard viewLayout.showMinimap,
              let minimapTextLayoutManager = minimapView?.textLayoutManager
        else { return }
        
        textLayoutManager?.ensureLayout(for: textLayoutManager!.documentRange)
        minimapTextLayoutManager.ensureLayout(for: minimapTextLayoutManager.documentRange)
        
        // NB: We don't use `minimapView?.contentSize.height`, because it is too large if the code doesn't fill the whole
        //     visible portion of the minimap view. Moreover, even for the code view, `contentSize` may not yet have been
        //     adjusted, whereas we know that the layout is complete (as we ensure that above).
        guard let codeHeight
                = optTextLayoutManager?.textLayoutFragmentExtent(for: optTextLayoutManager!.documentRange)?.height,
              let minimapHeight
                = minimapTextLayoutManager.textLayoutFragmentExtent(for: minimapTextLayoutManager.documentRange)?.height
        else { return }
        
        let visibleHeight = documentVisibleRect.size.height
        
#if os(iOS) || os(visionOS)
        // We need to force the scroll view (superclass of `UITextView`) to accomodate the whole content without scrolling
        // and to extent over the whole visible height. (On macOS, the latter is enforced by setting `minSize` in `tile()`.)
        let minimapMinimalHeight = max(minimapHeight, documentVisibleRect.height)
        if let currentHeight = minimapView?.frame.size.height,
           minimapMinimalHeight > currentHeight
        {
            minimapView?.frame.size.height = minimapMinimalHeight
        }
#endif
        
        let scrollFactor: CGFloat = if minimapHeight < visibleHeight || codeHeight <= visibleHeight { 1 }
        else { 1 - (minimapHeight - visibleHeight) / (codeHeight - visibleHeight) }
        
        // We box the positioning of the minimap at the top and the bottom of the code view (with the `max` and `min`
        // expessions. This is necessary as the minimap will otherwise be partially cut off by the enclosing clip view.
        // To get Xcode-like behaviour, where the minimap sticks to the top, it being a floating view is not sufficient.
        let newOriginY = floor(min(max(documentVisibleRect.origin.y * scrollFactor, 0),
                                   codeHeight - minimapHeight))
        if minimapView?.frame.origin.y != newOriginY { minimapView?.frame.origin.y = newOriginY }  // don't update frames in vain
        
        let heightRatio: CGFloat = if codeHeight <= minimapHeight { 1 } else { minimapHeight / codeHeight }
        let minimapVisibleY      = documentVisibleRect.origin.y * heightRatio,
            minimapVisibleHeight = visibleHeight * heightRatio,
            documentVisibleFrame = CGRect(x: 0,
                                          y: minimapVisibleY,
                                          width: minimapView?.bounds.size.width ?? 0,
                                          height: minimapVisibleHeight).integral
        if documentVisibleBox?.frame != documentVisibleFrame { documentVisibleBox?.frame = documentVisibleFrame }  // don't update frames in vain
    }
    
}


// MARK: Code container

final class CodeContainer: NSTextContainer {
    
#if os(iOS) || os(visionOS)
    weak var textView: UITextView?
#endif
    
    // We adapt line fragment rects in two ways: (1) we leave `gutterWidth` space on the left hand side and (2) on every
    // line that contains a message, we leave `MessageView.minimumInlineWidth` space on the right hand side (but only for
    // the first line fragment of a layout fragment).
    override func lineFragmentRect(forProposedRect proposedRect: CGRect,
                                   at characterIndex: Int,
                                   writingDirection baseWritingDirection: NSWritingDirection,
                                   remaining remainingRect: UnsafeMutablePointer<CGRect>?)
    -> CGRect
    {
        let superRect      = super.lineFragmentRect(forProposedRect: proposedRect,
                                                    at: characterIndex,
                                                    writingDirection: baseWritingDirection,
                                                    remaining: remainingRect),
            calculatedRect = CGRect(x: 0, y: superRect.minY, width: size.width, height: superRect.height)
        
        guard let codeView    = textView as? MarkdownTextView,
              let codeStorage = codeView.optMarkdownTextStorage,
              let delegate    = codeStorage.delegate as? MarkdownTextStorageDelegate,
              let line        = delegate.lineMap.lineOf(index: characterIndex),
              let oneLine     = delegate.lineMap.lookup(line: line),
              characterIndex == oneLine.range.location     // do the following only for the first line fragment of a line
        else { return calculatedRect }
        
        return calculatedRect
    }
}


// MARK: Selection change management

/// Common code view actions triggered on a selection change.
///
func selectionDidChange<TV: TextView>(_ textView: TV) {
    guard let codeStorage  = textView.optMarkdownTextStorage,
          let visibleLines = textView.documentVisibleLines
    else { return }
    
    
    if let location             = textView.insertionPoint,
       let matchingBracketRange = codeStorage.matchingBracket(at: location, in: visibleLines)
    {
        textView.showFindIndicator(for: matchingBracketRange)
    }
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
