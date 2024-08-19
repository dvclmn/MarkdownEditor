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

@testable import MarkdownEditor

enum LogLevel: String {
  case debug, info, warning, error, success
}


class Logger {
  static func log(_ items: Any..., level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
    let filename = URL(fileURLWithPath: file).lastPathComponent
    let prefix: String
    let color: ANSIColors
    
    switch level {
      case .debug:
        prefix = "🔍 DEBUG"
        color = .cyan
      case .info:
        prefix = "ℹ️ INFO"
        color = .blue
      case .warning:
        prefix = "⚠️ WARNING"
        color = .yellow
      case .error:
        prefix = "🚫 ERROR"
        color = .red
      case .success:
        prefix = "✅ SUCCESS"
        color = .green
    }
    
    let message = items.map { String(describing: $0) }.joined(separator: " ")
    formattedPrint("\(prefix) [\(filename):\(line)] \(function):", terminator: " ", textColor: color)
    print(message)
  }
}




enum ANSIColors: String {
  case black = "\u{001B}[0;30m"
  case red = "\u{001B}[0;31m"
  case green = "\u{001B}[0;32m"
  case yellow = "\u{001B}[0;33m"
  case blue = "\u{001B}[0;34m"
  case magenta = "\u{001B}[0;35m"
  case cyan = "\u{001B}[0;36m"
  case white = "\u{001B}[0;37m"
  case reset = "\u{001B}[0;0m"
  
  case bgBlack = "\u{001B}[40m"
  case bgRed = "\u{001B}[41m"
  case bgGreen = "\u{001B}[42m"
  case bgYellow = "\u{001B}[43m"
  case bgBlue = "\u{001B}[44m"
  case bgMagenta = "\u{001B}[45m"
  case bgCyan = "\u{001B}[46m"
  case bgWhite = "\u{001B}[47m"
  
  case bold = "\u{001B}[1m"
  case underline = "\u{001B}[4m"
}

func coloredPrint(_ items: Any..., separator: String = " ", terminator: String = "\n", color: ANSIColors) {
  let output = items.map { "\(color.rawValue)\($0)\(ANSIColors.reset.rawValue)" }.joined(separator: separator)
  print(output, terminator: terminator)
}

func formattedPrint(_ items: Any..., separator: String = " ", terminator: String = "\n", textColor: ANSIColors? = nil, backgroundColor: ANSIColors? = nil, formatting: ANSIColors? = nil) {
  var formatString = ""
  if let textColor = textColor { formatString += textColor.rawValue }
  if let backgroundColor = backgroundColor { formatString += backgroundColor.rawValue }
  if let formatting = formatting { formatString += formatting.rawValue }
  
  let output = items.map { "\(formatString)\($0)\(ANSIColors.reset.rawValue)" }.joined(separator: separator)
  print(output, terminator: terminator)
}

func logInfo(_ items: Any...) {
  formattedPrint("ℹ️ INFO:", terminator: " ")
  formattedPrint(items, textColor: .blue)
}

func logWarning(_ items: Any...) {
  formattedPrint("⚠️ WARNING:", terminator: " ")
  formattedPrint(items, textColor: .yellow)
}

func logError(_ items: Any...) {
  formattedPrint("🚫 ERROR:", terminator: " ")
  formattedPrint(items, textColor: .red)
}

func logSuccess(_ items: Any...) {
  formattedPrint("✅ SUCCESS:", terminator: " ")
  formattedPrint(items, textColor: .green)
}

func logDebug(_ items: Any...) {
  formattedPrint("🔍 DEBUG:", terminator: " ")
  formattedPrint(items, textColor: .cyan)
}

@MainActor @Suite("MarkdownTextView tests")
struct MarkdownTextViewTests {
  
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
  
  

  @Test("Adding markdown content parses elements and measures performance")
  func addingContentParsesElementsAndMeasuresPerformance() async throws {

    let textView = MarkdownTextView(frame: .zero, textContainer: nil)
    
    textView.string = """
    # Header
    
    This is **bold** text.
    """
    
    textView.setupViewportLayoutController()
    
    try await Task.sleep(for: .seconds(0.1))
    
    let duration = try await measurePerformance {
      await textView.runMainMarkdownParse()
    }
    
    let averageDuration = try await measureAveragePerformance(iterations: 10) {
      await textView.runMainMarkdownParse()
    }
    
    print("Average parse duration: \(averageDuration) seconds")
    
    coloredPrint("This is a red message", color: .red)
    coloredPrint("This is a green message", color: .green)
    coloredPrint("This is a blue message", color: .blue)
    
    formattedPrint("This is bold red text on a yellow background", textColor: .red, backgroundColor: .bgYellow, formatting: .bold)
    
    logInfo("This is an informational message")
    logWarning("This is a warning message")
    logError("This is an error message")
    logSuccess("This operation completed successfully")
    logDebug("Here's some debug information")
    
    Logger.log("Starting operation", level: .info)
    Logger.log("Operation completed", level: .success)
    Logger.log("An error occurred", level: .error)
    
    #expect(!textView.elements.isEmpty)
    #expect(textView.elements.count == 2)
    #expect(textView.elements[0].type == .heading(level: 1))
    #expect(textView.elements[1].type == .bold(style: .asterisk))
    
    // Performance assertion
    #expect(duration < 1.0, "Parsing took too long")
  }
  
}
