//
//  File.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import BaseHelpers
import MarkdownModels
import SwiftUI

@MainActor
public struct MarkdownEditor: NSViewRepresentable {

  @Binding var text: String
  var configuration: EditorConfiguration
  var height: (CGFloat) -> Void

  public init(
    text: Binding<String>,
    configuration: EditorConfiguration = .init(),
    height: @escaping (CGFloat) -> Void = { _ in }
  ) {
    self._text = text
    self.configuration = configuration
    self.height = height
  }

  public func makeNSView(context: Context) -> MarkdownScrollView {
    let view = MarkdownScrollView(
      frame: .zero,
      configuration: configuration
    )
    view.textView.delegate = context.coordinator
    view.textView.setUpTextView(configuration)

    /// For non‑editable views, assign the closure so that we get notified when the intrinsic height changes.
    view.heightChanged = { newHeight in
      DispatchQueue.main.async {
        if !configuration.isEditable {
          self.height(newHeight)
        }
      }
    }

    return view
  }

  public func updateNSView(_ nsView: MarkdownScrollView, context: Context) {

    print("Running `updateNSView` at \(Date())")

    let textView = nsView.textView

    if textView.string != text {
      textView.string = text
    }


    /// Only for non‑editable views, update height
    if !configuration.isEditable {
      nsView.layoutSubtreeIfNeeded()
      let newIntrinsicHeight = textView.intrinsicContentSize.height

      /// Throttle to prevent excessive updates.
      if let last = context.coordinator.lastUpdatedHeight, abs(last - newIntrinsicHeight) < 1.0 {
        /// Change is minimal; do nothing.
      } else {
        print("The `textView` intrinsic height is \(newIntrinsicHeight)")
        context.coordinator.lastUpdatedHeight = newIntrinsicHeight
        DispatchQueue.main.async {
          /// Pass the new desired height to SwiftUI.
          self.height(newIntrinsicHeight)
        }
      }
    }


    //    if !configuration.isEditable {
    //      /// Force a layout update.
    //      nsView.layoutSubtreeIfNeeded()
    //
    //      /// Retrieve the height from the text view’s intrinsic content size.
    //      let intrinsicHeight = textView.intrinsicContentSize.height
    //      print("The `textView` intrinsic height is \(intrinsicHeight)")
    //
    //      /// Call the closure so SwiftUI can update its layout.
    //      DispatchQueue.main.async {
    //        height(intrinsicHeight)
    //      }
    //    }

  }
}
