//
//  Parsing.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import SwiftUI



extension MarkdownTextView {
  
  
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
  
  /// Example usage:
  /// ```
  ///    Task {
  ///
  ///      do {
  ///        try await Task.sleep(for: .seconds(0.4))
  ///
  ///        self.processingTime = await self.processFullDocumentWithTiming(self.string)
  ///      } catch {
  ///
  ///      }
  ///    }
  /// ```
  ///
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
      
      processAllMarkdownBlocks()
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
  
  func processAllMarkdownBlocks(highlight: Bool = false) {
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager,
          let tcs = self.textContentStorage else { return }
    
    let documentRange = tlm.documentRange
    
    var currentBlock: MarkdownBlock?
    var lineNumber = 0
    
    tcm.enumerateTextElements(from: documentRange.location) { textElement in
      guard let paragraph = textElement as? NSTextParagraph,
            let paragraphRange = paragraph.elementRange,
            let content = tcm.attributedString(in: paragraphRange)?.string
      else { return false }
      
      lineNumber += 1
      
      /// Identify code block opening
      /// Three backticks, ignore leading whitespace
      ///
      
      
      return true
      
    }
   
  }
}

