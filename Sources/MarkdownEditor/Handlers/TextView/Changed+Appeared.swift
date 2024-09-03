//
//  Changed+Appeared.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import SwiftUI
//import Rearrange
//import STTextKitPlus

extension MarkdownTextView {
  
  public override func viewDidMoveToSuperview() {
    super.viewDidMoveToSuperview()
    
    setupScrollObservation()
  }
  
  public override func viewDidMoveToWindow() {
    
    super.viewDidMoveToWindow()
    
    
    setupViewportLayoutController()
    
    
    //    self.parseAndStyleMarkdownLite(trigger: .appeared)
    
    //    self.styleElements(trigger: .appeared)
    
    Task { @MainActor in
      let heightUpdate = self.updateEditorHeight()
      await self.infoHandler.update(heightUpdate)
    }
    
    exploreTextSegments()
    
    
  }
  

  
  func exploreTextSegments() {
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager
    else { return }
    
    
    tcm.performEditingTransaction {
      
      tlm.enumerateTextLayoutFragments(from: tlm.documentRange.location) { fragment in
        guard let paragraph = fragment.textElement as? NSTextParagraph else { return true }
        
        styleParagraph(paragraph, textLayoutManager: tlm)
        
        return true
      }
      
//      tlm.enumerateTextLayoutFragments(from: tlm.documentRange.location) { fragment in
//        
//        guard let paragraph = fragment.textElement as? NSTextParagraph else { return false }
//        
//        let string = paragraph.attributedString.string
//        
//        guard let paragraphRange = paragraph.elementRange,
//              let nsRange = tcm.range(for: paragraphRange)
//                
//        else {
//          print("Returned false: \(string)")
//          return false
//        }
//        
//        if string.contains("`") {
//          
//        }
//        
//        print("NSRange: \(nsRange), preview: \(string.preview(10))")
//
//        
//        return true
//        
//      } // END enumerate fragments
//      
    } // END perform edit
  }
  
  
  func setupScrollObservation() {
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleScrollViewDidScroll),
      name: NSView.boundsDidChangeNotification,
      object: enclosingScrollView?.contentView
    )
    
  }
  
  
}


extension NSTextContentManager {
  func range(for textRange: NSTextRange) -> NSRange? {
    let location = offset(from: documentRange.location, to: textRange.location)
    let length = offset(from: textRange.location, to: textRange.endLocation)
    if location == NSNotFound || length == NSNotFound { return nil }
    return NSRange(location: location, length: length)
  }
  
  func textRange(for range: NSRange) -> NSTextRange? {
    guard let textRangeLocation = location(documentRange.location, offsetBy: range.location),
          let endLocation = location(textRangeLocation, offsetBy: range.length) else { return nil }
    return NSTextRange(location: textRangeLocation, end: endLocation)
  }
}


extension MarkdownTextView {
  
  
  func styleParagraph(_ paragraph: NSTextParagraph, textLayoutManager: NSTextLayoutManager) {
    guard let range = paragraph.elementRange else { return }
    let string = paragraph.attributedString.string
    
    var currentIndex = range.location
    let endIndex = range.endLocation
    
    while currentIndex < endIndex {
      
      
//      if let (syntaxRange, syntax) = findNextSyntax(from: currentIndex, in: string, endIndex: endIndex) {
      textLayoutManager.setRenderingAttributes(Markdown.Syntax.inlineCode.contentRenderingAttributes, for: range)
//        currentIndex = syntaxRange.endLocation
//      } else {
//        break
//      }
    }
  }
  
//  func findNextSyntax(from startLocation: NSTextLocation, in string: String, endIndex: NSTextLocation) -> (NSTextRange, Markdown.Syntax)? {
//    var currentIndex = startLocation
//    while currentIndex < endIndex {
//      let character = string[string.index(string.startIndex, offsetBy: textLayoutManager.offset(from: range.location, to: currentIndex))]
//      
//      switch character {
//        case "`":
//          if let endLocation = findClosingCharacter("`", from: currentIndex, in: string, endIndex: endIndex) {
//            return (NSTextRange(location: currentIndex, end: endLocation), .inlineCode)
//          }
//        case "*":
//          if let endLocation = findClosingCharacter("*", from: currentIndex, in: string, endIndex: endIndex) {
//            return (NSTextRange(location: currentIndex, end: endLocation), .italic)
//          }
//        case "~":
//          if let endLocation = findClosingPair("~~", from: currentIndex, in: string, endIndex: endIndex) {
//            return (NSTextRange(location: currentIndex, end: endLocation), .strikethrough)
//          }
//        default:
//          break
//      }
//      
//      currentIndex = textLayoutManager.location(currentIndex, offsetBy: 1)
//    }
//    return nil
//  }
  
//  func findClosingCharacter(_ character: Character, from startLocation: NSTextLocation, in string: String, endIndex: NSTextLocation) -> NSTextLocation? {
//    var currentIndex = textLayoutManager.location(startLocation, offsetBy: 1)
//    while currentIndex < endIndex {
//      let currentChar = string[string.index(string.startIndex, offsetBy: textLayoutManager.offset(from: range.location, to: currentIndex))]
//      if currentChar == character {
//        return textLayoutManager.location(currentIndex, offsetBy: 1)
//      }
//      currentIndex = textLayoutManager.location(currentIndex, offsetBy: 1)
//    }
//    return nil
//  }
//  
//  func findClosingPair(_ pair: String, from startLocation: NSTextLocation, in string: String, endIndex: NSTextLocation) -> NSTextLocation? {
//    var currentIndex = textLayoutManager.location(startLocation, offsetBy: pair.count)
//    while currentIndex < endIndex {
//      let endOfPairIndex = textLayoutManager.location(currentIndex, offsetBy: pair.count)
//      if endOfPairIndex <= endIndex {
//        let range = NSTextRange(location: currentIndex, end: endOfPairIndex)
//        let substring = string[string.index(string.startIndex, offsetBy: textLayoutManager.offset(from: range.location, to: currentIndex))..<string.index(string.startIndex, offsetBy: textLayoutManager.offset(from: range.location, to: endOfPairIndex))]
//        if substring == pair {
//          return endOfPairIndex
//        }
//      }
//      currentIndex = textLayoutManager.location(currentIndex, offsetBy: 1)
//    }
//    return nil
//  }
  
//  enum MarkdownSyntax {
//    case inlineCode
//    case italic
//    case bold
//    case strikethrough
//    
//    var renderingAttributes: [NSAttributedString.Key: Any] {
//      switch self {
//        case .inlineCode:
//          return [.backgroundColor: NSColor.lightGray, .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)]
//        case .italic:
//          return [.font: NSFont.italicSystemFont(ofSize: 12)]
//        case .bold:
//          return [.font: NSFont.boldSystemFont(ofSize: 12)]
//        case .strikethrough:
//          return [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
//      }
//    }
//  }


}
