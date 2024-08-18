//
//  Parsing.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import AppKit

extension MarkdownTextView {
  
  
  // MARK: - Document Structure
//  
  func addElement(_ element: Markdown.Element) {
    elements.append(element)
    rangeIndex[element.range] = element
  }
  
  func removeElement(_ element: Markdown.Element) {
    elements.removeAll { $0 == element }
    rangeIndex.removeValue(forKey: element.range)
  }
  
//  func updateBlockRange(_ element: Markdown.Element, newRange: NSTextRange) {
//    rangeIndex.removeValue(forKey: element.range)
//    element.range = newRange
//    rangeIndex[newRange] = element
//  }
//  
  func elementsInRange(_ range: NSTextRange) -> [Markdown.Element] {
    return elements.filter { $0.range.intersects(range) }
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
      // Clear existing elements
      elements.removeAll()
      rangeIndex.removeAll()
      
      processAllMarkdownElements()
      // Parse the entire document
      //      let parser = MarkdownParser() // You'd need to implement this
      //      let newBlocks = try? await parser.parse(text)
      
      //      if let newBlocks = newBlocks, !Task.isCancelled {
      //        for element in newBlocks {
      //          addBlock(element)
      //        }
      //      }
    }
    await processingTask?.value
  }
  
  func processRange(_ range: NSTextRange, in text: String) async {
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
  }
  
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

extension MarkdownTextView {
  
  func processAllMarkdownElements(highlight: Bool = false) {
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager
//          let tcs = self.textContentStorage
    else { return }
    
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
   
  } // END process all markdown
  
  func parseMarkdown(in text: String) -> [Markdown.Element] {
    var elements: [Markdown.Element] = []
    let fullRange = text.startIndex..<text.endIndex

    
    // Find all ranges matching the regex
    let headerRanges = text.ranges(of: Markdown.Syntax.h1.regex)
    
//    for range in headerRanges {
//      if let nsRange = NSRange(range, in: text) {
//        let nsTextRange = NSTextRange(nsRange)!
//        let headerLevel = text[range].starts(with: "######") ? 6 :
//        text[range].starts(with: "#####") ? 5 :
//        text[range].starts(with: "####") ? 4 :
//        text[range].starts(with: "###") ? 3 :
//        text[range].starts(with: "##") ? 2 : 1
//        let element = Markdown.Element(type: .header(level: headerLevel), range: nsTextRange)
//        elements.append(element)
//      }
//    }
    
    // Use enumerateSubstrings for additional parsing if needed
//    text.enumerateSubstrings(in: fullRange, options: .byParagraphs) { (substring, substringRange, _, _) in
//      if let substring = substring, !headerRanges.contains(where: { $0.overlaps(substringRange) }) {
//        if let nsRange = NSRange(substringRange, in: text) {
//          let nsTextRange = NSTextRange(nsRange)!
//          let element = Markdown.Element(type: .paragraph, range: nsTextRange)
//          elements.append(element)
//        }
//      }
//    }
    
    return elements
  }
}

