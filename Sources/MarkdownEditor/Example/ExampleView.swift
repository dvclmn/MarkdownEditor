//
//  SwiftUIView.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import SwiftUI
//import Networking
import Scrolling

struct ExampleView: View {
  
  @State private var text: String = Self.exampleMarkdown
  @State private var textInfo: EditorInfo.Text? = nil
  @State private var selectionInfo: EditorInfo.Selection? = nil
  @State private var editorHeight: CGFloat = .zero
  @State private var scrollOffset: CGFloat = .zero
  
  @State private var scrollInfo: EditorInfo.Scroll? = nil
  
  var body: some View {
    
    
    
    VStack(spacing: 0) {
      
      Spacer()
      
      VStack {
        MarkdownEditor(
          text: $text,
          scrollOffsetIn: scrollOffset,
          isShowingFrames: false,
          textInfo: { self.textInfo = $0 },
          selectionInfo: { self.selectionInfo = $0 },
          editorHeight: { self.editorHeight = $0 },
          scrollOffsetOut: { self.scrollInfo = $0 }
        )
        .frame(height: self.editorHeight)
      }
//      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .scrollWithOffset { offset in
        self.scrollOffset = offset.y
      }
//      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
      
      HStack(alignment: .bottom) {
        Text(self.selectionInfo?.summary ?? "nil")
        Spacer()
        Text(self.scrollInfo?.summary ?? "nil")
        Spacer()
        Text(self.textInfo?.summary ?? "nil")
      }
      .foregroundStyle(.secondary)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 30)
      .padding(.top, 10)
      .padding(.bottom, 14)
      .background(.black.opacity(0.5))
    }
    .overlay(alignment: .topTrailing) {
      VStack {
        Text("Local editor height \(self.editorHeight.description)")
        //        Text("Local scroll offset \(self.scrollOffset.y)")
      }
      .allowsHitTesting(false)
      .foregroundStyle(.secondary)
    }
    .background(.black.opacity(0.5))
    .background(.purple.opacity(0.1))
    .frame(width: 500, height: 700)
  }
}

extension ExampleView {
  
  static let shortSample: String = "This *brief* block quote, with ==text contents==, lines `advance expanding` the view in the current writing direction.ExampleView"
  
  static let exampleMarkdown: String = """
   # Markdown samples
   ## Overview of the sample
   
   ```swift
   @State private var selectionInfo: EditorInfo.Selection? = nil
   // @State private var editorHeight: CGFloat = .zero
   ```
   
   Usually, `NSTextView` manages the *layout* process inside **the viewport** interacting ~~with its delegate~~.
   
   - [AttributeContainer](http://apple.com) is a container for attributes.
   - By configuring the container, we can set, replace, and merge
   - A large number of attributes for a string (or fragment) at once.
   
   ```python
   // There is also some basic code
   var x = y
   ```
   
   ### Markdown syntax summary
   A `viewport` is a _rectangular_ area within a ==flipped coordinate system== expanding along the y-axis, with __bold alternate__, as well as ***bold italic*** emphasis.
   
   1. You’d mentioned this is rendered within an OpenGL window
   2. Despite the implementation details under the hood
   3. They can only speculate, but perhaps OpenGL here is useful
   
   > This *brief* block quote, with ==text contents==, lines `advance expanding` the view in the current writing direction.ExampleView
   
   """
}

#Preview {
  ExampleView()
  
}
