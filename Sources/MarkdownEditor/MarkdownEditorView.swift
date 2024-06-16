//
//  MarkdownEditor.swift
//  Banksia
//
//  Created by Dave Coleman on 17/4/2024.
//

import Foundation
import SwiftUI
import ExampleText
//import GeneralUtilities
//import GeneralStyles

public protocol Markdownable {
    var userPrompt: String { get set }
}

@MainActor
public struct MarkdownEditorRepresentable: NSViewRepresentable {
    
    @Binding public var text: String
    @Binding public var editorHeight: CGFloat
    
    public var inlineCodeColour: Color
    
    public var isFocused: Bool
    
    public var isEditable: Bool
    
    public var isShowingFrames: Bool
    public var fontSize: Double
    
    private let verticalPadding: Double = 30
    
    @State private var previousWidth: Double = 0
    
    public init(
        text: Binding<String>,
        editorHeight: Binding<CGFloat>,
        inlineCodeColour: Color,
        isFocused: Bool = false,
        
        isEditable: Bool = true,
        isShowingFrames: Bool = false,
        fontSize: Double = 15
    ) {
        self._text = text
        self._editorHeight = editorHeight
        self.inlineCodeColour = inlineCodeColour
        
        self.isFocused = isFocused
        
        self.isEditable = isEditable
        self.isShowingFrames = isShowingFrames
        self.fontSize = fontSize
    }
    
    /// This function creates the NSView and configures its initial state
    public func makeNSView(context: Context) -> MarkdownEditor {
        
        let textView = MarkdownEditor(
            frame: .zero,
            editorHeight: editorHeight,
            inlineCodeColour: inlineCodeColour,
            isShowingFrames: isShowingFrames
        )
        textView.delegate = context.coordinator
        textView.string = text
        
        setUpTextViewOptions(for: textView)
        textView.applyStyles()

        
        if isFocused {
            textView.window?.makeFirstResponder(textView)
        }

        DispatchQueue.main.async {
            self.editorHeight = textView.editorHeight
        }
        
        return textView
    }
    
    /// This function is to communicate updates **from** SwiftUI, back **to** the NSView
    /// It is not for sending updates back up to SwiftUI
    public func updateNSView(_ textView: MarkdownEditor, context: Context) {
        
        textView.needsLayout = true
        
        if textView.string != text {
            textView.string = text
            
            DispatchQueue.main.async {
                textView.applyStyles()
                self.editorHeight = textView.editorHeight
            }
        }
            
        if textView.isEditable != isEditable {
            textView.isEditable = isEditable
        }
        
        let currentWidth = textView.bounds.width
        
        if previousWidth != currentWidth {
            
            textView.needsDisplay = true

            DispatchQueue.main.async {
                previousWidth = currentWidth
                textView.applyStyles()
                self.editorHeight = textView.editorHeight
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
            
            self.parent.text = textView.string
            
            
        }
        
        
        public func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? MarkdownEditor else { return }
            
            DispatchQueue.main.async {
                if self.parent.text != textView.string {
                    self.parent.text = textView.string
                    textView.applyStyles()
                    self.parent.editorHeight = textView.editorHeight
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
                inlineCodeColour: .cyan,
                isFocused: true
            )
        }
        .border(Color.green.opacity(0.2))
    }
}
#Preview {
    MarkdownExampleView()
        .frame(width: 600, height: 700)
}

