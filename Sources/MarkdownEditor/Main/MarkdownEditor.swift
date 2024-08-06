//
//  MarkdownEditor.swift
//  Banksia
//
//  Created by Dave Coleman on 17/4/2024.
//

#if os(macOS)

import Combine
import Rearrange
import Foundation
import SwiftUI
import OSLog


@MainActor
public struct MarkdownEditor: NSViewRepresentable {
    
    /// Specification of a text editing position; i.e., text selection and scroll position.
    ///
    public struct Position {
        
        /// Specification of a list of selection ranges.
        ///
        /// * A range with a zero length indicates an insertion point.
        /// * An empty array, corresponds to an insertion point at position 0.
        /// * On iOS, this can only always be one range.
        ///
        public var selections: [NSRange]
        
        public var currentToken: String
        
        public init(
            selections: [NSRange] = [],
            currentToken: String = "nil"
        ) {
            self.selections = selections
            self.currentToken = currentToken
        }
        
    }
    
    
    let breakUndoCoalescing: PassthroughSubject<(), Never>?
    
    @Binding private var position: Position
    
    @Binding public var text: String
    //    @Binding public var height: CGFloat
    public var maxWidth: CGFloat
    public var width: CGFloat
    
    
    public var searchText: String
    public var configuration: MarkdownEditorConfiguration
    
    public var id: String?
    
    public var isShowingFrames: Bool
    public var isShowingSyntax: Bool
    
    public var isEditable: Bool
    
    public var output: (_ metrics: String, _ height: CGFloat) -> Void
    
    
    public init(
        text: Binding<String>,
        position:            Binding<Position>,
        breakUndoCoalescing: PassthroughSubject<(), Never>? = nil,
        maxWidth: CGFloat = 540,
        width: CGFloat = .zero,
        searchText: String = "",
        configuration: MarkdownEditorConfiguration = MarkdownEditorConfiguration(),
        id: String? = nil,
        
        isShowingFrames: Bool = false,
        isShowingSyntax: Bool = false,
        
        isEditable: Bool = true,
        
        output: @escaping (_ metrics: String, _ height: CGFloat) -> Void = {_,_ in }
        
    ) {
        self._text = text
        self._position           = position
        self.breakUndoCoalescing = breakUndoCoalescing
        self.maxWidth = maxWidth
        self.width = width
        self.searchText = searchText
        self.configuration = configuration
        self.id = id
        self.isShowingFrames = isShowingFrames
        self.isShowingSyntax = isShowingSyntax
        self.isEditable = isEditable
        self.output = output
    }
    
    private let isPrinting: Bool = true
    
    @State private var nsViewMetrics: String = ""
    
    
    /// This function creates the NSView and configures its initial state
    public func makeNSView(context: Context) -> MDTextView {
        
        
        func setText(_ text: String) {
            guard !context.coordinator.updatingView else { return }
            
            if self.text != text { self.text = text }
        }
        context.coordinator.updatingView = true
        defer {
            context.coordinator.updatingView = false
        }
        
       
        
        // Create NSTextContentStorage
        let textContentStorage = MDTextContentStorage()
        let textStorage = MDTextStorage()
        textContentStorage.textStorage = textStorage
        
        // Create NSTextLayoutManager
        let textLayoutManager = NSTextLayoutManager()
        
        // Create NSTextContainer
        let containerSize = NSRect(x: 0, y: 0, width: self.width, height: .zero)
        let textContainer = MDTextContainer(size: containerSize.size)
//        let textContainer = NSTextContainer(size: containerSize.size)
        
        textContentStorage.addTextLayoutManager(textLayoutManager)
        textContentStorage.primaryTextLayoutManager = textLayoutManager
        
        textLayoutManager.textContainer = textContainer
        
//        textStorage.delegate = markdownTextStorageDelegate
        
        
        let textView = MDTextView(
            frame: containerSize,
            configuration: configuration,
            isShowingFrames: self.isShowingFrames,
            isShowingSyntax: self.isShowingSyntax,
            searchText: self.searchText,
            textContainer: textContainer,
            setText: setText(_:)
        )
        
        textContainer.textView = textView
        
        textLayoutManager.renderingAttributesValidator = { (textLayoutManager, layoutFragment) in
            guard let textContentStorage = textLayoutManager.textContentManager as? NSTextContentStorage else { return }
            textStorage.setHighlightingAttributes(
                for: textContentStorage.range(for: layoutFragment.rangeInElement),
                in: textLayoutManager
            )
        }
        
//        if let delegate = textView.delegate as? MDTextViewDelegate {
//
//          // The property `delegate.textDidChange` is expected to alreayd have been set during initialisation of the
//          // `CodeView`. Hence, we add to it; instead of just overwriting it.
//          let currentTextDidChange = delegate.textDidChange
//          delegate.textDidChange = { [currentTextDidChange] mdTextView in
//            context.coordinator.textDidChange(mdTextView)
//            currentTextDidChange?(mdTextView)
//          }
//          delegate.selectionDidChange = { mdTextView in
//            selectionDidChange(mdTextView)
//            context.coordinator.selectionDidChange(mdTextView)
//          }
//
//        }
        
        
        
        textView.selectedRanges = position.selections.map{ NSValue(range: $0) }
        
        
        // Break undo coalescing whenever we get a trigger over the corresponding subject.
        context.coordinator.breakUndoCoalescingCancellable = breakUndoCoalescing?.sink { [weak textView] _ in
            textView?.breakUndoCoalescing()
        }
        
        
        textView.delegate = context.coordinator
        textView.string = text
        
        
        setUpTextViewOptions(for: textView)
        
//        textView.updateMDStyling()
        //        self.sendOutSize(for: textView)
        
        
        return textView
    }
    
    /// This function is to communicate updates **from** SwiftUI, back **to** the NSView
    /// It is not for sending updates back up to SwiftUI
    /// This *will* update any time a `@Binding` property is mutated from SwiftUI
    public func updateNSView(_ textView: MDTextView, context: Context) {
        
        
        context.coordinator.updatingView = true
        defer {
            context.coordinator.updatingView = false
        }
        
        textView.breakUndoCoalescing()
        
        let selections = position.selections.map{ NSValue(range: $0) }
        
        if selections != textView.selectedRanges {
            textView.selectedRanges = selections
            
        }
        
        
        
        
        
        /// Actions that *should* reapply the styles. Determining these, so I don't have to apply styles on *every* keypress
        /// - Clicking anywhere in the text. This could be achieved with a change in selected range
        /// - Pasting new content in — I think `textDidChange` in the coordinator could help with this
        /// - Pressing space key, or return key
        /// - Possibly pressing any syntax key(s)
        
        textView.editorHeight = textView.calculateEditorHeight()
        
        if textView.string != self.text {
            textView.string = self.text
            //            textView.updateMarkdownStyling()
            //            textView.editorHeight = textView.calculateEditorHeight()
            
        }
        
        
        // Update width if changed
        if abs(textView.frame.width - self.width) > 0.1 {  // Use a small threshold to avoid floating point issues
            
            textView.invalidateIntrinsicContentSize()
            //            self.sendOutSize(for: textView)
        }
        
        // Update other properties if changed
        if textView.isShowingFrames != self.isShowingFrames {
            textView.isShowingFrames = self.isShowingFrames
        }
        
        if textView.searchText != self.searchText {
            textView.searchText = self.searchText
        }
        
        
        
    } // END update nsView
    
    
    /// It is the Coordinator that is responsible for sending information back **to** SwiftUI, from the NSView
    ///
    public func makeCoordinator() -> Coordinator {
        return Coordinator(
            text: $text,
            position: $position
        )
    }
    
    public class Coordinator: NSObject, NSTextViewDelegate {
        
        @Binding fileprivate var text:     String
        @Binding fileprivate var position: Position
        
        fileprivate var updatingView = false
        
        var lastKnownWidth: CGFloat = 0
        
        init(
            text: Binding<String>,
            position: Binding<Position>
        ) {
            self._text      = text
            self._position  = position
        }
        
        
        var boundsChangedNotificationObserver: NSObjectProtocol?
        var extraActionsCancellable:           Cancellable?
        var breakUndoCoalescingCancellable:    Cancellable?
        
        deinit {
            if let observer = boundsChangedNotificationObserver { NotificationCenter.default.removeObserver(observer) }
        }
        
        // Update of `self.text` happens in `MDTextStorageDelegate` — see [Note Propagating text changes into SwiftUI].
        func textDidChange(_ textView: NSTextView) { }
        
        func selectionDidChange(_ textView: NSTextView) {
            guard !updatingView else { return }
            
            let newValue = textView.selectedRanges.map{ $0.rangeValue }
            if self.position.selections != newValue { self.position.selections = newValue
            }
            
        }
        
    } // END coordinator
    
} // END NSViewRepresentable




#endif
