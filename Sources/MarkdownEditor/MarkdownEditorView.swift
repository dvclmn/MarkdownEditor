//
//  MarkdownEditor.swift
//  Banksia
//
//  Created by Dave Coleman on 17/4/2024.
//

import Foundation
import SwiftUI
import ExampleText
import OSLog
//import GeneralUtilities
//import GeneralStyles

@MainActor
public protocol Markdownable {
    var userPrompt: String { get set }
}

@MainActor
public struct MarkdownEditorRepresentable: NSViewRepresentable {
    
    @Binding public var text: String
    @Binding public var editorHeight: CGFloat
    @Binding public var isShowingFrames: Bool
    
    public var editorMaxHeight: CGFloat?
    
    public var editorHeightTypingBuffer: CGFloat
    public var inlineCodeColour: Color
    
    public var isEditable: Bool
    
    public var fontSize: Double
    
    private let verticalPadding: Double = 30
    
    @State private var previousWidth: Double = 0
    
    @State private var needsDisplayTimer: Timer?
    @State private var needsDisplayFlag = false
    
    
    public init(
        text: Binding<String>,
        editorHeight: Binding<CGFloat>,
        isShowingFrames: Binding<Bool> = .constant(false),
        
        editorMaxHeight: CGFloat? = nil,
        
        editorHeightTypingBuffer: CGFloat = 120,
        inlineCodeColour: Color = .purple,
        
        isEditable: Bool = true,
        fontSize: Double = 15
    ) {
        self._text = text
        self._editorHeight = editorHeight
        self._isShowingFrames = isShowingFrames
        
        self.editorMaxHeight = editorMaxHeight
        
        self.editorHeightTypingBuffer = editorHeightTypingBuffer
        self.inlineCodeColour = inlineCodeColour
        
        self.isEditable = isEditable
        self.fontSize = fontSize
    }
    
    /// This function creates the NSView and configures its initial state
    public func makeNSView(context: Context) -> MarkdownEditor {
        
        os_log("`makeNSView` was called")
        
        let textView = MarkdownEditor(
            frame: .zero,
            editorHeight: editorHeight,
            editorMaxHeight: editorMaxHeight,
            editorHeightTypingBuffer: editorHeightTypingBuffer,
            inlineCodeColour: inlineCodeColour,
            isShowingFrames: isShowingFrames
        )
        
        textView.delegate = context.coordinator
        textView.string = text
        
        setUpTextViewOptions(for: textView)
        
        DispatchQueue.main.async {
            textView.applyStyles()
            self.editorHeight = textView.editorHeight
        }
        
        return textView
    }
    
    /// This function is to communicate updates **from** SwiftUI, back **to** the NSView
    /// It is not for sending updates back up to SwiftUI
    /// This *will* update any time a `@Binding` property is mutated from SwiftUI
    public func updateNSView(_ textView: MarkdownEditor, context: Context) {
        
        //        os_log("`updateNSView` was called")
        
        
        if textView.editorHeight != self.editorHeight {
            DispatchQueue.main.async {
                
                // TODO: These changes caused the editor height to *not* change, when sending a message, and the Messages to not update their height when the GPT response is streamed in
                
                //                textView.applyStyles()
                
                //                os_log("PRE-UPDATE: `updateNSView` editor height from SwiftUI: \(self.editorHeight), editor height from nstextview: \(textView.editorHeight)")
                
                self.editorHeight = textView.editorHeight
                
                //                os_log("NOW UPDATED: `updateNSView` editor height from SwiftUI: \(self.editorHeight), editor height from nstextview: \(textView.editorHeight)")
                
                textView.invalidateIntrinsicContentSize()
                
                
                //                textView.needsDisplay = true
            } // END dispatch queue
            
            
            Task { @MainActor in
                self.needsDisplayFlag = true
                
                // If the timer is not already running, start it
                if self.needsDisplayTimer == nil {
                    self.needsDisplayTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                        Task { @MainActor in
                            if self.needsDisplayFlag {
                                textView.needsDisplay = true
                                self.needsDisplayFlag = false
                            }
                            self.needsDisplayTimer = nil
                        }
                    }
                }
            }
            
            
        } // END editor height changed check
        
        if textView.string != text {
            
            DispatchQueue.main.async {
                textView.string = text
                self.editorHeight = textView.editorHeight
                textView.invalidateIntrinsicContentSize()
            }
        }
        
        
        
        if textView.isShowingFrames != self.isShowingFrames {
            /// Interestingly, this little bit of code does *not* work, without the `needsDisplay` call
            textView.isShowingFrames = self.isShowingFrames
            os_log("MDE showing frames?: `\(textView.isShowingFrames)`")
            textView.needsDisplay = true
        }
        
        if textView.isEditable != isEditable {
            textView.isEditable = isEditable
        }
        
        let currentWidth = textView.bounds.width
        
        if previousWidth != currentWidth {
            DispatchQueue.main.async {
                previousWidth = currentWidth
                textView.applyStyles()
                self.editorHeight = textView.editorHeight
                textView.needsDisplay = true
            }
        }
        
        textView.needsLayout = true
        
    } // END update nsView
    
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
            
            os_log("`textDidBeginEditing` was called")
            
            self.parent.text = textView.string
        }
        
        public func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? MarkdownEditor else { return }
            
            //            os_log("`textDidChange` was called")
            
            DispatchQueue.main.async {
                
                if self.parent.text != textView.string {
                    
                    /// FROM nstextview, to SwiftUI
                    self.parent.text = textView.string
                    
                    self.parent.editorHeight = textView.editorHeight
                    textView.applyStyles()
                    
                    //                    os_log("PRE-UPDATE:`textDidChange` editor height from SwiftUI: \(self.parent.editorHeight), editor height from nstextview: \(textView.editorHeight)")
                    
                    
                    //                    os_log("NOW UPDATED: `textDidChange` editor height from SwiftUI: \(self.parent.editorHeight), editor height from nstextview: \(textView.editorHeight)")
                    
                    //                    textView.needsDisplay = true
                }
            } // END dispatch async
            
        } // END Text did change
        
        //        public func textViewDidChangeSelection(_ notification: Notification) {
        //            guard let textView = notification.object as? MarkdownEditor else { return }
        
        //            DispatchQueue.main.async {
        //                textView.needsDisplay = true
        //            }
        //        }
        
        
        
        
    }
} // END NSViewRepresentable



extension MarkdownEditorRepresentable {
    
    private func setUpTextViewOptions(for textView: MarkdownEditor) {
        
        textView.isVerticallyResizable = false
        
        textView.textContainer?.containerSize = CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.heightTracksTextView = false
        
        textView.isAutomaticSpellingCorrectionEnabled = true
        textView.isAutomaticTextCompletionEnabled = true
        
        textView.textContainer?.lineFragmentPadding = 34
        textView.textContainerInset = NSSize(width: 0, height: 30)
        
        textView.font = NSFont.systemFont(ofSize: fontSize)
        
        textView.isEditable = self.isEditable
        
        textView.drawsBackground = false
        textView.allowsUndo = true
        textView.setNeedsDisplay(textView.bounds)
    }
    
}

//
//extension MarkdownEditorRepresentable.Coordinator {
//
//    @MainActor func wrapSelectedTextWithAsterisks(textView: MarkdownEditor) {
//
//        guard let textRange = textView.selectedRanges.first as? NSRange, textRange.length > 0 else {
//            print("No text is selected")
//            return
//        }
//
//        guard let textStorage = textView.textStorage else {
//            print("Couldn't get text storage")
//            return
//        }
//
//        let selectedText = textStorage.attributedSubstring(from: textRange).string
//
//        let wrappedText = "*\(selectedText)*"
//
//        textStorage.replaceCharacters(in: textRange, with: wrappedText)
//
//        let newRange = NSRange(location: textRange.location, length: textRange.length + 2)
//
//        textView.setSelectedRange(newRange)
//        parent.handler.userPrompt = textView.string
//
//    }
//}


struct MarkdownExampleView: View {
    
    @State private var text: String = ExampleText.smallCodeBlock
    @State private var editorHeight: CGFloat = 0
    
    @FocusState private var isFocused
    
    var body: some View {
        
        ScrollView {
            MarkdownEditorRepresentable(
                text: $text,
                editorHeight: $editorHeight,
                editorMaxHeight: 400,
                editorHeightTypingBuffer: 60,
                inlineCodeColour: .cyan
                //                isFocused: true
            )
        }
        .border(Color.green.opacity(0.2))
    }
}
#Preview {
    MarkdownExampleView()
        .frame(width: 600, height: 700)
}

