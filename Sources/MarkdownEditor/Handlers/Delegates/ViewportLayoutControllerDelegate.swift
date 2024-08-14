//
//  CustomViewportDelegate.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI

class CustomViewportDelegate: NSObject, NSTextViewportLayoutControllerDelegate {
    weak var textView: MarkdownTextView?

    func viewportBounds(for textViewportLayoutController: NSTextViewportLayoutController) -> CGRect {
        guard let textView = textView else { return .zero }
        return textView.visibleRect
    }

    func textViewportLayoutController(_ textViewportLayoutController: NSTextViewportLayoutController, configureRenderingSurfaceFor textLayoutFragment: NSTextLayoutFragment) {
        // This method is called for each text layout fragment that needs to be rendered
        print("Rendering fragment: \(textLayoutFragment)")
    }

    func textViewportLayoutControllerWillLayout(_ textViewportLayoutController: NSTextViewportLayoutController) {
        print("Layout process is about to begin")
    }

    func textViewportLayoutControllerDidLayout(_ textViewportLayoutController: NSTextViewportLayoutController) {
        print("Layout process has completed")
    }
}
