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
import GeneralStyles

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
    
    //    @State private var startedLoadingTime: Date = .now
    //    @State private var finishedLoadingTime: Date = .now
    
    @State private var needsDisplayTimer: Timer?
    @State private var needsDisplayFlag = false
    
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
        
        isLoading: @escaping (Bool) -> Void
        
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
        
        /// The below two statements are called a billion times a second, on SwiftUI ScrollView scroll!
        /// I think I will need to make sure anything in this function, is *ONLY* called if neccesary
        os_log("`updateNSView` > MDE width for ID `\(self.id)`: \(textView.bounds.width)")
        
        if textView.isEditable != self.isEditable {
            os_log("MDE ID: `\(self.id)`. `textView.isEditable`: \(textView.isEditable) is not equal to `self.isEditable`: \(self.isEditable).")
            textView.isEditable = self.isEditable
        }
        
        if self.isEditable {
            
            os_log("--- BEGIN: `updateNSView > if self.isEditable {` ---")
            os_log("This is likely to contain only the live editor's operations")
            if textView.string != self.text {
                os_log("""
--- EDITOR STRING Changed — `if textView.string != self.text` ---
MDE ID: `\(self.id)`
`textView.isEditable`: \(textView.isEditable), `self.isEditable`: \(self.isEditable)
`textView.string`: \"\(textView.string.suffix(60))\", `self.text`: \"\(self.text.suffix(60))\" (last 60 characters)
---
""")
                
                textView.string = text
                Task {
                    await setUpTextView(for: textView)
                }
                
            }
            
            if textView.editorHeight != self.editorHeight {
                
                os_log("""
--- EDITOR HEIGHT Changed — `if textView.editorHeight != self.editorHeight` ---
MDE ID: `\(self.id)`
`textView.isEditable`: \(textView.isEditable), `self.isEditable`: \(self.isEditable)
`textView.editorHeight`: \"\(textView.editorHeight)\", `self.editorHeight`: \"\(self.editorHeight)\"
---
""")
                
                Task {
                    await setUpTextView(for: textView)
                }
                
            } // END editor height changed check
            
            if textView.isShowingFrames != self.isShowingFrames {
                textView.isShowingFrames = self.isShowingFrames
                Task {
                    await setUpTextView(for: textView)
                }
            }
            
            
            /// NOTE: This value changes a LOT, so debounce it, or avoid tying expensive operations to it
            if textView.bounds.width != editorWidth {
                
                debounce(interval: 2) { [weak textView] in
                    await MainActor.run {
                        textView?.invalidateIntrinsicContentSize()
                    }
                }
            }
            
            
            os_log("--- END: `updateNSView > if self.isEditable {` ---\n\n\n")
            
        } // END is editable check

    } // END update nsView
    
    func dismantleNSView(_ textView: MarkdownEditor, context: Context) {
        debounceTask?.cancel()
    }
    
    private func debounce(interval: TimeInterval, action: @escaping () async -> Void) {
        debounceTask?.cancel()
        debounceTask = Task { @MainActor in
            do {
                try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                if !Task.isCancelled {
                    await action()
                }
            } catch {
                print("Debounce task error \(error)")
            }
        }
    }
    
    
    private func setUpTextView(for textView: MarkdownEditor) async {
        
        //                try? await Task.sleep(for: .seconds(2))
        
        await MainActor.run {
            textView.applyStyles()
            self.editorHeight = textView.editorHeight
        }
    }
    
    private func redrawWidth(for textView: MarkdownEditor) async {
        
        
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
        
        textView.textContainer?.lineFragmentPadding = Styles.paddingLarge
        textView.textContainerInset = NSSize(width: 0, height: Styles.paddingLarge)
        
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
    
    @State private var mdeDidAppear: Bool = false
    @State private var isLoading: Bool = false
    
    var body: some View {
        
        ScrollView {
            MarkdownEditorRepresentable(
                text: $text,
                editorHeight: $editorHeight,
                id: "Markdown editor preview",
                didAppear: mdeDidAppear,
                editorWidth: 200,
                editorHeightTypingBuffer: 60,
                inlineCodeColour: .cyan
            ) { isLoading in
                
                self.isLoading = isLoading
            }
        }
        .border(Color.green.opacity(0.2))
        .background(.blue.opacity(isLoading ? 0.6 : 0.1))
        //        .task {
        //            mdeDidAppear = true
        //        }
    }
}
#Preview {
    MarkdownExampleView()
        .frame(width: 600, height: 700)
}

