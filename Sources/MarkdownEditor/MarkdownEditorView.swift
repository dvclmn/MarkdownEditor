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
    public var configuration: MarkdownEditorConfiguration
    
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
        configuration: MarkdownEditorConfiguration = MarkdownEditorConfiguration(),
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
    
    @State private var nsViewMetrics: String = ""
    
    
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
        let textStorage = MarkdownTextStorage()
        textContentStorage.textStorage = textStorage
        
        // Create NSTextLayoutManager
        let textLayoutManager = NSTextLayoutManager()
        
        // Create NSTextContainer
        let containerSize = NSSize(width: self.width, height: .zero)
        let textContainer = NSTextContainer(size: containerSize)

        textContentStorage.addTextLayoutManager(textLayoutManager)
        textLayoutManager.textContainer = textContainer
        
        let textView = MarkdownEditor(
            frame: containerSize,
            configuration: configuration,
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

        textView.updateMarkdownStyling()
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
        
        textView.updateMarkdownStyling()
        textView.editorHeight = textView.calculateEditorHeight()
        
        if textView.string != self.text {
            textView.string = self.text
//            textView.updateMarkdownStyling()
//            textView.editorHeight = textView.calculateEditorHeight()

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

     
        
    } // END update nsView
    
    
    /// It is the Coordinator that is responsible for sending information back **to** SwiftUI, from the NSView
    public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    public class Coordinator: NSObject, NSTextViewDelegate {
        
        var parent: MarkdownEditorRepresentable
        weak var textContentStorage: NSTextContentStorage?
//        weak var editor: MarkdownEditor?
        
        
        var lastKnownWidth: CGFloat = 0

        public init(_ parent: MarkdownEditorRepresentable) {
            self.parent = parent
//            super.init()
        }
        
        
        /// Try `scrollRangeToVisible_` for when scroll jumps to top when pasting
        public func textDidChange(_ notification: Notification) {
            
            guard let textView = notification.object as? MarkdownEditor else { return }
            
            if self.parent.text != textView.string {
                self.parent.text = textView.string
                textView.updateMarkdownStyling()
                
                
                
                self.parent.sendOutSize(for: textView)
//                self.parent.sendOutSize(for: textView, withMessage: "Updated text")
                
            }  // END text equality check
            //
        } // END Text did change
        
        
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
                """
                
                Height: \(textView.editorHeight)
                Editor metrics: \(textView.editorMetrics)
                """,
                textView.editorHeight + (MarkdownDefaults.paddingY * 4))
        }

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
