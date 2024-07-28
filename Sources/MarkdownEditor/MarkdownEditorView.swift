//
//  MarkdownEditor.swift
//  Banksia
//
//  Created by Dave Coleman on 17/4/2024.
//

#if os(macOS)

import Foundation
import SwiftUI
import OSLog


@MainActor
public struct MarkdownEditorRepresentable: NSViewRepresentable {
    
    @Binding public var text: String
    //    @Binding public var height: CGFloat
    public var maxWidth: CGFloat
    public var width: CGFloat
    
    
    public var searchText: String
    public var configuration: MarkdownEditorConfiguration?
    
    public var id: String?
    
    public var isShowingFrames: Bool
    public var isShowingSyntax: Bool
    
    public var isEditable: Bool
    
    public var output: (_ metrics: String, _ height: CGFloat) -> Void
    
    public init(
        text: Binding<String>,
        maxWidth: CGFloat = 540,
        width: CGFloat = .zero,
        searchText: String = "",
        configuration: MarkdownEditorConfiguration? = nil,
        id: String? = nil,
        
        isShowingFrames: Bool = false,
        isShowingSyntax: Bool = false,
        
        isEditable: Bool = true,
        
        output: @escaping (_ metrics: String, _ height: CGFloat) -> Void = {_,_ in }
        
    ) {
        self._text = text
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
    
    
    /// This function creates the NSView and configures its initial state
    public func makeNSView(context: Context) -> MarkdownEditor {
        
        
        /// Unlike init(frame:), which builds up an entire group of text-handling objects, you use
        /// this method after you’ve created the other components of the text-handling system —
        /// a text storage object, a layout manager, and a text container.
        ///
        /// Assembling the components in this fashion means that the text storage,
        /// not the text view, is the principal owner of the component objects.
        ///
        /// When you use this initializer (`init(frame frameRect: NSRect, textContainer container: NSTextContainer?)`)
        /// in macOS 12 and later, you have the option to use NSTextLayoutManager
        /// which gives you access to newer TextKit functionality and performance improvements.
        /// Reading: https://developer.apple.com/documentation/appkit/nstextview/1449347-init#discussion

        // Create NSTextContentStorage
        let textContentStorage = NSTextContentStorage()
        
        // Create NSTextLayoutManager
        let textLayoutManager = NSTextLayoutManager()
        
        // Create NSTextContainer
        let containerSize = NSSize(width: self.width, height: CGFloat.greatestFiniteMagnitude)
        let textContainer = NSTextContainer(size: containerSize)
        
        
        // Important: Keep a reference to text storage since NSTextView weakly references it.
//        var textContentStorage = NSTextContentStorage()
        textContentStorage.addTextLayoutManager(textLayoutManager)
        textLayoutManager.textContainer = textContainer
        
        let textView = MarkdownEditor(
            viewWidth: self.width,
            isShowingFrames: self.isShowingFrames,
            isShowingSyntax: self.isShowingSyntax,
            searchText: self.searchText,
            textContainer: textContainer
        )
        
        textView.delegate = context.coordinator
        textView.string = text
        
        // Important: Store a reference to textContentStorage
        context.coordinator.textContentStorage = textContentStorage
        
        setUpTextViewOptions(for: textView)
        
//        textView.applyStyles(to: NSRange(location: 0, length: text.utf16.count))
        
        // Set up width constraint
        //                let widthConstraint = textView.widthAnchor.constraint(equalToConstant: width)
        //                widthConstraint.isActive = true
        //                context.coordinator.widthConstraint = widthConstraint
        
        // Initial size update
        
        
        
        self.sendOutSize(for: textView)
        
        return textView
    }
    
    /// This function is to communicate updates **from** SwiftUI, back **to** the NSView
    /// It is not for sending updates back up to SwiftUI
    /// This *will* update any time a `@Binding` property is mutated from SwiftUI
    public func updateNSView(_ textView: MarkdownEditor, context: Context) {
        
        
        /// Actions that *should* reapply the styles. Determining these, so I don't have to apply styles on *every* keypress
        /// - Clicking anywhere in the text. This could be achieved with a change in selected range
        /// - Pasting new content in — I think `textDidChange` in the coordinator could help with this
        /// - Pressing space key, or return key
        /// - Possibly pressing any syntax key(s)
        
        
        // Update text if changed
        if textView.string != self.text {
            let oldLength = textView.string.utf16.count
            textView.string = text
            let newLength = text.utf16.count
            
            // Apply styles only to the changed range
            let changedRange = NSRange(location: 0, length: max(oldLength, newLength))
            textView.applyStyles(to: changedRange)
        }
        

        // Update width if changed
        if abs(textView.frame.width - self.width) > 0.1 {  // Use a small threshold to avoid floating point issues
            
            textView.invalidateIntrinsicContentSize()
            self.sendOutSize(for: textView)
        }
        
        // Update other properties if changed
        if textView.isShowingFrames != self.isShowingFrames {
            textView.isShowingFrames = self.isShowingFrames
        }
        
        if textView.searchText != self.searchText {
            textView.searchText = self.searchText
        }
        
        if abs(context.coordinator.lastKnownWidth - width) > 0.1 {
            context.coordinator.lastKnownWidth = width
            textView.invalidateIntrinsicContentSize()
            //            textView.needsLayout = true
            //            textView.needsDisplay = true
            print("This is actually being fired")
            
            self.sendOutSize(for: textView)
            //                context.coordinator.widthChangeContinuation?.yield(width)
        }
        
        
        
        
        
        
        //
        //        if textView.string != self.text {
        //            let oldLength = textView.string.utf16.count
        //            textView.string = text
        //            let newLength = text.utf16.count
        //
        //            // Apply styles only to the changed range
        //            let changedRange = NSRange(location: 0, length: max(oldLength, newLength))
        //
        //            textView.applyStyles(to: changedRange)
        //
        //            self.sendOutSize(for: textView)
        //        }
        //
        //        if textView.isShowingFrames != self.isShowingFrames {
        //            textView.isShowingFrames = self.isShowingFrames
        //            os_log("Does this ever change? is `textView.isShowingFrames` \(textView.isShowingFrames), ever different from `self.isShowingFrames`? \(self.isShowingFrames)")
        //        }
        //
        //
        //
        //        if textView.searchText != self.searchText {
        //            textView.searchText = self.searchText
        //            os_log("Does this ever change? is `textView.searchText` \(textView.searchText), ever different from `self.searchText`? \(self.searchText)")
        //        }
        //
        //        //        DispatchQueue.main.async {
        //        //                    output("Current width \(textView.frame.width)")
        //        //                }
        //
        //        let currentWidth = textView.frame.width
        //        if currentWidth != textView.frame.width {
        //            context.coordinator.lastKnownWidth = currentWidth
        //
        //            textView.invalidateIntrinsicContentSize()
        //
        //            self.sendOutSize(for: textView)
        //
        //            output("Current width \(textView.frame.width)")
        //
        ////            DispatchQueue.main.async {
        ////                self.height = textView.editorHeight
        ////                self.width = textView.editorWidth
        ////            }
        //            //                context.coordinator.applyMarkdownStyling(to: textView)
        //        }
        //
        //
        //        /// THIS WORKS TO FIX HEIGHT, WHEN WIDTH CHANGES — DON'T LOSE THISSSSS
        //                        if textView.bounds.width != self.width {
        //
        //                            self.sendOutSize(for: textView)
        //
        //
        ////                            DispatchQueue.main.async {
        ////                                output("The width changed")
        ////                            }
        //        //                    Task {
        //        //                        await MainActor.run {
        //        //
        //        //                            textView.invalidateIntrinsicContentSize()
        //        //                            self.output(textView.editorHeight)
        //        //
        //        //                        }
        //        //                    }
        //                        }
        //
        
    } // END update nsView
    
    
    /// It is the Coordinator that is responsible for sending information back **to** SwiftUI, from the NSView
    public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    public class Coordinator: NSObject, NSTextViewDelegate {
        
        var parent: MarkdownEditorRepresentable
        var textContentStorage: NSTextContentStorage?
        
        var lastKnownWidth: CGFloat = 0
        //        let widthChangeSubject = AsyncStream<CGFloat>.makeStream()
        //        var widthChangeContinuation: AsyncStream<CGFloat>.Continuation?
        //        var debounceTask: Task<Void, Never>?
        //        var widthConstraint: NSLayoutConstraint?
        
        
        public init(_ parent: MarkdownEditorRepresentable) {
            self.parent = parent
            super.init()
            //            self.widthChangeContinuation = widthChangeSubject.continuation
            //            setupDebounce()
        }
        
        /// Try `scrollRangeToVisible_` for when scroll jumps to top when pasting
        public func textDidChange(_ notification: Notification) {
            
            guard let textView = notification.object as? MarkdownEditor else { return }
            
            if self.parent.text != textView.string {
                self.parent.text = textView.string
                self.parent.sendOutSize(for: textView)
                
            }  // END text equality check
            //
        } // END Text did change
        
//        @MainActor
//        func applyMarkdownStyling(to textView: AutoGrowingTextView) {
//            
//            guard let textStorage = textView.textStorage else { return }
//            
//            let fullRange = NSRange(location: 0, length: textStorage.length)
//            let text = textStorage.string
//            
//            // Store the current selection
//            let selectedRanges = textView.selectedRanges
//            
//            // Remove all existing styles
//            textStorage.removeAttribute(.font, range: fullRange)
//            textStorage.removeAttribute(.foregroundColor, range: fullRange)
//            
//            // Apply default style
//            textStorage.addAttribute(.font, value: NSFont.systemFont(ofSize: 14), range: fullRange)
//            textStorage.addAttribute(.foregroundColor, value: NSColor.textColor, range: fullRange)
//            
//            // Apply bold styling
//            let boldPattern = try! NSRegularExpression(pattern: "\\*\\*(.+?)\\*\\*")
//            boldPattern.enumerateMatches(in: text, range: fullRange) { match, _, _ in
//                if let matchRange = match?.range(at: 1) {
//                    textStorage.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: 14), range: matchRange)
//                    textStorage.addAttribute(.foregroundColor, value: NSColor.orange, range: matchRange)
//                }
//            }
//            
//            // Apply inline code styling
//            let codePattern = try! NSRegularExpression(pattern: "`(.+?)`")
//            codePattern.enumerateMatches(in: text, range: fullRange) { match, _, _ in
//                if let matchRange = match?.range(at: 1) {
//                    textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 14, weight: .regular), range: matchRange)
//                    textStorage.addAttribute(.foregroundColor, value: NSColor.systemRed, range: matchRange)
//                }
//            }
//            
//            // Restore the selection
//            textView.selectedRanges = selectedRanges
//        }
        //        func setupDebounce() {
        //            self.debounceTask = Task {
        //                for await width in widthChangeSubject.debounce(for: .milliseconds(100)) {
        //                    await handleWidthChange(width: width)
        //                }
        //            }
        //        }
        
        
        
        //        deinit {
        //            debounceTask?.cancel()
        //            widthChangeContinuation?.finish()
        //        }
        
    } // END coordinator
    
    //    @MainActor
    //    func handleWidthChange(width: CGFloat, textView: MarkdownTextView) {
    //
    //        textView.invalidateIntrinsicContentSize()
    //        self.parent.output("Width changed to \(width)", textView.frame.height)
    //    }
    
    
    private func sendOutSize(for textView: MarkdownEditor) {
        DispatchQueue.main.async {
            self.output(
                "Height: \(textView.editorHeight)",
                textView.editorHeight + (MarkdownDefaults.paddingY * 4))
        }
        
        
//        DispatchQueue.main.async {
//            self.height = textView.intrinsicContentSize.height
//        }
    }
    
    //    @MainActor
    //    private func outputEditorHeight(for textView: MarkdownEditor, withReason: String) {
    //        DispatchQueue.main.async {
    //            textView.invalidateIntrinsicContentSize()
    ////            self.height = textView.editorHeight
    ////            self.output(textView.editorHeight)
    //        }
    //        //        os_log("Sent editor height from `textView` to SwiftUI: \(textView.editorHeight.displayAsInt()), and invalidated content size. The reason/trigger for this being executed was: \(withReason)")
    //    }
    
} // END NSViewRepresentable




#endif
