//
//  Parsing.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import AppKit
import Rearrange

extension MarkdownTextView {
  
//  static func createElement<S: MarkdownSyntax>(type: S, range: NSTextRange) -> AnyMarkdownElement {
//    switch type {
//      case let singleCapture as Markdown.SingleCaptureSyntax:
//        return Markdown.SingleCaptureElement(type: singleCapture, range: range)
//      case let doubleCapture as Markdown.DoubleCaptureSyntax:
//        return Markdown.DoubleCaptureElement(type: doubleCapture, range: range)
//      default:
//        fatalError("Unsupported syntax type")
//    }
//  }
//  
//  
  func addElement(_ element: Markdown.Element) {
    elements.append(element)
    rangeIndex[element.range] = element
  }
  
  func removeElement(_ element: Markdown.Element) {
    elements.removeAll { $0.range == element.range }
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
  
  func elementsInRange(_ range: NSTextRange) -> [Markdown.Element] {
    return elements.filter { $0.range.intersects(range) }
  }
  
  func element(for range: NSTextRange) -> (Markdown.Element)? {
    return rangeIndex[range]
  }
  
  func addElements(_ newElements: [Markdown.Element]) {
    elements.append(contentsOf: newElements)
    for element in newElements {
      rangeIndex[element.range] = element
    }
  }
  
  func removeElements(_ elementsToRemove: [Markdown.Element]) {
    elements.removeAll { element in
      elementsToRemove.contains { $0.range == element.range }
    }
    for element in elementsToRemove {
      rangeIndex.removeValue(forKey: element.range)
    }
  }
  
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
    
    let time = await measureBackgroundTaskTime {
      
      self.parsingTask?.cancel()
      
      self.parsingTask = Task {
        
        
        
        self.parsingTask = Task {
          self.elements.removeAll()
          self.rangeIndex.removeAll()
          
          let nsRange = NSRange(searchRange, provider: tcm)
          
          for syntax in Markdown.Syntax.testCases {
            
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
    
    guard let stringRange = range.range(in: self) else { return [] }
    
    var elements: [Markdown.Element] = []
    
//    let matches: (Substring, Substring) = self[stringRange].matches(of: syntax.regex)
    
    
    for match in self[stringRange].matches(of: syntax.regex) {
      let matchRange = match.range
      let matchStart = matchRange.lowerBound.utf16Offset(in: self)
      let matchLength = self.distance(from: matchRange.lowerBound, to: matchRange.upperBound)
      
      let offsetRange = NSRange(
        location: range.location + matchStart,
        length: matchLength
      )
      
      guard let textRange = NSTextRange(offsetRange, in: textContentManager) else { continue }
      
      let element = Markdown.Element(type: syntax, range: textRange)
      elements.append(element)
    }
    
    return elements

  
  
    
//    let matches = self[stringRange].matches(of: syntax.regex) { match in
//      let matchRange = NSRange(match.range, in: self)
//      let offsetRange = NSRange(location: matchRange.location + range.location, length: matchRange.length)
//      guard let textRange = NSTextRange(offsetRange, provider: textContentManager) else { return nil }
//      
//      return MarkdownTextView.createElement(type: syntax, range: textRange)
//    }
//    
//    return result
  }
}

