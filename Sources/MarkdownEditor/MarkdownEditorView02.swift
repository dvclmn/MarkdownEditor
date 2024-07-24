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
    @Binding var height: CGFloat
    
    public var isEditable: Bool
    
    public init(
        text: Binding<String>,
        height: Binding<CGFloat>,
        isEditable: Bool = true
    ) {
        self._text = text
        self._height = height
        self.isEditable = isEditable
    }
    
    public func makeNSView(context: Context) -> AutoGrowingTextView {
        
        let textStorage = NSTextStorage()
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer()
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        let textView = AutoGrowingTextView(frame: .zero, heightChangeHandler: nil)
        
//        textView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.delegate = context.coordinator
        
        textView.textContainer?.containerSize = CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)
        
        
        textView.isRichText = false
        textView.isEditable = self.isEditable
        textView.isSelectable = true
        textView.drawsBackground = false
        textView.allowsUndo = true
        
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        
        textView.textColor = .white
        textView.font = MarkdownDefaults.defaultFont
        textView.textContainer?.lineFragmentPadding = 30
        textView.textContainerInset = NSSize(width: 0, height: 30)
        
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.heightTracksTextView = false
        
        textView.heightChangeHandler = { newHeight in
            DispatchQueue.main.async {
                self.height = newHeight
            }
        }
        
        textView.setNeedsDisplay(textView.bounds)
        
        
        
        return textView
    }
    
    public func updateNSView(_ textView: AutoGrowingTextView, context: Context) {
        
        
        if textView.string != self.text {
            let selectedRanges = textView.selectedRanges
            textView.string = self.text
            textView.selectedRanges = selectedRanges
            context.coordinator.applyMarkdownStyling(to: textView)
            
            DispatchQueue.main.async {
                self.height = textView.intrinsicContentSize.height
            }
        }
        
        // Check if the width has changed significantly
        //        let currentWidth = textView.frame.width
        //        if abs(currentWidth - context.coordinator.lastKnownWidth) > 10 { // 10 points threshold
        //            context.coordinator.lastKnownWidth = currentWidth
        //            context.coordinator.applyMarkdownStyling(to: textView)
        //        }
        
        
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MarkdownTextView
        
        init(_ parent: MarkdownTextView) {
            self.parent = parent
        }
        
        //        var lastKnownWidth: CGFloat = 0
        
        public func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? AutoGrowingTextView else { return }
            parent.text = textView.string
            applyMarkdownStyling(to: textView)
        }
        
        @MainActor
        func applyMarkdownStyling(to textView: AutoGrowingTextView) {
            
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



@MainActor
public class AutoGrowingTextView: NSTextView {
    var heightChangeHandler: ((CGFloat) -> Void)?
    
    public init(
        frame frameRect: NSRect,
        heightChangeHandler: ((CGFloat) -> Void)? = nil
    ) {

        let textStorage = NSTextStorage()
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize(width: frameRect.width, height: CGFloat.greatestFiniteMagnitude))
        
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        super.init(frame: frameRect, textContainer: textContainer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var intrinsicContentSize: NSSize {
        
        guard let layoutManager = self.layoutManager, let container = self.textContainer else {
            return super.intrinsicContentSize
        }
        
        container.containerSize = NSSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        layoutManager.ensureLayout(for: container)
        
        let rect = layoutManager.usedRect(for: container).size
        
        return rect
    }
    
    public override func didChangeText() {
        super.didChangeText()
        invalidateIntrinsicContentSize()
        let height = intrinsicContentSize.height
        heightChangeHandler?(height)
    }
}
