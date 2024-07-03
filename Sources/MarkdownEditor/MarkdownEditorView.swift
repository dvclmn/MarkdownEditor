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

public struct MarkdownEditorConfiguration {
    public var fontSize: Double
    public var insertionPointColour: Color
    public var defaultCodeColour: Color
    public var paddingX: Double
    public var paddingY: Double
    
    public init(fontSize: Double, insertionPointColour: Color, defaultCodeColour: Color, paddingX: Double, paddingY: Double) {
        self.fontSize = fontSize
        self.insertionPointColour = insertionPointColour
        self.defaultCodeColour = defaultCodeColour
        self.paddingX = paddingX
        self.paddingY = paddingY
    }
}

@MainActor
public struct MarkdownEditorRepresentable: NSViewRepresentable {
    
    @Binding public var text: String
    
    public var configuration: MarkdownEditorConfiguration?
    
    public var id: String?
    public var didAppear: Bool
    public var editorWidth: CGFloat?
    
    public var isShowingFrames: Bool
    
    public var isEditable: Bool
    
        var output: (_ editorHeight: CGFloat) -> Void
    
    private let isPrinting: Bool = true
    
    @State private var debounceTask: Task<Void, Error>?
    
    public init(
        text: Binding<String>,
        configuration: MarkdownEditorConfiguration? = nil,
        id: String? = nil,
        didAppear: Bool = false,
        editorWidth: CGFloat? = nil,
        
        isShowingFrames: Bool = false,
        
        isEditable: Bool = true,
        
                output: @escaping (_ editorHeight: CGFloat) -> Void = {_ in}
        
    ) {
        self._text = text
        self.configuration = configuration
        self.id = id
        self.didAppear = didAppear
        self.editorWidth = editorWidth
        self.isShowingFrames = isShowingFrames
        
        self.isEditable = isEditable
        self.output = output
    }
    
    /// This function creates the NSView and configures its initial state
    public func makeNSView(context: Context) -> MarkdownEditor {
        
        let textView = MarkdownEditor(
            frame: .zero,
            isShowingFrames: isShowingFrames
        )
        
        textView.delegate = context.coordinator
        textView.string = text
        
        setUpTextViewOptions(for: textView)
        
        textView.applyStyles()
        self.output(textView.editorHeight)
        
        //        if isPrinting { os_log("Made the nsview\n") }
        
        return textView
    }
    
    /// This function is to communicate updates **from** SwiftUI, back **to** the NSView
    /// It is not for sending updates back up to SwiftUI
    /// This *will* update any time a `@Binding` property is mutated from SwiftUI
    public func updateNSView(_ textView: MarkdownEditor, context: Context) {
        
        
        /// The below two statements are called a billion times a second, on SwiftUI ScrollView scroll!
        /// I think I will need to make sure anything in this function, is *ONLY* called if neccesary
        //        os_log("`updateNSView` > MDE width for ID `\(self.id)`: \(textView.bounds.width)")
        
        /// Issue with including `&& self.isEditable` is that the non-editable MDEs can still have their text change
        if textView.string != self.text {
            //
            textView.string = text
            
            /// **IMPORTANT** Before adding the below, when text would get streamed (SSE) in to the MDE (non-Editable mode), the height would not re-calculate per-stream event. So the text would very quickly bleed off the bottom of the Message. With `textView.needsLayout = true`, `textView.invalidateIntrinsicContentSize()`, `textView.needsDisplay = true` etc added, the text view is able to re-adjust its container whenever the binding string is mutated
            Task {
                await MainActor.run {
                    //                  /// It does seem to work with ONLY `textView.invalidateIntrinsicContentSize()`
                    /// Keep `needsLayout`  and `needsDisplay` as a backup just in case
                    self.output(textView.editorHeight)
                    textView.invalidateIntrinsicContentSize()
                }
            }
            //
            ////            textView.setSelectedRange(currentSelectedRange)
            //
            //            Task {
            //                await setStyles(for: textView)
            //            }
            //
        }
        //
        if textView.isShowingFrames != self.isShowingFrames {
            textView.isShowingFrames = self.isShowingFrames
            //            if isPrinting { os_log("Checked if showing frames. Result: \(textView.isShowingFrames)") }
            //            textView.applyStyles()
            //            self.output(textView.editorHeight)
        }
        
        
        /// THIS WORKS TO FIX HEIGHT, WHEN WIDTH CHANGES — DON'T LOSE THISSSSS
        if textView.bounds.width != self.editorWidth {
            Task {
                await MainActor.run {
                    //                            textView.needsLayout = true
                    
                    /// It does seem to work with ONLY `textView.invalidateIntrinsicContentSize()`
                    /// Keep `needsLayout`  and `needsDisplay` as a backup just in case
                    self.output(textView.editorHeight)
                    textView.invalidateIntrinsicContentSize()
                    
                }
            }
        }
        
        
    } // END update nsView
    
    
    
    //    func dismantleNSView(_ textView: MarkdownEditor, context: Context) {
    //
    //        if isPrinting { os_log("Dismantling nsView\n") }
    //        debounceTask?.cancel()
    //    }
    //
    //    private func setStyles(for textView: MarkdownEditor) async {
    //
    //        await MainActor.run {
    //
    //            debounceTask?.cancel()
    //            debounceTask = Task {
    //                do {
    //                    try await Task.sleep(for: .seconds(1))
    //                    if !Task.isCancelled {
    //                        os_log("Waited, now adjusting")
    //                        textView.applyStyles()
    //                        self.output(textView.editorHeight)
    //                        //                        textView.needsLayout = true
    //                        //                        textView.invalidateIntrinsicContentSize()
    //                        //                        textView.needsDisplay = true
    //                        //                        textView.isShowingFrames = false
    //                    }
    //                } catch {}
    //            }
    //
    //        }
    //    }
    
    
    //    private func regexAndStyles(for textView: MarkdownEditor) async {
    //
    //
    //    }
    
    
    /// It is the Coordinator that is responsible for sending information back **to** SwiftUI, from the NSView
    public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    public class Coordinator: NSObject, NSTextViewDelegate {
        
        var parent: MarkdownEditorRepresentable
        
        public init(_ parent: MarkdownEditorRepresentable) {
            self.parent = parent
            //            super.init()
        }
        
        //        public func textDidBeginEditing(_ notification: Notification) {
        //            guard let textView = notification.object as? MarkdownEditor else { return }
        //
        //            if self.parent.text != textView.string {
        //                DispatchQueue.main.async {
        //                    self.parent.text = textView.string
        //                }
        //            }
        //        }
        
        /// Try `scrollRangeToVisible_` for when scroll jumps to top when pasting
        public func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? MarkdownEditor else { return }
            //
            //
            if self.parent.text != textView.string {
                //
                self.parent.text = textView.string
                //
                //                if self.parent.isPrinting {
                //                    os_log("Checked if text has changed")
                //                    os_log("`self.parent.text`: \(self.parent.text)")
                //                    os_log("`textView.string`: \(textView.string)")
                //                }
                //
                //                Task {
                //                    await MainActor.run {
                //
                //                        self.parent.debounceTask?.cancel()
                //                        self.parent.debounceTask = Task {
                //                            do {
                //                                try await Task.sleep(for: .seconds(1))
                //                                if !Task.isCancelled {
                //                                    os_log("Waited, now adjusting")
                //                                    textView.applyStyles()
                //                                    self.parent.output(textView.editorHeight)
                //                                    //                        textView.needsLayout = true
                //                                    //                        textView.invalidateIntrinsicContentSize()
                //                                    //                        textView.needsDisplay = true
                //                                    //                        textView.isShowingFrames = false
                //                                }
                //                            } catch {}
                //                        }
                //
                //                    }
                //                }
                //
                //                //                DispatchQueue.main.async {
                //                //                    if self.parent.text != textView.string {
                //                //                        self.parent.text = textView.string
                //                //                        textView.applyStyles()
                //                //
                //                //
                //                //                        //                        self.parent.editorHeight = textView.editorHeight
                //                //                        self.parent.output(false, textView.editorHeight)
                //                //
                //                //                        textView.invalidateIntrinsicContentSize()
                //                //                        textView.needsDisplay = true
                //                //                    }
                //                //                } // END dispatch async
                //
            } // END text equality check
            //
        } // END Text did change
        
        //        public func textViewDidChangeSelection(_ notification: Notification) {
        //            guard let textView = notification.object as? MarkdownEditor else { return }
        //
        //            DispatchQueue.main.async {
        //                let caretRect = textView.layoutManager?.boundingRect(forGlyphRange: textView.selectedRange(), in: textView.textContainer!)
        //                if let caretRect = caretRect {
        //                    print("Caret position? `\(caretRect)`")
        //                    self.parent.onCaretPositionChange?(caretRect)
        //                }
        //            }
        //
        //
        //        }
        
    }
} // END NSViewRepresentable



extension MarkdownEditorRepresentable {
    
    private func setUpTextViewOptions(for textView: MarkdownEditor) {
        
        textView.textContainer?.containerSize = CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)
        
        /// If this is set to false, then the text tends to be allowed to run off the right edge,
        /// and less width-related calculations seem to be neccesary
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.heightTracksTextView = false
        
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        //        textView.autoresizingMask = [.width]
        
        textView.isAutomaticSpellingCorrectionEnabled = true
        textView.isAutomaticTextCompletionEnabled = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = true
        
        textView.wantsScrollEventsForSwipeTracking(on: .none)
        textView.wantsForwardedScrollEvents(for: .none)
        
        
        
        textView.isRichText = false
        textView.importsGraphics = false
        
        textView.insertionPointColor = NSColor(configuration?.insertionPointColour ?? .blue)
        
        textView.smartInsertDeleteEnabled = true
        
        textView.usesFindBar = true
        
        textView.textContainer?.lineFragmentPadding = configuration?.paddingX ?? 30
        textView.textContainerInset = NSSize(width: 0, height: configuration?.paddingY ?? 30)
        
        /// When the text field has an attributed string value, the system ignores the textColor, font, alignment, lineBreakMode, and lineBreakStrategy properties. Set the foregroundColor, font, alignment, lineBreakMode, and lineBreakStrategy properties in the attributed string instead.
        textView.font = NSFont.systemFont(ofSize: configuration?.fontSize ?? MarkdownDefaults.fontSize, weight: .medium)
        textView.textColor = NSColor.textColor.withAlphaComponent(MarkdownDefaults.fontOpacity)
        
        textView.isEditable = self.isEditable
        
        textView.drawsBackground = false
        textView.allowsUndo = true
        textView.setNeedsDisplay(textView.bounds)
        //        textView.setNeedsDisplay(NSRect(x: 0, y: 0, width: self.editorWidth ?? 200, height: 200))
    }
    
}

