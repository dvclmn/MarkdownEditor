//
//  Parsing.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import SwiftUI

actor MarkdownParser {
  private var blocks: [MarkdownBlock] = []
  private var rangeIndex: [NSTextRange: MarkdownBlock] = [:]
  private var processingTask: Task<Void, Never>?
  
  // MARK: - Document Structure
  
  func addBlock(_ block: MarkdownBlock) {
    blocks.append(block)
    rangeIndex[block.range] = block
  }
  
  func removeBlock(_ block: MarkdownBlock) {
    blocks.removeAll { $0 === block }
    rangeIndex.removeValue(forKey: block.range)
  }
  
  func updateBlockRange(_ block: MarkdownBlock, newRange: NSTextRange) {
    rangeIndex.removeValue(forKey: block.range)
    block.range = newRange
    rangeIndex[newRange] = block
  }
  
  func blocksInRange(_ range: NSTextRange) -> [MarkdownBlock] {
    return blocks.filter { $0.range.intersects(range) }
  }
  
  // MARK: - Processing
  
  func processFullDocumentWithTiming(_ text: String) async -> Double {
    return await measureBackgroundTaskTime {
      await self.processFullDocument(text)
    }
  }
  
  
  func processFullDocument(_ text: String) async {
    processingTask?.cancel()
    processingTask = Task {
      // Clear existing blocks
      blocks.removeAll()
      rangeIndex.removeAll()
      
      // Parse the entire document
      //      let parser = MarkdownParser() // You'd need to implement this
      //      let newBlocks = try? await parser.parse(text)
      
      //      if let newBlocks = newBlocks, !Task.isCancelled {
      //        for block in newBlocks {
      //          addBlock(block)
      //        }
      //      }
    }
    await processingTask?.value
  }
  
  func processRange(_ range: NSTextRange, in text: String) async {
    //    let parser = MarkdownParser() // You'd need to implement this
    //    let newBlocks = try? await parser.parse(text, in: range)
    
    //    if let newBlocks = newBlocks, !Task.isCancelled {
    //      for block in newBlocks {
    //        if let existingBlock = rangeIndex[block.range] {
    //          updateBlockRange(existingBlock, newRange: block.range)
    //        } else {
    //          addBlock(block)
    //        }
    //      }
    //    }
  }
  
  // MARK: - Viewport Handling
  
  func getBlocksForViewport(_ range: NSTextRange) async -> [MarkdownBlock] {
    return blocksInRange(range)
  }
}

//func countCodeBlocks() -> Int {
//
//  let codeblocks = self.markdownBlocks.filter { $0.syntax == .codeBlock }
//
//  return codeblocks.count
//
//}

//func getMarkdownBlock(for range: NSTextRange) -> MarkdownBlock? {
//  guard let currentBlock = self.markdownBlocks.first(where: { $0.range.intersects(range) }) else { return nil }
//  return currentBlock
//}

extension MarkdownTextView {
  
  func processMarkdownBlocks(highlight: Bool = false) -> [MarkdownBlock] {
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager,
          let tcs = self.textContentStorage else {
      return []
    }
    
    let documentRange = tlm.documentRange
    var markdownBlocks: [MarkdownBlock] = []
    var currentCodeBlock: MarkdownBlock?
    
    /// Basics: Enumerating over the text elements provides the opportunity to work with
    /// each and every `NSTextElement` that matches any filtering performed in
    /// the `block` closure. (see: `{ textElement in`).
    ///
    /// For parameter `textLocation`, I've explicitly
    /// supplied `documentRange.location`, which also happens to be the default value.
    ///
    /// The return type for `block` is `Bool`; provide `false` to stop enumerating
    ///
    /// Example:
    /// ```
    /// tcm.enumerateTextElements { element in
    ///   if element.property == something {
    ///     // do things
    ///     return true
    ///   } else {
    ///     return false
    ///   }
    /// }
    /// ```
    tcm.enumerateTextElements(from: documentRange.location, options: []) { textElement in
      guard let paragraph = textElement as? NSTextParagraph,
            let paragraphRange = paragraph.elementRange,
            let content = tcm.attributedString(in: paragraphRange)?.string else {
        return true
      }
      
      if content.hasPrefix("```") {
        if let currentBlock = currentCodeBlock {
          currentBlock.isComplete = true
          if let fullRange = NSTextRange(location: currentBlock.range.location, end: paragraphRange.endLocation) {
            currentBlock.range = fullRange
          }
          markdownBlocks.append(currentBlock)
          currentCodeBlock = nil
        } else {
          currentCodeBlock = MarkdownBlock(tcm, range: paragraphRange, syntax: .codeBlock, isComplete: false)
        }
      }
      
      return true
    }
    
    // Handle case where document ends without closing code block
    if let currentBlock = currentCodeBlock {
      markdownBlocks.append(currentBlock)
    }
    
    if highlight {
      for block in markdownBlocks where block.syntax == .codeBlock {
        
        self.addStyle(for: block)
        
      }
    }
    
    return markdownBlocks
  }
}

//public class MarkdownParser {
//  var elements: [MarkdownFragment] = []
//  var visibleElements: [MarkdownFragment] = []
//
//  public var text: String {
//    didSet {
//      updateElements()
//    }
//  }

//  public var visibleRange: NSRange {
//    didSet {
//      updateVisibleElements()
//    }
//  }
//
//  init(text: String = "") {
//    self.text = text
//    self.visibleRange = NSRange(location: 0, length: 0)
//    updateElements()
//  }

//  private func updateElements() {
// Parse the entire text and update the elements array
// This would involve your Markdown parsing logic
//  }

//  private func updateVisibleElements() {
//    visibleElements = elements.filter { NSIntersectionRange($0.range, visibleRange).length > 0 }
//  }
//
//  public func elementsInRange(_ range: NSRange) -> [MarkdownFragment] {
//    return elements.filter { NSIntersectionRange($0.range, range).length > 0 }
//  }
//
//  public func elementAt(_ location: Int) -> MarkdownFragment? {
//    return elements.first { NSLocationInRange(location, $0.range) }
//  }

//  public func applyStyle(for element: MarkdownFragment) -> [NSAttributedString.Key: Any] {
//    // Return appropriate style attributes based on the element
//
//    return [:]
//  }
//
//  public func toggleSyntax(_ syntax: Markdown.Syntax, in range: NSRange) {
//    // Logic to add or remove syntax in the given range
//  }
//}



//class MarkdownParser {
//  // MARK: - Parsing Methods
//
//  func parse(_ text: String) async throws -> [MarkdownBlock] {
//    // Parse the entire document
//  }
//
//  func parse(_ text: String, in range: NSTextRange) async throws -> [MarkdownBlock] {
//    // Parse a specific range within the document
//  }
//}

// MARK: - Block-Level Parsing
//
//  private func parseHeadings(_ line: String) -> MarkdownBlock?
//  private func parseLists(_ lines: [String]) -> MarkdownBlock?
//  private func parseCodeBlocks(_ lines: [String]) -> MarkdownBlock?
//  private func parseBlockquotes(_ lines: [String]) -> MarkdownBlock?
//  private func parseParagraphs(_ lines: [String]) -> MarkdownBlock?
//
//  // MARK: - Inline Parsing
//
//  private func parseInlineElements(_ text: String) -> [InlineElement]
//  private func parseEmphasis(_ text: String) -> [InlineElement]
//  private func parseLinks(_ text: String) -> [InlineElement]
//  private func parseInlineCode(_ text: String) -> [InlineElement]
//
//  // MARK: - Utility Methods
//
//  private func splitIntoLines(_ text: String) -> [String]
//  private func identifyBlockType(_ line: String) -> BlockType
//  private func mergeAdjacentBlocks(_ blocks: [MarkdownBlock]) -> [MarkdownBlock]
//}
//
//enum BlockType {
//  case heading(level: Int)
//  case paragraph
//  case list(type: ListType)
//  case codeBlock
//  case blockquote
//  // ... other block types ...
//}
//
//enum ListType {
//  case unordered
//  case ordered
//}
//
//struct InlineElement {
//  let range: NSRange
//  let type: InlineElementType
//}
//
//enum InlineElementType {
//  case bold
//  case italic
//  case link(url: String)
//  case code
//  // ... other inline types ...
//}



//
//  func parseInlineCode() {
//    guard let textContentManager = self.textLayoutManager?.textContentManager else { return }
//
//    inlineCodeElements.removeAll()
//
////    let fullRange = NSRange(location: 0, length: string.utf16.count)
//    let regex = Markdown.Syntax.inlineCode.regex
//
//    regex.
//
//    regex.enumerateMatches(in: string, options: [], range: fullRange) { match, _, _ in
//      if let matchRange = match?.range {
//        let element = InlineCodeElement(range: matchRange)
//        inlineCodeElements.append(element)
//
//        textContentManager.performEditingTransaction {
//          textContentManager.addTextElement(element, for: NSTextRange(matchRange, in: textContentManager))
//        }
//      }
//    }
//
//    print("Found \(inlineCodeElements.count) inline code elements")
//  }
//
//

