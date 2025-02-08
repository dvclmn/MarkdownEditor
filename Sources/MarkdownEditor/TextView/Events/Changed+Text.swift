//
//  TextChanged.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

//import SwiftUI
//import BaseStyles


//extension MarkdownTextView {
//  
//  
//  
//  public override func didChangeText() {
//    
//    super.didChangeText()
//    
//  }
//  
//  
//  
//  
//}

//@MainActor
//extension MarkdownEditor.Coordinator {
//  public func textDidChange(_ notification: Notification) {
//    
//    guard let textView = notification.object as? MarkdownTextView,
//          !updatingNSView
//    else { return }
//    
//    /// Moved this here, from `NSTextView`s `didChangeText` override,
//    /// to address some scroll jumping bugs when typing
//    ///
//    /// https://stackoverflow.com/a/8697502
//    ///
//    Task { @MainActor in
//      await textView.parsingDebouncer.processTask {
//        await textView.parseAllMarkdown()
//        await textView.styleInlineMarkdown()
//      }
//    }
//    
//    textView.onAppearAndTextChange()
//    
//    self.parent.text = textView.string
//    self.selectedRanges = textView.selectedRanges
//    
//    /// I have learned, and need to remember, that this `Coordinator` is
//    /// a delegate, for my ``MarkdownTextView``. Which means I can take
//    /// full advantage of methods here, just like I can with overrides in `MarkdownTextView`. They often have different functionalities to
//    /// experiment with.
//    
//  }
//}

