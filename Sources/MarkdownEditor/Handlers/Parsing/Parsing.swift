//
//  Parsing.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import AppKit

extension MarkdownTextView {
  
  func addElement(_ element: Markdown.Element) {
    elements.append(element)
    rangeIndex[element.range] = element
  }
  
  func removeElement(_ element: Markdown.Element) {
    elements.removeAll { $0 == element }
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
  
  func element(for range: NSTextRange) -> Markdown.Element? {
    return rangeIndex[range]
  }
  
  func addElements(_ newElements: [Markdown.Element]) {
    elements.append(contentsOf: newElements)
    for element in newElements {
      rangeIndex[element.range] = element
    }
  }
  
  func removeElements(_ elementsToRemove: [Markdown.Element]) {
    elements.removeAll { elementsToRemove.contains($0) }
    for element in elementsToRemove {
      rangeIndex.removeValue(forKey: element.range)
    }
  }
  
  // MARK: - Processing
  
  func processFullDocument(
    _ text: String,
    in range: NSTextRange? = nil
  ) async -> (result: Void, processingTime: Double)? {
    
    guard let tlm = self.textLayoutManager,
      let tcm = tlm.textContentManager
    else { return nil }
    
    let range = range ?? tlm.documentRange
    
    let time = await measureBackgroundTaskTime {
      
      self.parsingTask?.cancel()
      self.parsingTask = Task {
        
        // Clear existing elements
        self.elements.removeAll()
        self.rangeIndex.removeAll()
        
        let documentRange = tlm.documentRange
        
        //    var currentElement: Markdown.Element?
        var lineNumber = 0
        
        tcm.enumerateTextElements(from: documentRange.location) { textElement in
          guard let paragraph = textElement as? NSTextParagraph
                  //            let paragraphRange = paragraph.elementRange
                  //            let content = tcm.attributedString(in: paragraphRange)?.string
          else { return false }
          
          lineNumber += 1
          
          let syntaxList: [Markdown.Syntax] = [.codeBlock, .inlineCode]
          
          for syntax in syntaxList {
            
            let regex = syntax.regex
            
            guard let attributedString = tcm.attributedString(in: documentRange)
                    
            else { return false }
            
            let string = attributedString.string
            let fullRange = string.startIndex..<string.endIndex
            
            ///
            /// `using block: (String?, NSTextRange, NSTextRange?, UnsafeMutablePointer<ObjCBool>) -> Void`
            /// This is the enclosing range. Its meaning depends on the enumeration options:
            /// - For `.byWords`, it's the range of the enclosing word.
            /// - For `.byLines`, it's the range of the enclosing line.
            /// - For `.byParagraphs`, it's the range of the enclosing paragraph.
            /// - It can be nil if not applicable or if using `.byCharacters`.
            tlm.enumerateSubstrings(from: documentRange.location, options: .byWords) { subString, substringRange, enclosingRange, stop in
              
              guard let string = subString else {
                
                tlm.addRenderingAttribute(.foregroundColor, value: NSColor.red, for: enclosingRange ?? substringRange)
                return
              }
              
              
              
              if !string.isEmpty {
                
                tlm.addRenderingAttribute(.foregroundColor, value: NSColor.green, for: enclosingRange ?? substringRange)
                
                //            let element = Markdown.Element(type: .h1, range: enclosingRange ?? substringRange)
                //            self.addElement(element)
                
              } else {
                tlm.addRenderingAttribute(.foregroundColor, value: NSColor.orange, for: enclosingRange ?? substringRange)
              }
              
            }
            
          } // END syntax loop
          
          
          return true
          
        }
        
      } // END Task
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
