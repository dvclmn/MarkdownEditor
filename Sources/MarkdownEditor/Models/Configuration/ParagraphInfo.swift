//
//  ParagraphInfo.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 17/9/2024.
//

//import AppKit
//import BaseHelpers
//import Rearrange

//@MainActor
//public struct ParagraphHandler: Sendable {
//  
//  public var currentParagraph: ParagraphInfo
//  public var previousParagraph: ParagraphInfo
//  
//  public init() {
//    self.currentParagraph = .zero
//    self.previousParagraph = .zero
//  }
//}
//
//
//public struct ParagraphInfo: Sendable {
//  public var string: String
//  public var range: NSRange
//  public var type: BlockSyntax
//  
//  public init(
//    string: String = "",
//    range: NSRange = .zero,
//    type: BlockSyntax = .none
//  ) {
//    self.string = string
//    self.range = range
//    self.type = type
//  }
//}
//
//extension ParagraphInfo {
//  public static let zero = ParagraphInfo()
//}
//
//extension ParagraphInfo: CustomStringConvertible {
//  public var description: String {
//    
//    // - Selected: \(Date.now.friendlyDateAndTime)
//    let output: String = """
//    
//      - Range: \\(range.info)
//      - Type: \(type)
//      - String: \(string.trimmingCharacters(in: .whitespacesAndNewlines).preview(40))
//    """
//    
//    return output
//  }
//}
//
//
