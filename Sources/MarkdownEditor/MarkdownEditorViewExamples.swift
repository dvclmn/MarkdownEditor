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
//import BaseUtilities
//import Resizable

struct MarkdownExampleView: View {
    
    @State private var isStreaming: Bool = false
    
//    @State private var text: String = ""
    @State private var text: String = TestStrings.paragraphs[1]
    
    @State private var editorHeight: CGFloat = .zero
    @State private var editorWidth: CGFloat = 300
    @State private var editorMetrics: String = "nil"
    
    @FocusState private var isFocused
    
    @State private var isLoading: Bool = false
    
    @State private var isManualMode: Bool = false
    
    var body: some View {
        VStack {
            
            ScrollView(.vertical) {
                MarkdownEditorRepresentable(
                    text: $text,
                    width: editorWidth
                ) { metrics, height in
                    editorMetrics = metrics
                    editorHeight = height
                }
                .border(Color.green.opacity(0.3))
                .frame(height: editorHeight + 60)
            }
//            .readSize { size in
//                editorWidth = size.width
//            }
//                            .resizable(
//                                isManualMode: $isManualMode,
//                                edge: .trailing,
//                                lengthMin: 100,
//                                lengthMax: 400
//                            )
            
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
            VStack {
                Text("Metrics: \(editorMetrics)")
                Text("Height: \(editorHeight)")
                Text("Width: \(editorWidth)")
            }
            .background(.blue.opacity(0.6))
            .font(.caption)
        }
    }
}


#Preview {
    MarkdownExampleView()
        .frame(width: 500, height: 700)
}

#endif





enum TextChunkError: Error {
    case cancelled
}

public class MockupTextStream {
    
    public static func chunks(
        from text: String? = nil,
        chunkSize: Int = 5,
        speed: Int = 200
    ) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    for chunk in splitContentPreservingWhitespace(text, chunkSize: chunkSize) {
                        try Task.checkCancellation()
                        continuation.yield(chunk)
                        try await Task.sleep(for: .milliseconds(speed))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    private static func splitContentPreservingWhitespace(_ content: String? = nil, chunkSize: Int = 5) -> [String] {
        var chunks: [String] = []
        var currentChunk = ""
        var wordCount = 0
        
        var textContent: String = ""
        
        if let content = content {
            textContent = content
        } else {
            textContent = TestStrings.paragraphsWithCode[0]
        }
        
        for character in textContent {
            currentChunk.append(character)
            
            if character.isWhitespace || character.isNewline {
                wordCount += 1
                if wordCount >= chunkSize {
                    chunks.append(currentChunk)
                    currentChunk = ""
                    wordCount = 0
                }
            }
        }
        
        if !currentChunk.isEmpty {
            chunks.append(currentChunk)
        }
        
        return chunks
    }
}

