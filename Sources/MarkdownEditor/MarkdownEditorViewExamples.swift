//
//  File.swift
//  
//
//  Created by Dave Coleman on 25/6/2024.
//

import Foundation
import SwiftUI
import TestStrings

struct MarkdownExampleView: View {
    
    @State private var text: String = TestStrings.smallCodeBlock
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
