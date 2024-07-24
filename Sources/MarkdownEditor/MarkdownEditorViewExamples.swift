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
    
    @State private var isStreaming: Bool = false
    
    @State private var text: String = TestStrings.paragraphs[1]
    
    @State private var editorHeight: CGFloat = .zero
    @State private var editorWidth: CGFloat = .zero
    @State private var editorMetrics: String = "nil"
    
    @FocusState private var isFocused
    
    @State private var mdeDidAppear: Bool = false
    @State private var isLoading: Bool = false
    
    @State private var isManualMode: Bool = false
    
    var body: some View {
        VStack {
            
            MarkdownEditorRepresentable(text: $text, width: editorWidth) { metrics, height in
                editorMetrics = metrics
                editorHeight = height
            }
            .readSize { size in
                editorWidth = size.width
            }
                            .frame(height: editorHeight + 60)
                            .border(Color.green.opacity(0.3))
                            .resizable(
                                isManualMode: $isManualMode,
                                edge: .trailing,
                                lengthMin: 100,
                                lengthMax: 400
                            )
            
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
            
        } // END vstack
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .border(Color.purple.opacity(0.3))
        .overlay(alignment: .trailing) {
//            VStack {
//                Text("Metrics: \(editorMetrics)")
//                Text("Height: \(editorHeight)")
//                Text("Width: \(editorWidth)")
//            }
//            .font(.caption)
        }
    }
}


#Preview {
    MarkdownExampleView()
        .frame(width: 500, height: 700)
}

#endif

