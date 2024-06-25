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
    
    @Binding public var isShowingFrames: Bool
    
    public var editorHeightTypingBuffer: CGFloat
    public var inlineCodeColour: Color
    
    
    public var isEditable: Bool
    
    public var fontSize: Double
    
    var isLoading: (Bool) -> Void
    
    private let verticalPadding: Double = 30
    
    @State private var previousWidth: Double = 0
    
    @State private var needsDisplayTimer: Timer?
    @State private var needsDisplayFlag = false
    
    public init(
        text: Binding<String>,
        editorHeight: Binding<CGFloat>,
        id: String,
        didAppear: Bool = false,
        
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
        
        Task {
            await setUpTextView(for: textView)
        }
        
        return textView
        
    }
    
    private func setUpTextView(for textView: MarkdownEditor) async {
        
//                try? await Task.sleep(for: .seconds(2))
        
        await MainActor.run {
            textView.applyStyles()
            self.editorHeight = textView.editorHeight
        }
        self.isLoading(false)
    }
    
    /// This function is to communicate updates **from** SwiftUI, back **to** the NSView
    /// It is not for sending updates back up to SwiftUI
    /// This *will* update any time a `@Binding` property is mutated from SwiftUI
    public func updateNSView(_ textView: MarkdownEditor, context: Context) {
        
        if didAppear {
            
            os_log("Can now update MDE of id: `\(id)`, view has appeared")
            if textView.isEditable != self.isEditable {
//                os_log("Editability changed.")
//                os_log("`textView.isEditable`: \(textView.isEditable)")
//                os_log("`self.isEditable`: \(self.isEditable)")
                textView.isEditable = self.isEditable
            }
            
            if self.isEditable {
                
                if textView.string != text {
                    
                    textView.string = text
                    Task {
                        await setUpTextView(for: textView)
                    }
                    
                }
                
                if textView.editorHeight != self.editorHeight {
                    
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
                
                
                
                let currentWidth = textView.bounds.width
                
                if previousWidth != currentWidth {
                    
                    previousWidth = currentWidth
                    Task {
                        await setUpTextView(for: textView)
                    }
                    
                }
                
            } else  {
                let currentWidth = textView.bounds.width
                
                if previousWidth != currentWidth {
                    os_log("Width changed")
                    
                    previousWidth = currentWidth
                    Task {
                        await setUpTextView(for: textView)
                    }
                    
                }
                
            } // END edtiable check
            
            
        } else {
            os_log("Not updating view, MDE of id \(id) has not appeared yet.")
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
        
        textView.textContainer?.lineFragmentPadding = Styles.paddingLarge
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
    
    @State private var mdeDidAppear: Bool = false
    @State private var isLoading: Bool = false
    
    var body: some View {
        
        ScrollView {
            MarkdownEditorRepresentable(
                text: $text,
                editorHeight: $editorHeight,
                id: "Markdown editor preview",
                didAppear: mdeDidAppear,
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

