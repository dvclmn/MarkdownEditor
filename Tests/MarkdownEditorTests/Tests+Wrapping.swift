//
//  Wrapping.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 9/9/2024.
//

//import Testing
//import Foundation
//
//@testable import MarkdownEditor
//
//@MainActor @Suite("Wrapping tests")
//struct WrappingTests {
//  
//  let textView = MarkdownTextView(
//    frame: .zero,
//    textContainer: nil,
////    action: Markdown.SyntaxAction(syntax: .bold),
//    configuration: .init()
//  )
//  
//  let exampleString = """
//    # Header
//    
//    This is **bold** text.
//    """
//  let exampleString02 = "This has some **bold** text."
//  
//  @Test("Wrap text with bold syntax", arguments:
////    Markdown.Syntax.allCases
//        [Markdown.Syntax.bold]
//  )
//  
//  func testWrapping(for syntax: Markdown.Syntax) throws {
//    
//    textView.string = "Hello, world!"
//    textView.setSelectedRange(NSRange(location: 0, length: 5))
//    
//    for shortcut in syntax.shortcuts {
//      textView.handleWrapping(.wrap, for: syntax)
//    }
//    
//    #expect(textView.string == "**Hello**, world!")
//    #expect(textView.selectedRange() == NSRange(location: 2, length: 5))
//    
////    #expect(
////      wrappedString.hasPrefix(
////        String(
////          repeating: "\(syntax.leadingCharacter)" ?? "",
////          count: syntax.leadingCharacterCount ?? 0
////        )
////      )
////    )
////    #expect(
////      wrappedString.hasSuffix(
////        String(
////          repeating: "\(syntax.trailingCharacter)" ?? "",
////          count: syntax.trailingCharacterCount ?? 0
////        )
////      )
////    )
////    #expect(wrappedRange.location == (syntax.leadingCharacterCount ?? 0))
////    #expect(wrappedRange.length == testString.count)
//    
//    
//  }
//  
//  
//}
