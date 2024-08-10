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
import APIHandler
//import Resizable

struct MarkdownExampleView: View {
    
    @State private var isStreaming: Bool = false
    
    @State private var text: String = ""
    //    @State private var text: String = TestStrings.Markdown.shortMarkdownBasics
    
    @State private var position = MarkdownEditor.Position()
    
    @State private var editorHeight: CGFloat = .zero
    @State private var editorWidth: CGFloat = 400
    @State private var editorMetrics: String = "nil"
    
    @FocusState private var isFocused
    
    @State private var isLoading: Bool = false
    
    @State private var isManualMode: Bool = false
    
    var body: some View {
        VStack {
            
            ScrollView(.vertical) {
                
                MarkdownEditor(
                    text: $text, 
                    position: $position,
                    width: editorWidth
                ) { metrics, height in
                    editorMetrics = metrics
                    editorHeight = height
                }
                .border(Color.green.opacity(0.3))
                .frame(height: editorHeight + 60)
            } // END scroll view
            
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
                    VStack(alignment: .leading) {
                        Text("\(editorMetrics)")
                        Text("Height: \(editorHeight.formatted())")
                        Text("Width: \(editorWidth.formatted())")
                    }
                    .padding()
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


//public struct PerformanceWidget: View {
//    @ObservedObject public var metrics = PerformanceMetrics.shared
//    
//    public init(
//        metrics: PerformanceMetrics = PerformanceMetrics.shared
//    ) {
//        self.metrics = metrics
//    }
//    
//    public var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text("Performance Metrics")
//                .font(.headline)
//            
//            ForEach(metrics.metrics.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
//                HStack {
//                    Text(key)
//                    Spacer()
//                    Text("\(value)")
//                }
//            }
//            
//            Divider()
//            
//            Text("Timings")
//                .font(.headline)
//            
//            ForEach(metrics.timings.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
//                HStack {
//                    Text(key)
//                    Spacer()
//                    Text(String(format: "%.4f s", value))
//                }
//            }
//        }
//        .padding()
//        .background(Color.gray.opacity(0.1))
//        .cornerRadius(10)
//        .frame(width: 250)
//    }
//}

