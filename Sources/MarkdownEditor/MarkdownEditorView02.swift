//
//  MarkdownEditorView02.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 24/7/2024.
//

import SwiftUI

struct MarkdownTextView: NSViewRepresentable {
    @Binding var text: String
    
    @MainActor func makeNSView(context: Context) -> NSScrollView {
        
        let textView = NSTextView()
        textView.isRichText = false
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.drawsBackground = false
        
        textView.textColor = .white
        textView.font = MarkdownDefaults.defaultFont
        
        textView.autoresizingMask = [.width]
        textView.translatesAutoresizingMaskIntoConstraints = true
        
        //        textView.textContainer?.containerSize = CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)
        
        //        textView.textContainer?.widthTracksTextView = true
        textView.delegate = context.coordinator
        
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false
        
        scrollView.documentView = textView
        
        textView.minSize = NSSize(width: 0, height: scrollView.bounds.height)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.frame = scrollView.bounds
        
        styleText(for: textView)
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        if textView.string != self.text {
            styleText(for: textView)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MarkdownTextView
        
        init(_ parent: MarkdownTextView) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }
    }
}

extension MarkdownTextView {
    
    @MainActor
    func styleText(for textView: NSTextView) {
        
        let selectedRanges = textView.selectedRanges
        
        let attributedString = NSAttributedString(string: self.text)
        
        
        
        try? NSAttributedString(markdown: text, options: .init(allowsExtendedAttributes: true, interpretedSyntax: .full, failurePolicy: .returnPartiallyParsedIfPossible))
        
        textView.textStorage?.setAttributedString(attributedString ?? NSAttributedString(string: text))
        textView.selectedRanges = selectedRanges
        
        
//                        textView.string = text
        //
        //            do {
        //                let thankYouString = try AttributedString(
        //                    markdown:"**Thank you!** Please visit our [website](https://example.com)")
        //            } catch {
        //                print("Couldn't parse the string. \(error.localizedDescription)")
        //            }
        //
        //
        
        
        //            let attributedString = try? NSAttributedString(markdown: text)
        //            textView.textStorage?.setAttributedString(attributedString ?? NSAttributedString(string: text))
    }
}
