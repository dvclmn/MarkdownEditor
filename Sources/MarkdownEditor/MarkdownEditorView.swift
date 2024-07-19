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
    
    public var searchText: String
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
        searchText: String = "",
        configuration: MarkdownEditorConfiguration? = nil,
        id: String? = nil,
        didAppear: Bool = false,
        editorWidth: CGFloat? = nil,
        
        isShowingFrames: Bool = false,
        
        isEditable: Bool = true,
        
        output: @escaping (_ editorHeight: CGFloat) -> Void = {_ in}
        
    ) {
        self._text = text
        self.searchText = searchText
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
            isShowingFrames: self.isShowingFrames,
            searchText: self.searchText
        )
        
        textView.delegate = context.coordinator
        textView.string = text
        
        setUpTextViewOptions(for: textView)
        
        textView.applyStyles()
        
        /// Not sure there's anything to invalidate on startup
//        textView.invalidateIntrinsicContentSize()
        
        self.output(textView.editorHeight)
        
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
        
        if textView.string != self.text {
            textView.string = text
            Task {
                await MainActor.run {
                    
                    if self.isEditable {
                        /// Keep `needsLayout`  and `needsDisplay` as a backup just in case
                        textView.invalidateIntrinsicContentSize()
                        //                    textView.needsLayout = true
//                                            textView.needsDisplay = true
                        self.output(textView.editorHeight)
                        
                    } else {
                        /// I can run a 'more expensive' operation on non-Editable MDE's
                        textView.applyStyles()
//                        textView.invalidateIntrinsicContentSize()
//                        self.output(textView.editorHeight)
                    }
                    
                }
            } // END task
        }

        if textView.isShowingFrames != self.isShowingFrames {
            textView.isShowingFrames = self.isShowingFrames
            os_log("Does this ever change? is `textView.isShowingFrames` \(textView.isShowingFrames), ever different from `self.isShowingFrames`? \(self.isShowingFrames)")
        }
        
        
        
        if textView.searchText != self.searchText {
            textView.searchText = self.searchText
            os_log("Does this ever change? is `textView.searchText` \(textView.searchText), ever different from `self.searchText`? \(self.searchText)")
            
            Task {
                await MainActor.run {
                    textView.applyStyles()
                    textView.invalidateIntrinsicContentSize()
                    self.output(textView.editorHeight)
                }
            }
        }
        
        
        /// THIS WORKS TO FIX HEIGHT, WHEN WIDTH CHANGES — DON'T LOSE THISSSSS
        if textView.bounds.width != self.editorWidth {
            Task {
                await MainActor.run {
                    
                    textView.invalidateIntrinsicContentSize()
                    self.output(textView.editorHeight)
                    
                }
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
        }
        
        /// Try `scrollRangeToVisible_` for when scroll jumps to top when pasting
        public func textDidChange(_ notification: Notification) {
            
            guard let textView = notification.object as? MarkdownEditor else { return }
            
            if self.parent.text != textView.string {
                self.parent.text = textView.string
                Task {
                    await MainActor.run {
                        self.parent.output(textView.editorHeight)
                        textView.applyStyles()
                        textView.invalidateIntrinsicContentSize()
                    }
                }
                
            } // END text equality check
            //
        } // END Text did change
        
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
        
        textView.smartInsertDeleteEnabled = false
        
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
//                textView.setNeedsDisplay(NSRect(x: 0, y: 0, width: self.editorWidth ?? 200, height: 200))
    }
    
}


#endif
