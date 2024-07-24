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
import Resizable

struct MarkdownExampleView: View {
    
    @State private var isStreaming: Bool = true
    
    @State private var text: String = TestStrings.paragraphs[1]
    @State private var editorHeight: CGFloat = 0
    
    @FocusState private var isFocused
    
    @State private var mdeDidAppear: Bool = false
    @State private var isLoading: Bool = false
    
    @State private var isManualMode: Bool = false
    
    var body: some View {
        
//        GeometryReader { geo in
//        ScrollView {
            
                MarkdownTextView(text: $text)
                    .padding()
                    .resizable(
                        isManualMode: $isManualMode,
                        edge: .trailing,
                        lengthMin: 100,
                        lengthMax: 400
                    )
                    .background(.blue.opacity(0.3))
                    .border(Color.purple.opacity(0.3))
        
//                    .frame(height: geo.size.height, alignment: .top)
//            } // END scrollview
            
//            HStack {
                
//                VStack {
//                    Text("Editable")
//                    MarkdownEditorRepresentable(text: $text)
//                }
//                VStack {
//                    Text("Non-editable")
//                    MarkdownEditorRepresentable(text: $text, isEditable: false)
//                }
//            }
            
//        } // END geo reader
        
//        .task {
//            if isStreaming {
//                do {
//                    for try await chunk in MockupTextStream.chunks(chunkSize: 1, speed: 300) {
//                        await MainActor.run {
//                            text += chunk
//                        }
//                    }
//                } catch {
//                    print("Error: \(error)")
//                }
//            }
//        }
//        .border(Color.green.opacity(0.2))
        
        //        .task {
        //            mdeDidAppear = true
        //        }
    }
}


#Preview {
    MarkdownExampleView()
        .frame(width: 500, height: 700)
}

#endif

