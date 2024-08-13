//
//  Invalidations.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 13/8/2024.
//

import SwiftUI

//
//private extension NSViewInvalidating where Self == NSView.Invalidations.InsertionPoint {
//  static var insertionPoint: NSView.Invalidations.InsertionPoint {
//    NSView.Invalidations.InsertionPoint()
//  }
//}
//
//private extension NSViewInvalidating where Self == NSView.Invalidations.CursorRects {
//  static var cursorRects: NSView.Invalidations.CursorRects {
//    NSView.Invalidations.CursorRects()
//  }
//}
//
//private extension NSView.Invalidations {
//  
//  struct InsertionPoint: NSViewInvalidating {
//    
//    func invalidate(view: NSView) {
//      guard let textView = view as? MarkdownView else {
//        return
//      }
//      
//      textView.updateInsertionPointStateAndRestartTimer()
//    }
//  }
//  
//  struct CursorRects: NSViewInvalidating {
//    
//    func invalidate(view: NSView) {
//      view.window?.invalidateCursorRects(for: view)
//    }
//  }
//  
//}
