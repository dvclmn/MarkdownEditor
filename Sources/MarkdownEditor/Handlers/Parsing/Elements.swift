//
//  Elements.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 2/9/2024.
//

import Foundation
import AppKit
import BaseHelpers
import STTextKitPlus
import TextCore


//extension MarkdownTextView: NSTextContentManagerDelegate {
//  func handleTextChange(in range: NSTextRange) {
//
//    let affectedElements = elements.filter { $0.range.content.intersects(range) }
//    
//    for element in affectedElements {
//      
//      print("This element was affected: \(element.syntax.name)")
////      if element.syntax == .inlineCode {
////        // Check if the change affects the end of the inline code
////        if affectedRange.location == element.range.trailing?.location {
////          // The backtick at the end was deleted
////          updateInlineCodeElement(element, newEndLocation: affectedRange.location)
////        }
////      }
//    }
//    
//    // After updating elements, trigger restyling
//    needsDisplay = true
//  }
//}




extension MarkdownTextView {
  
  
  func addMarkdownElement(_ element: Markdown.Element) {
    elements.append(element)
    needsDisplay = true
  }
  
  func removeElements(in range: NSTextRange) {
    
    let lastElementCount: Int = self.elements.count
    self.elements.removeAll(where: { $0.range.content.intersects(range)})
    
    let removedCount: Int = self.elements.count - lastElementCount
    
    print("Removed \(removedCount) elements.")
    
    
  }
  
  
  
  // Main function to update elements
//  func updateMarkdownElements(trigger: ChangeTrigger) {
//    switch trigger {
//      case .text:
//        incrementallyUpdateElements()
//      case .appeared, .scroll:
//        fullUpdateElements()
//    }
//  }
//  
//  // Full update of elements
//  private func fullUpdateElements() {
//    guard let string = self.string as NSString? else { return }
//    elements.removeAll()
//    
//    // Implement your full parsing logic here
//    // This is just a placeholder example
//    let fullRange = NSRange(location: 0, length: string.length)
//    parseMarkdownElements(in: fullRange)
//  }
//  
//  // Incremental update of elements
//  private func incrementallyUpdateElements() {
//    guard let selectedRange = self.selectedRanges.first as? NSRange else { return }
//    
//    // Find affected elements
//    let affectedElements = elements.filter { $0.range.intersects(selectedRange) }
//    
//    // Remove affected elements
//    elements.removeAll { affectedElements.contains($0) }
//    
//    // Re-parse the affected area
//    let extendedRange = NSUnionRange(selectedRange, NSRange(location: max(0, selectedRange.location - 10), length: selectedRange.length + 20))
//    parseMarkdownElements(in: extendedRange)
//    
//    // Sort elements if needed
//    elements.sort { $0.range.location < $1.range.location }
//  }
//  
//  // Parse markdown elements in a given range
//  private func parseMarkdownElements(in range: NSRange) {
//    guard let string = self.string as NSString? else { return }
//    
//    // Implement your parsing logic here
//    // This is just a placeholder example for headers
//    let pattern = "^(#{1,6})\\s+(.+)$"
//    do {
//      let regex = try NSRegularExpression(pattern: pattern, options: .anchorsMatchLines)
//      let matches = regex.matches(in: string as String, options: [], range: range)
//      
//      for match in matches {
//        let headerLevel = match.range(at: 1).length
//        let headerText = string.substring(with: match.range(at: 2))
//        let element = Markdown.Element(syntax: .heading(level: headerLevel),
//                                       range: Markdown.Range(content: match.range(at: 2),
//                                                             leading: match.range(at: 1),
//                                                             trailing: nil))
//        addMarkdownElement(element)
//      }
//    } catch {
//      print("Regex error: \(error)")
//    }
//  }
//  
  // Add a markdown element

}
