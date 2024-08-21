//
//  File.swift
//
//
//  Created by Dave Coleman on 11/8/2024.
//

import Foundation
import SwiftUI
import Testing
import XCTest
import Logging

@testable import MarkdownEditor

@MainActor @Suite("MarkdownTextView tests")

struct MarkdownTextViewTests {
  
  let textView = MarkdownTextView(frame: .zero, textContainer: nil)
  let exampleString = """
    # Header
    
    This is **bold** text.
    """
  let exampleString02 = "This has some **bold** text."
  
  func measurePerformance(_ operation: () async throws -> Void) async throws -> TimeInterval {
    let startTime = Date()
    try await operation()
    return Date().timeIntervalSince(startTime)
  }
  
  func measureAveragePerformance(iterations: Int, _ operation: () async throws -> Void) async throws -> TimeInterval {
    var totalDuration: TimeInterval = 0
    
    for _ in 0..<iterations {
      let startTime = Date()
      try await operation()
      totalDuration += Date().timeIntervalSince(startTime)
    }
    
    return totalDuration / Double(iterations)
  }
  
  @Test(
    "Adding markdown content parses elements and measures performance",
    .disabled()
  )
  func addingContentParsesElementsAndMeasuresPerformance() async throws {
    
    
    
    textView.string = exampleString
    
    textView.setupViewportLayoutController()
    
    try await Task.sleep(for: .seconds(0.1))
    
    let duration = try await measurePerformance {
      await textView.runMainMarkdownParse()
    }
    
    let averageDuration = try await measureAveragePerformance(iterations: 10) {
      await textView.runMainMarkdownParse()
    }
    
    print("Average parse duration: \(averageDuration) seconds")
    
//    printCollection(textView.elements, keyPaths: [\.type, \.range])
    
    #expect(!textView.elements.isEmpty)
//    #expect(textView.elements.count == 2)
//    #expect(textView.elements[0].type == .heading(level: 1))
//    #expect(textView.elements[1].type == .bold(style: .asterisk))
    
    // Performance assertion
    #expect(duration < 1.0, "Parsing took too long")
  }
  
}


