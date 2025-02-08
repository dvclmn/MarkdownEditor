//
//  Fragments.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/10/2024.
//

import AppKit
import MarkdownModels

//extension MarkdownEditor.Coordinator {
//  
//  
//  /// The method the framework calls to give the delegate an opportunity to return a custom text layout fragment.
//  /// https://developer.apple.com/documentation/uikit/nstextlayoutmanagerdelegate/3810024-textlayoutmanager
//  public func textLayoutManager(
//    _ textLayoutManager: NSTextLayoutManager,
//    textLayoutFragmentFor location: NSTextLocation,
//    in textElement: NSTextElement
//  ) -> NSTextLayoutFragment {
//    
//    if let parItemTextElement = textElement as? MarkdownParagraph {
//      return CodeBlockBackground(
//        textElement: parItemTextElement,
//        range: parItemTextElement.elementRange,
//        viewWidth: .greatestFiniteMagnitude
//      )
//    }
//    return NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
//  }
//  
//  
//  
//  
//}
