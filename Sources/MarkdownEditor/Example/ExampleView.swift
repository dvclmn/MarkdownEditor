//
//  SwiftUIView.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import SwiftUI
import BaseHelpers
//import Resizable

public struct ExampleView: View {
  
  
  @State private var text: String = TestStrings.Markdown.basicMarkdown
  
  /// From AppKit —> SwiftUI
  /// This currently only returns a frame (`CGSize`), to provide SwiftUI with
  /// the height of the editor.
  @State private var editorInfo: EditorInfo? = nil
  
  @State private var emitter: EventEmitter<SyntaxEvent> = .init()
  @State private var isManualMode: Bool = false
  //  @State private var markdownAction: Markdown.SyntaxAction? = nil
  
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
  
  let syntaxButtons: [Markdown.Syntax] = [.bold, .italic, .inlineCode]
  
  public var body: some View {
    
    VStack(spacing: 0) {
      
      MarkdownEditor(
        text: $text
//        eventEmitter: self.emitter,
      ) { info in
        self.editorInfo = info
      }
    }
    //    .overlay(alignment: .bottom) {
    //      HStack {
    //
    //        ForEach(syntaxButtons) { syntax in
    //          Button {
    //            self.emitter.emit(.wrap(syntax))
    //          } label: {
    //            Label(syntax.name, systemImage: syntax.shortcuts.first?.label?.icon ?? "bold")
    //              .labelStyle(.iconOnly)
    //              .fontWeight(.medium)
    //              .fontDesign(.rounded)
    //              .frame(width: 14)
    //          }
    //
    //        }
    //
    //      }
    //      .padding(.horizontal, 12)
    //      .frame(height: 40)
    //      .frame(maxWidth: .infinity, alignment: .leading)
    ////      .background(.regularMaterial)
    //    }
    //
    
//    .resizable(
//      isManualMode: $isManualMode,
//      edge: .trailing,
//      lengthMin: 100,
//      lengthMax: 600
//    )
    .background(.black.opacity(0.6))
    .background(.purple.opacity(0.1))
    
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

extension ExampleView {
  
}


#Preview {
  ExampleView()
    .frame(width: 600, height: 600)
}
