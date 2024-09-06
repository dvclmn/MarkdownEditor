//
//  SwiftUIView.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import SwiftUI
import BaseHelpers
import BaseStyles

import Neon

struct ExampleView: View {
  
  @State private var text: String = TestStrings.Markdown.basicMarkdown
  @State private var editorInfo: EditorInfo? = nil
  @State private var config = MarkdownEditorConfiguration(
    fontSize: 13,
    lineHeight: 1.1,
    renderingAttributes: .markdownRenderingDefaults,
    insertionPointColour: .pink,
    codeColour: .green,
    hasLineNumbers: false,
    isShowingFrames: false,
    insets: 20
  )
  
  var body: some View {
    
    VStack(spacing: 0) {
      
      
      MarkdownEditor(text: $text, configuration:config) { info in
        self.editorInfo = info
      }
      .background(alignment: .topLeading) {
        Rectangle()
          .fill(.blue.opacity(0.05))
          .frame(height: self.editorInfo?.frame.height, alignment: .topLeading)
          .border(Color.blue.opacity(0.2))
      }
      .frame(maxWidth: .infinity, alignment: .top)
      
    }
  
    .background(.black.opacity(0.5))
    .background(.purple.opacity(0.1))
    .frame(width: 440, height: 600)
    
    /// Interestingly, the below 'simulates' text being added to the NSTextView, but NOT
    /// in the same as a user actually focusing the view and typing into it. There appears
    /// to be a difference between these two methods of the text being mutated.
    ///
    //    .task {
    //      do {
    //        try await Task.sleep(for: .seconds(0.8))
    //
    //        self.text += "Hello"
    //      } catch {
    //
    //      }
    //    }
  }
}


#Preview {
  ExampleView()
  
}
