//
//  File.swift
//  
//
//  Created by Dave Coleman on 25/6/2024.
//

#if os(macOS)
import Foundation
import SwiftUI
import TestStrings
import BaseUtilities

struct MarkdownExampleView: View {
    
    @State private var isStreaming: Bool = false
    
    @State private var text: String = TestStrings.paragraphsWithCode[0]
    @State private var editorHeight: CGFloat = 0
    
    @FocusState private var isFocused
    
    @State private var mdeDidAppear: Bool = false
    @State private var isLoading: Bool = false
    
    var body: some View {
        
        ScrollView {
            
            HStack {
                
                VStack {
                    Text("Editable")
                    MarkdownEditorRepresentable(text: $text)
                }
                VStack {
                    Text("Non-editable")
                    MarkdownEditorRepresentable(text: $text, isEditable: false)
                }
            }
            
        }
        .task {
            if isStreaming {
                do {
                    for try await chunk in MockupTextStream.chunks(chunkSize: 1, speed: 300) {
                        await MainActor.run {
                            text += chunk
                        }
                    }
                } catch {
                    print("Error: \(error)")
                }
            }
        }
//        .border(Color.green.opacity(0.2))
        .background(.blue.opacity(isLoading ? 0.6 : 0.1))
        //        .task {
        //            mdeDidAppear = true
        //        }
    }
}

extension MarkdownExampleView {
    
    
    
}
#Preview {
    MarkdownExampleView()
        .frame(width: 600, height: 700)
}

#endif
