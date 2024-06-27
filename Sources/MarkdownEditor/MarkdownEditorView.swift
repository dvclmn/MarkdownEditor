//
//  MarkdownEditor.swift
//  Banksia
//
//  Created by Dave Coleman on 17/4/2024.
//

import Foundation
import SwiftUI
import OSLog
import AsyncAlgorithms

@MainActor
public struct MarkdownEditorRepresentable: NSViewRepresentable {
    
    @Binding public var text: String
    @Binding public var editorHeight: CGFloat
    public var id: String
    public var didAppear: Bool
    public var editorWidth: CGFloat?
    
    @Binding public var isShowingFrames: Bool
    
    public var editorHeightTypingBuffer: CGFloat
    public var inlineCodeColour: Color
    
    public var isEditable: Bool
    
    public var fontSize: Double
    
    var isLoading: (Bool) -> Void
    var onCaretPositionChange: ((NSRect) -> Void)?

    private let padding: Double = 30
    
    @State private var debounceTask: Task<Void, Error>?
    
    public init(
        text: Binding<String>,
        editorHeight: Binding<CGFloat>,
        id: String,
        didAppear: Bool = false,
        editorWidth: CGFloat? = nil,
        
        isShowingFrames: Binding<Bool> = .constant(false),
        
        editorHeightTypingBuffer: CGFloat = 120,
        inlineCodeColour: Color = .purple,
        
        
        isEditable: Bool = true,
        fontSize: Double = 15,
        
        isLoading: @escaping (Bool) -> Void,
        onCaretPositionChange: ((NSRect) -> Void)? = nil
        
    ) {
        self._text = text
        self._editorHeight = editorHeight
        self.id = id
        self.didAppear = didAppear
        self.editorWidth = editorWidth
        self._isShowingFrames = isShowingFrames
        
        self.editorHeightTypingBuffer = editorHeightTypingBuffer
        self.inlineCodeColour = inlineCodeColour
        
        
        self.isEditable = isEditable
        self.fontSize = fontSize
        
        self.isLoading = isLoading
        self.onCaretPositionChange = onCaretPositionChange
    }
    
    /// This function creates the NSView and configures its initial state
    public func makeNSView(context: Context) -> MarkdownEditor {
        
        self.isLoading(true)
        //        Task { @MainActor in
        //            self.startedLoadingTime = Date.now
        //        }
        //        os_log("`makeNSView`: `self.isLoading(true)`")
        
        let textView = MarkdownEditor(
            frame: .zero,
            editorHeight: editorHeight,
            editorHeightTypingBuffer: editorHeightTypingBuffer,
            inlineCodeColour: inlineCodeColour,
            isShowingFrames: isShowingFrames
        )
        
        textView.delegate = context.coordinator
        textView.string = text
        
        setUpTextViewOptions(for: textView)
        
        //        os_log("`makeNSView`: Performed all setup *except* for expensive `setUpTextView(for: textView)`")
        
        Task {
            await setUpTextView(for: textView)
        }
        
        //        os_log("`makeNSView`: Now, performed *all* setup")
        
        self.isLoading(false)
        //        Task { @MainActor in
        //            self.finishedLoadingTime = Date.now
        //        }
        //        os_log("`makeNSView`: `self.isLoading(false)`")
        //        os_log("Total loading time for ID `\(self.id)`: \(differenceInMilliseconds(from: startedLoadingTime, to: finishedLoadingTime))")
        
        return textView
        
    }
    
    
    //    private func differenceInMilliseconds(from date1: Date, to date2: Date) -> Int {
    //        let differenceInSeconds = Int(date2.timeIntervalSince(date1))
    //        return differenceInSeconds * 1000
    //    }
    
    /// This function is to communicate updates **from** SwiftUI, back **to** the NSView
    /// It is not for sending updates back up to SwiftUI
    /// This *will* update any time a `@Binding` property is mutated from SwiftUI
    public func updateNSView(_ textView: MarkdownEditor, context: Context) {
        

        /// Had the idea to add the 'text is the same' part, so this gets called less often
        if textView.editorHeight != self.editorHeight && textView.string == self.text {
            Task {
                await setUpTextView(for: textView)
            }
        }
        
        

        /// The below two statements are called a billion times a second, on SwiftUI ScrollView scroll!
        /// I think I will need to make sure anything in this function, is *ONLY* called if neccesary
        //        os_log("`updateNSView` > MDE width for ID `\(self.id)`: \(textView.bounds.width)")
        
        if textView.isEditable != self.isEditable {
            textView.isEditable = self.isEditable
        }
        
        
        if textView.string != self.text && self.isEditable {
            textView.string = text
            Task {
                await setUpTextView(for: textView)
            }
            
        }
        
        if textView.isShowingFrames != self.isShowingFrames {
            textView.isShowingFrames = self.isShowingFrames
            Task {
                await setUpTextView(for: textView)
            }
        }
        
        
        /// NOTE: This value changes a LOT, so debounce it, or avoid tying expensive operations to it
//        if textView.bounds.width != editorWidth {
//            
//            Task {
//                await redrawWidth(for: textView)
//            }
//        }
        
        
        //            os_log("--- END: `updateNSView > if self.isEditable {` ---\n\n\n")
        
        
        
    } // END update nsView
    
    func dismantleNSView(_ textView: MarkdownEditor, context: Context) {
        debounceTask?.cancel()
    }
    
    private func redrawWidth(for textView: MarkdownEditor) async {
        
        await MainActor.run {
            
            debounceTask?.cancel()
            debounceTask = Task {
                do {
//                    os_log("Let's wait for 2 seconds before adjust instrinsic size and height")
                    try await Task.sleep(for: .seconds(2))
                    if !Task.isCancelled {
                        os_log("Waited 2 seconds. Now adjusting")
                        textView.applyStyles()
                    }
                } catch {}
            }
            
        }
    }
    
    private func setUpTextView(for textView: MarkdownEditor) async {
        await MainActor.run {
            textView.applyStyles()
            self.editorHeight = textView.editorHeight
        }
    }
    
    
    /// It is the Coordinator that is responsible for sending information back **to** SwiftUI, from the NSView
    public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    public class Coordinator: NSObject, NSTextViewDelegate {
        
        var parent: MarkdownEditorRepresentable
        
        public init(_ parent: MarkdownEditorRepresentable) {
            self.parent = parent
            super.init()
        }
        
        public func textDidBeginEditing(_ notification: Notification) {
            guard let textView = notification.object as? MarkdownEditor else { return }
            
            if self.parent.text != textView.string {
                DispatchQueue.main.async {
                    self.parent.text = textView.string
                }
            }
        }
        
        public func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? MarkdownEditor else { return }
            
            
            if self.parent.text != textView.string {
                
                DispatchQueue.main.async {
                    if self.parent.text != textView.string {
                        self.parent.text = textView.string
                        textView.applyStyles()
                        self.parent.editorHeight = textView.editorHeight
                        textView.invalidateIntrinsicContentSize()
                        textView.needsDisplay = true
                    }
                } // END dispatch async
            } // END text equality check
            
        } // END Text did change
        
        public func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? MarkdownEditor else { return }
            
            DispatchQueue.main.async {
                let caretRect = textView.layoutManager?.boundingRect(forGlyphRange: textView.selectedRange(), in: textView.textContainer!)
                if let caretRect = caretRect {
                    print("Caret position? `\(caretRect)`")
                    self.parent.onCaretPositionChange?(caretRect)
                }
            }

            
        }
        
    }
} // END NSViewRepresentable



extension MarkdownEditorRepresentable {
    
    private func setUpTextViewOptions(for textView: MarkdownEditor) {
        
        textView.isVerticallyResizable = false
        
        textView.textContainer?.containerSize = CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)
        
        /// If this is set to false, then the text tends to be allowed to run off the right edge,
        /// and less width-related calculations seem to be neccesary
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.heightTracksTextView = false
        
        textView.isAutomaticSpellingCorrectionEnabled = true
        textView.isAutomaticTextCompletionEnabled = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = true
        
        textView.isRichText = false
        textView.importsGraphics = false
        
        textView.insertionPointColor = .purple
        
        textView.smartInsertDeleteEnabled = true
        
        textView.usesFindBar = true

        
        textView.textContainer?.lineFragmentPadding = padding
        textView.textContainerInset = NSSize(width: 0, height: padding)
        
        /// When the text field has an attributed string value, the system ignores the textColor, font, alignment, lineBreakMode, and lineBreakStrategy properties. Set the foregroundColor, font, alignment, lineBreakMode, and lineBreakStrategy properties in the attributed string instead.
        textView.font = NSFont.systemFont(ofSize: MarkdownDefaults.fontSize, weight: .medium)
        textView.textColor = NSColor.textColor.withAlphaComponent(MarkdownDefaults.fontOpacity)
        
        textView.isEditable = self.isEditable
        
        textView.drawsBackground = false
        textView.allowsUndo = true
        textView.setNeedsDisplay(textView.bounds)
    }
    
}

