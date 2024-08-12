//
//  SwiftUIView.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import SwiftUI
//import Networking

struct ExampleView: View {
  
  @State private var text: String = Self.exampleMarkdown
  
  var body: some View {
    MarkdownEditor(text: $text)
      .background(.black.opacity(0.5))
      .background(.purple.opacity(0.1))
  }
}

extension ExampleView {
  static let exampleMarkdown: String = """
   # Markdown samples
   ## Overview of the sample
   Usually, `NSTextView` manages the *layout* process inside **the viewport** interacting ~~with its delegate~~.
   
   - [AttributeContainer](http://apple.com) is a container for attributes.
   - By configuring the container, we can set, replace, and merge
   - A large number of attributes for a string (or fragment) at once.
   
   ### Markdown syntax summary
   A `viewport` is a _rectangular_ area within a ==flipped coordinate system== expanding along the y-axis, with __bold alternate__, as well as ***bold italic*** emphasis.
   
   1. You’d mentioned this is rendered within an OpenGL window
   2. Despite the implementation details under the hood
   3. They can only speculate, but perhaps OpenGL here is useful
   
   ```python
   // There is also some basic code
   var x = y
   ```
   
   > This *brief* block quote, with ==text contents==, lines `advance expanding` the view in the current writing direction.ExampleView
   
   
   """
}

#Preview {
  ExampleView()
    .frame(height: 700)
}
