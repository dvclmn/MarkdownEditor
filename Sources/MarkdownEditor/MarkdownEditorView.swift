//
//  MarkdownEditor.swift
//  Banksia
//
//  Created by Dave Coleman on 17/4/2024.
//

import Foundation
import SwiftUI
import GeneralUtilities
import GeneralStyles

public protocol Markdownable {
    var userPrompt: String { get set }
}

@MainActor
public struct MarkdownEditorRepresentable: NSViewRepresentable {
    
    @Binding public var text: String
    
    public var isFocused: Bool
    
    public var isEditable: Bool
    
    public var fontSize: Double
    
    public var height: (Double) -> Void
    
    private let verticalPadding: Double = 30
    
    @State private var previousWidth: Double = 0
    
    public init(
        text: Binding<String>,
        isFocused: Bool = false,
        
        isEditable: Bool = true,
        fontSize: Double = 15,
        
        height: @escaping (Double) -> Void
    ) {
        self._text = text
        
        self.isFocused = isFocused
        
        self.isEditable = isEditable
        self.fontSize = fontSize
        
        self.height = height
    }
    
    
    public func makeNSView(context: Context) -> MarkdownEditor {
        
        let textView = MarkdownEditor()
        
        textView.textBinding = $text
        
        textView.delegate = context.coordinator
        
        textView.string = text
        
        textView.positionButtons()
        
        setUpTextViewOptions(for: textView)
        
        textView.invalidateIntrinsicContentSize()
        
        height(textView.height)
        
        textView.applyStyles()
        
        if isFocused {
            textView.window?.makeFirstResponder(textView)
        }
        
        return textView
    }
    
    public func updateNSView(_ textView: MarkdownEditor, context: Context) {
        
        textView.needsLayout = true
        
        if textView.string != text {
            textView.string = text
            textView.applyStyles()
            textView.positionButtons()
        }
        
        if textView.isEditable != isEditable {
            textView.isEditable = isEditable
        }
        
        let currentWidth = textView.bounds.width
        
        if previousWidth != currentWidth {
            DispatchQueue.main.async {
                previousWidth = currentWidth

                textView.invalidateIntrinsicContentSize()
                textView.needsDisplay = true
                
            }
        }
    } // END update nsView
    
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    public class Coordinator: NSObject, NSTextViewDelegate {
        
        var parent: MarkdownEditorRepresentable
        var copyButtons = [NSButton]()
        
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
                self.parent.text = textView.string
                
                textView.needsDisplay = true
                
                self.parent.height(textView.height)
                
                textView.applyStyles()
                textView.invalidateIntrinsicContentSize()
                //                textView.updateHeight()
            }
            
        } // END Text did change
        
        public func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? MarkdownEditor else { return }
            DispatchQueue.main.async {
                textView.needsDisplay = true
            }
        }
        
        
        
        
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

        textView.textContainer?.lineFragmentPadding = Styles.paddingSomething
        
        textView.font = NSFont.systemFont(ofSize: fontSize)
        textView.isEditable = isEditable
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


//struct MarkdownExampleView: View {
//
//    @State private var text: String = ExampleText.paragraphs[3]
//    @State private var editorHeight: Double = 300
//
//    @FocusState private var isFocused
//
//    var body: some View {
//
//        ScrollView {
//            MarkdownEditorRepresentable(
//                text: $text,
//                editorHeight: $editorHeight,
//                isFocused: $isFocused
//            )
//        }
//        .border(Color.green.opacity(0.2))
//    }
//}
//#Preview {
//    MarkdownExampleView()
//        .frame(width: 600, height: 300)
//}

