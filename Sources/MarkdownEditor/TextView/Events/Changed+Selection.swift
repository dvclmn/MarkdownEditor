//
//  SelectionChanged.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI
//import Wrecktangle

extension MarkdownTextView {
  
  //  public override func setSelectedRange(_ charRange: NSRange) {
  //
  //    super.setSelectedRange(charRange)
  //
  //    updateParagraphInfo(selectedRange: charRange)
  //
  //  }
  
  public override func setSelectedRanges(_ ranges: [NSValue], affinity: NSSelectionAffinity, stillSelecting: Bool) {
    
    super.setSelectedRanges(ranges, affinity: affinity, stillSelecting: stillSelecting)
    
    displayTypingAttributes()
    //    print("Text view frame: `\(self.frame)`")
    //    updateParagraphInfo(firstSelected: ranges.first?.rangeValue)
    
    //    if !stillSelecting {
    //      printNewSelection()
    //    }
  }
  
  func displayTypingAttributes() {
    let result = typingAttributes.map { key, value in
//      let keyString = key.rawValue
      var keyString: String = ""
      var valueString: String = ""
      
      switch key {
        case .font:
          keyString = "Font"
          
        case .foregroundColor:
          keyString = "Text Color"
          
        case .backgroundColor:
          keyString = "Background Color"
          
        case .paragraphStyle:
          keyString = "Paragraph"
          
        default:
          keyString = key.rawValue
      }
      
      switch value {
        case let font as NSFont:
          valueString = "\(font.displayName ?? font.fontName), \(font.pointSize)pt"
          
        case let color as NSColor:
          valueString = color.colorNameComponent
          
        case let number as NSNumber:
          valueString = number.stringValue
          
        case let paragraphStyle as NSParagraphStyle:
          valueString = "Alignment: \(paragraphStyle.alignment.rawValue), LineSpacing: \(paragraphStyle.lineSpacing)"
          
        default:
          valueString = "Default: " + String(describing: value)
      }
      
      return (keyString, valueString)
    }
      .sorted { $0.0 < $1.0 }
      .map { "\t\($0): \($1)" }
      .joined(separator: "\n")
    
    Task { @MainActor in
      await self.infoDebouncer.processTask {
        self.infoHandler.updateMetric(keyPath: \.typingAttributes, value: result)
      }
    }
  }
  
  //  func printNewSelection() {
  //
  //    /// I don't need to see anything below a character count of 2
  //    ///
  //    guard self.selectedRange().length > 2,
  //          lastSelectedText != self.selectedText
  //    else { return }
  //
  //    let result: String = """
  //    Selected text: \(selectedText)
  //    """
  //
  //    self.lastSelectedText = selectedText
  //
  //    print(result)
  //
  //  }
  
}


