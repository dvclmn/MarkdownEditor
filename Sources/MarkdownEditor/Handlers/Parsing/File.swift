//
//  File.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 20/8/2024.
//

import AppKit


extension MarkdownTextView {
  
//  func addElement(_ element: Markdown.Element) {
//    elements.append(element)
//    rangeIndex[element.range] = element
//  }
//  
//  func removeElement(_ element: Markdown.Element) {
//    elements.removeAll { $0.range == element.range }
//    rangeIndex.removeValue(forKey: element.range)
//  }
//  
//  
//  
//  func updateElementRange(for elementRange: NSTextRange, newRange: NSTextRange) {
//    if let index = elements.firstIndex(where: { $0.range == elementRange }) {
//      var updatedElement = elements[index]
//      updatedElement.range = newRange
//      elements[index] = updatedElement
//      
//      rangeIndex.removeValue(forKey: elementRange)
//      rangeIndex[newRange] = updatedElement
//    }
//  }
//  
//  func elementsInRange(_ range: NSTextRange) -> [Markdown.Element] {
//    return elements.filter { $0.range.intersects(range) }
//  }
//  
//  func element(for range: NSTextRange) -> (Markdown.Element)? {
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
//    elements.removeAll { element in
//      elementsToRemove.contains { $0.range == element.range }
//    }
//    for element in elementsToRemove {
//      rangeIndex.removeValue(forKey: element.range)
//    }
//  }
}
