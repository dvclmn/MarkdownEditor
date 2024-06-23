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

@MainActor
public struct MarkdownEditorRepresentable: NSViewRepresentable {
    
    @Binding public var text: String
    @Binding public var editorHeight: CGFloat
    @Binding public var isShowingFrames: Bool
    @Binding public var isLoading: Bool
    
    public var editorHeightTypingBuffer: CGFloat
    public var inlineCodeColour: Color
    
    public var isEditable: Bool
    public var isEditorResizing: Bool
    
    public var fontSize: Double
    
    private let verticalPadding: Double = 30
    
    @State private var previousWidth: Double = 0
    
    @State private var needsDisplayTimer: Timer?
    @State private var needsDisplayFlag = false
    
    public init(
        text: Binding<String>,
        editorHeight: Binding<CGFloat>,
        isShowingFrames: Binding<Bool> = .constant(false),
        isLoading: Binding<Bool> = .constant(false),
        
        editorHeightTypingBuffer: CGFloat = 120,
        inlineCodeColour: Color = .purple,
        
        isEditable: Bool = true,
        isEditorResizing: Bool = false,
        fontSize: Double = 15
    ) {
        self._text = text
        self._editorHeight = editorHeight
        self._isShowingFrames = isShowingFrames
        self._isLoading = isLoading
        
        self.editorHeightTypingBuffer = editorHeightTypingBuffer
        self.inlineCodeColour = inlineCodeColour
        
        self.isEditable = isEditable
        self.isEditorResizing = isEditorResizing
        self.fontSize = fontSize
    }
    
    /// This function creates the NSView and configures its initial state
    public func makeNSView(context: Context) -> MarkdownEditor {
        
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
        
        if textView.string != text {
            DispatchQueue.main.async {
                textView.string = text
                redrawEditor()
            }
        }
        
        if textView.editorHeight != self.editorHeight {
            DispatchQueue.main.async {
                redrawEditor()
            } // END dispatch queue
        } // END editor height changed check
        
        if textView.isShowingFrames != self.isShowingFrames {
            textView.isShowingFrames = self.isShowingFrames
            redrawEditor()
        }
        
        if textView.isEditable != isEditable {
            textView.isEditable = isEditable
        }
        
        let currentWidth = textView.bounds.width
        
        if previousWidth != currentWidth {
            DispatchQueue.main.async {
                previousWidth = currentWidth
                redrawEditor()
            }
        }
        
        func redrawEditor() {
            if !self.isEditorResizing {
                textView.applyStyles()
                self.editorHeight = textView.editorHeight
                textView.invalidateIntrinsicContentSize()
                textView.needsDisplay = true
            }
        }
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
        
        /// When the text field has an attributed string value, the system ignores the textColor, font, alignment, lineBreakMode, and lineBreakStrategy properties. Set the foregroundColor, font, alignment, lineBreakMode, and lineBreakStrategy properties in the attributed string instead.
        textView.font = NSFont.systemFont(ofSize: MarkdownDefaults.fontSize, weight: .medium)
        textView.textColor = NSColor.textColor.withAlphaComponent(MarkdownDefaults.fontOpacity)
        
        textView.isEditable = self.isEditable
        
        textView.drawsBackground = false
        textView.allowsUndo = true
        textView.setNeedsDisplay(textView.bounds)
    }
    
}

struct MarkdownExampleView: View {
    
    @State private var text: String = ExampleText.smallCodeBlock
    @State private var editorHeight: CGFloat = 0
    
    @FocusState private var isFocused
    
    var body: some View {
        
        ScrollView {
            MarkdownEditorRepresentable(
                text: $text,
                editorHeight: $editorHeight,
                editorHeightTypingBuffer: 60,
                inlineCodeColour: .cyan
            )
        }
        .border(Color.green.opacity(0.2))
        .background(.green.opacity(0.3))
    }
}
#Preview {
    MarkdownExampleView()
        .frame(width: 600, height: 700)
}

