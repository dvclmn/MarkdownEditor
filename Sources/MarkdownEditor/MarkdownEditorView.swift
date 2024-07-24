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
//    @Binding public var height: CGFloat
    public var width: CGFloat
    
    public var searchText: String
    public var configuration: MarkdownEditorConfiguration?
    
    public var id: String?
    
    public var isShowingFrames: Bool
    
    public var isEditable: Bool
    
    public var output: (_ metrics: String, _ height: CGFloat) -> Void
    
    public init(
        text: Binding<String>,
        
        width: CGFloat,
        searchText: String = "",
        configuration: MarkdownEditorConfiguration? = nil,
        id: String? = nil,
        
        isShowingFrames: Bool = false,
        
        isEditable: Bool = true,
        
        output: @escaping (_ metrics: String, _ height: CGFloat) -> Void = {_,_ in }
        
    ) {
        self._text = text
        
        self.width = width
        self.searchText = searchText
        self.configuration = configuration
        self.id = id
        self.isShowingFrames = isShowingFrames
        self.isEditable = isEditable
        self.output = output
    }
    
    private let isPrinting: Bool = true
    
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
        
        textView.applyStyles(to: NSRange(location: 0, length: text.utf16.count))
        
        // Set up width constraint
//                let widthConstraint = textView.widthAnchor.constraint(equalToConstant: width)
//                widthConstraint.isActive = true
//                context.coordinator.widthConstraint = widthConstraint
                
                // Initial size update
                
        
        
        self.sendOutSize(for: textView)
        
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
        
        
        
        
        
        // Update text if changed
                if textView.string != self.text {
                    let oldLength = textView.string.utf16.count
                    textView.string = text
                    let newLength = text.utf16.count
                    
                    // Apply styles only to the changed range
                    let changedRange = NSRange(location: 0, length: max(oldLength, newLength))
                    textView.applyStyles(to: changedRange)
                }

        let currentWidth = self.width
                // Update width if changed
//                if abs(textView.frame.width - self.width) > 0.1 {  // Use a small threshold to avoid floating point issues
        if currentWidth != self.width {
//                    context.coordinator.widthConstraint?.constant = self.width
                    textView.invalidateIntrinsicContentSize()
                    self.sendOutSize(for: textView)
                }

                // Update other properties if changed
                if textView.isShowingFrames != self.isShowingFrames {
                    textView.isShowingFrames = self.isShowingFrames
                }
                
                if textView.searchText != self.searchText {
                    textView.searchText = self.searchText
                }

        
        
        
        
//
//        if textView.string != self.text {
//            let oldLength = textView.string.utf16.count
//            textView.string = text
//            let newLength = text.utf16.count
//            
//            // Apply styles only to the changed range
//            let changedRange = NSRange(location: 0, length: max(oldLength, newLength))
//            
//            textView.applyStyles(to: changedRange)
//            
//            self.sendOutSize(for: textView)
//        }
//
//        if textView.isShowingFrames != self.isShowingFrames {
//            textView.isShowingFrames = self.isShowingFrames
//            os_log("Does this ever change? is `textView.isShowingFrames` \(textView.isShowingFrames), ever different from `self.isShowingFrames`? \(self.isShowingFrames)")
//        }
//        
//        
//        
//        if textView.searchText != self.searchText {
//            textView.searchText = self.searchText
//            os_log("Does this ever change? is `textView.searchText` \(textView.searchText), ever different from `self.searchText`? \(self.searchText)")
//        }
//        
//        //        DispatchQueue.main.async {
//        //                    output("Current width \(textView.frame.width)")
//        //                }
//            
//        let currentWidth = textView.frame.width
//        if currentWidth != textView.frame.width {
//            context.coordinator.lastKnownWidth = currentWidth
//            
//            textView.invalidateIntrinsicContentSize()
//            
//            self.sendOutSize(for: textView)
//            
//            output("Current width \(textView.frame.width)")
//            
////            DispatchQueue.main.async {
////                self.height = textView.editorHeight
////                self.width = textView.editorWidth
////            }
//            //                context.coordinator.applyMarkdownStyling(to: textView)
//        }
//        
//        
//        /// THIS WORKS TO FIX HEIGHT, WHEN WIDTH CHANGES — DON'T LOSE THISSSSS
//                        if textView.bounds.width != self.width {
//                            
//                            self.sendOutSize(for: textView)
//                            
//                            
////                            DispatchQueue.main.async {
////                                output("The width changed")
////                            }
//        //                    Task {
//        //                        await MainActor.run {
//        //
//        //                            textView.invalidateIntrinsicContentSize()
//        //                            self.output(textView.editorHeight)
//        //
//        //                        }
//        //                    }
//                        }
//        
        
    } // END update nsView
    
    
    /// It is the Coordinator that is responsible for sending information back **to** SwiftUI, from the NSView
    public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    public class Coordinator: NSObject, NSTextViewDelegate {
        
        var parent: MarkdownEditorRepresentable
        
//        var widthConstraint: NSLayoutConstraint?

        
        public init(_ parent: MarkdownEditorRepresentable) {
            self.parent = parent
        }
        
        /// Try `scrollRangeToVisible_` for when scroll jumps to top when pasting
        public func textDidChange(_ notification: Notification) {
            
            guard let textView = notification.object as? MarkdownEditor else { return }
            
            if self.parent.text != textView.string {
                self.parent.text = textView.string
                self.parent.sendOutSize(for: textView)
                //                self.parent.outputEditorHeight(for: textView, withReason: "`textDidChange`, if self.parent.text != textView.string {")
            }  // END text equality check
            //
        } // END Text did change
        
    } // END coordinator
    
    private func sendOutSize(for textView: MarkdownEditor) {
        DispatchQueue.main.async {
            self.output("Height: \(textView.editorHeight), Width: \(textView.editorWidth)", textView.editorHeight)
        }
    }
    
    //    @MainActor
    //    private func outputEditorHeight(for textView: MarkdownEditor, withReason: String) {
    //        DispatchQueue.main.async {
    //            textView.invalidateIntrinsicContentSize()
    ////            self.height = textView.editorHeight
    ////            self.output(textView.editorHeight)
    //        }
    //        //        os_log("Sent editor height from `textView` to SwiftUI: \(textView.editorHeight.displayAsInt()), and invalidated content size. The reason/trigger for this being executed was: \(withReason)")
    //    }
    
} // END NSViewRepresentable




#endif
