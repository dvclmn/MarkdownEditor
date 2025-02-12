//
//  Change+Frame.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 7/10/2024.
//

//import AppKit
//import Glyph

//extension MarkdownTextView {
  
  /// IMPORTANT:
  ///
  /// Trying to use a `layout` override, as a way to trigger parsing/styling/frame
  /// changes, is a BAD idea, and results in such messages as
  /// `attempted layout while textStorage is editing. It is not valid to cause the layoutManager to do layout while the textStorage is editing` etc
  
//  public override var frame: NSRect {
//    didSet {
//      if frame.width != oldValue.width {
//        onWidthChange?(frame.width)
//      }
//    }
//  }
  
  
//  func countLinesSimple() -> Int {
//    
//    let text = string
//    
//    let lines = text.split(separator: .newlineSequence)
//    
//    return lines.count
//  }
//  
//  func countLinesTK2() -> Int {
//    
//    guard let textLayoutManager = textLayoutManager else {
//      return 0
//    }
//    
//    var lineCount = 0
//    
//    textLayoutManager.enumerateTextLayoutFragments(
//      from: textLayoutManager.documentRange.location,
//      options: [.ensuresLayout, .ensuresExtraLineFragment]
//    ) { layoutFragment in
//      lineCount += layoutFragment.textLineFragments.count
//      return true
//    }
//    
//    return lineCount
//  }
//  
//}


