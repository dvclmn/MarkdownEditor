//
//  MarkdownEditorView02.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 24/7/2024.
//

import SwiftUI

@MainActor
public struct MarkdownTextView: NSViewRepresentable {
    @Binding var text: String
    
    public init(
        text: Binding<String>
    ) {
        self._text = text
    }
    
    public func makeNSView(context: Context) -> NSTextView {
        
        let textStorage = NSTextStorage()
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer()
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        let textView = NSTextView(frame: .zero, textContainer: textContainer)
        textView.isRichText = true
        textView.isEditable = true
        textView.isSelectable = true
        textView.drawsBackground = false
        textView.allowsUndo = true
        
        textView.translatesAutoresizingMaskIntoConstraints = true
        
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.autoresizingMask = [.width]

        textView.textColor = .white
        textView.font = MarkdownDefaults.defaultFont
        
        textContainer.widthTracksTextView = true
        textContainer.heightTracksTextView = false
        
        
        textView.delegate = context.coordinator
        
        return textView
    }
    
    public func updateNSView(_ textView: NSTextView, context: Context) {
        

        if textView.string != text {
            let selectedRanges = textView.selectedRanges
            textView.string = text
            textView.selectedRanges = selectedRanges
            context.coordinator.applyMarkdownStyling(to: textView)
        }
        
        // Check if the width has changed significantly
        let currentWidth = textView.frame.width
        if abs(currentWidth - context.coordinator.lastKnownWidth) > 10 { // 10 points threshold
            context.coordinator.lastKnownWidth = currentWidth
            context.coordinator.applyMarkdownStyling(to: textView)
        }
        
        
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MarkdownTextView
        
        init(_ parent: MarkdownTextView) {
            self.parent = parent
        }
        
        var lastKnownWidth: CGFloat = 0
        
        public func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
            applyMarkdownStyling(to: textView)
        }
        
        @MainActor
        func applyMarkdownStyling(to textView: NSTextView) {
            
            guard let textStorage = textView.textStorage else { return }
            
            let fullRange = NSRange(location: 0, length: textStorage.length)
            let text = textStorage.string
            
            // Store the current selection
            let selectedRanges = textView.selectedRanges
            
            // Remove all existing styles
            textStorage.removeAttribute(.font, range: fullRange)
            textStorage.removeAttribute(.foregroundColor, range: fullRange)
            
            // Apply default style
            textStorage.addAttribute(.font, value: NSFont.systemFont(ofSize: 14), range: fullRange)
            textStorage.addAttribute(.foregroundColor, value: NSColor.textColor, range: fullRange)
            
            // Apply bold styling
            let boldPattern = try! NSRegularExpression(pattern: "\\*\\*(.+?)\\*\\*")
            boldPattern.enumerateMatches(in: text, range: fullRange) { match, _, _ in
                if let matchRange = match?.range(at: 1) {
                    textStorage.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: 14), range: matchRange)
                    textStorage.addAttribute(.foregroundColor, value: NSColor.orange, range: matchRange)
                }
            }
            
            // Apply inline code styling
            let codePattern = try! NSRegularExpression(pattern: "`(.+?)`")
            codePattern.enumerateMatches(in: text, range: fullRange) { match, _, _ in
                if let matchRange = match?.range(at: 1) {
                    textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 14, weight: .regular), range: matchRange)
                    textStorage.addAttribute(.foregroundColor, value: NSColor.systemRed, range: matchRange)
                }
            }
            
            // Restore the selection
            textView.selectedRanges = selectedRanges
        }
    }
}
