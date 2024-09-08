//
//  SwiftUIView.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import SwiftUI
import BaseHelpers

public struct ExampleView: View {
  
  @State private var text: String = TestStrings.Markdown.basicMarkdown
  
  /// From AppKit —> SwiftUI
  /// This currently only returns a frame (`CGSize`), to provide SwiftUI with
  /// the height of the editor.
  ///
  @State private var editorInfo: EditorInfo? = nil
  
  /// From SwiftUI —> AppKit
  /// Current method to set options for how the editor should look and feel
  ///
//  let config = MarkdownEditorConfiguration(
//    fontSize: 13,
//    lineHeight: 1.1,
//    renderingAttributes: .markdownRenderingDefaults,
//    insertionPointColour: .pink,
//    codeColour: .green,
//    hasLineNumbers: false,
//    isShowingFrames: false,
//    insets: 20
//  )
  
  public var body: some View {
    
    VStack(spacing: 0) {
      
      MarkdownEditor(text: $text, configuration: .init()) { info in
        self.editorInfo = info
      }
     
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
