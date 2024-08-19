//
//  Parsing.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import AppKit
import Rearrange

extension MarkdownTextView {
  
  func addElement<S: MarkdownSyntax>(_ element: Markdown.Element<S>) {
    elements.append(element)
    rangeIndex[element.range] = element
  }
  
  func removeElement<S: MarkdownSyntax>(_ element: Markdown.Element<S>) {
    elements.removeAll { $0 as? Markdown.Element<S> == element }
    rangeIndex.removeValue(forKey: element.range)
  }

  func updateElementRange(for elementRange: NSTextRange, newRange: NSTextRange) {
    if let index = elements.firstIndex(where: { $0.range == elementRange }) {
      var updatedElement = elements[index]
      updatedElement.range = newRange
      elements[index] = updatedElement
      
      rangeIndex.removeValue(forKey: elementRange)
      rangeIndex[newRange] = updatedElement
    }
  }
  
//  func elementsInRange(_ range: NSTextRange) -> [any Markdown.Element] {
//    return elements.filter { $0.range.intersects(range) }
//  }
//  
//  func element(for range: NSTextRange) -> Markdown.Element? {
//    return rangeIndex[range]
//  }
//  
//  func addElements(_ newElements: [Markdown.Element]) {
//    elements.append(contentsOf: newElements)
//    for element in newElements {
//      rangeIndex[element.range] = element
//    }
//  }
//  
//  func removeElements(_ elementsToRemove: [Markdown.Element]) {
//    elements.removeAll { elementsToRemove.contains($0) }
//    for element in elementsToRemove {
//      rangeIndex.removeValue(forKey: element.range)
//    }
//  }
  
  // MARK: - Processing
  
  func applyMarkdownStyles() async -> (result: Void, processingTime: Double)? {
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager,
          let viewportRange = tlm.textViewportLayoutController.viewportRange
    else { return nil }
    
    let time = await measureBackgroundTaskTime {
      
      self.parsingTask?.cancel()
      
      self.parsingTask = Task {
        
        tcm.performEditingTransaction {
          
          for element in self.elements {
            
            tlm.setRenderingAttributes(element.type.contentAttributes, for: element.range)
            
          }
          
        } // END perform editing
      } // END task
      
    }
    
    return ((), time)
  }
  
  
  
  
  
  func parseMarkdown(
    in range: NSTextRange? = nil
  ) async -> (result: Void, processingTime: Double)? {
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager
    else { return nil }
    
    let searchRange = range ?? tlm.documentRange
    //    let syntaxList: [Markdown.Syntax] = [
    //      .inlineCode,
    //      .codeBlock
    //    ]
    
    let time = await measureBackgroundTaskTime {
      
      self.parsingTask?.cancel()
      
      self.parsingTask = Task {
        
        
        
        self.parsingTask = Task {
          self.elements.removeAll()
          self.rangeIndex.removeAll()
          
          let nsRange = NSRange(searchRange, provider: tcm)
          
          for syntax in Markdown.Syntax.all {
            let newElements = self.string.markdownMatches(of: syntax, in: nsRange, textContentManager: tcm)
            newElements.forEach { self.addElement($0) }
          }
          
          self.elements.sort { $0.range.location.compare($1.range.location) == .orderedAscending }
        }
        
        
      }
      
      
      
      await self.parsingTask?.value
    }
    
    return ((), time)
    
  }
  
  //  func processRange(_ range: NSTextRange, in text: String) async {
  //    let parser = MarkdownParser() // You'd need to implement this
  //    let newBlocks = try? await parser.parse(text, in: range)
  
  //    if let newBlocks = newBlocks, !Task.isCancelled {
  //      for element in newBlocks {
  //        if let existingBlock = rangeIndex[element.range] {
  //          updateBlockRange(existingBlock, newRange: element.range)
  //        } else {
  //          addBlock(element)
  //        }
  //      }
  //    }
  //  }
  
  // MARK: - Viewport Handling
  
  //  func getBlocksForViewport(_ range: NSTextRange) async -> [MarkdownElement] {
  //    return elementsInRange(range)
  //  }
}

//func countCodeBlocks() -> Int {
//
//  let codeblocks = self.markdownBlocks.filter { $0.syntax == .codeBlock }
//
//  return codeblocks.count
//
//}

//func getMarkdownElement(for range: NSTextRange) -> MarkdownElement? {
//  guard let currentBlock = self.markdownBlocks.first(where: { $0.range.intersects(range) }) else { return nil }
//  return currentBlock
//}


extension String {
  @MainActor
  func markdownMatches(
    of syntax: Markdown.Syntax,
    in range: NSRange,
    textContentManager: NSTextContentManager
  ) -> [Markdown.Element] {
    
    guard let stringRange = range.range(in: self)
    else { return [] }
    
    return self[stringRange].matches(of: syntax.regex).compactMap { match in
      
      let matchRange = NSRange(match.range, in: self)
      let offsetRange = NSRange(location: matchRange.location + range.location, length: matchRange.length)
      guard let textRange = NSTextRange(offsetRange, provider: textContentManager) else { return nil }
      return Markdown.Element(type: syntax, range: textRange)
      
    } // END loop over matches
  }
}

