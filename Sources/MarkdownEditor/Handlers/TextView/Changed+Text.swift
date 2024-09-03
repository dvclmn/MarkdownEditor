//
//  TextChanged.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI


extension MarkdownTextView {
  
  public override func shouldChangeText(in affectedCharRange: NSRange, replacementString: String?) -> Bool {
    super.shouldChangeText(in: affectedCharRange, replacementString: replacementString)
    
    //    print("`Should change text` \(Date.now)")
    
    
    Task { @MainActor in
      let heightUpdate = self.updateEditorHeight()
      await self.infoHandler.update(heightUpdate)
    }
    
    self.parseAndStyleMarkdownLite(trigger: .text)
    self.styleElements(trigger: .text)
    
    
    
    return true
  } // END shouldChangeText
  
  
  public override func didChangeText() {
    
    super.didChangeText()
    
    //    print("`override func didChangeText()` — at \(Date.now)")
    
    //    onAppearAndTextChange()
    

  }
}

//extension MarkdownTextView: NSTextContentStorageDelegate {
//  func textContentStorage(_ textContentStorage: NSTextContentStorage, didInvalidate range: NSTextRange) {
//    
//    print("Does this ever get called?")
//    DispatchQueue.main.async {
//      self.updateEditorHeightIfNeeded()
//    }
//  }
//}


extension MarkdownTextView {
//
//  func updateEditorHeightIfNeeded() {
//    let newFrame = updateEditorHeight()
//    
//    if abs(newFrame.height - frame.height) > 1 {
//      self.frame.size.height = newFrame.height
//      self.invalidateIntrinsicContentSize()
//      
//      // Update scroll view content size if necessary
//      if let scrollView = self.enclosingScrollView {
//        scrollView.documentView?.frame.size.height = newFrame.height
//        scrollView.contentView.needsDisplay = true
//      }
//      
//      self.superview?.needsLayout = true
//      self.superview?.needsLayout = true
//    }
//  }
//

  
  func updateEditorHeight() -> EditorInfo.Frame {
    guard let tlm = self.textLayoutManager else { return .init() }
    
    // Force layout update
    tlm.ensureLayout(for: tlm.documentRange)
    
    let bounds = tlm.usageBoundsForTextContainer
    
    let extraHeight: CGFloat = 80
    
    let frame = EditorInfo.Frame(
      width: bounds.width,
      height: bounds.height + extraHeight
    )
    
//    print("Editor size — Width: \(frame.width), Height: \(frame.height)")
    
    // Mark view for layout and display update
    self.invalidateIntrinsicContentSize()
    self.needsLayout = true
    self.needsDisplay = true
    
    return frame
  }
}

//extension MarkdownTextView {
//
//
//  func generateTextInfo() -> EditorInfo.Text {
//
//    guard let tlm = self.textLayoutManager,
//          let viewportRange = tlm.textViewportLayoutController.viewportRange
//    else { return .init() }
//
//    let documentRange = tlm.documentRange
//
//    var textElementCount: Int = 0
//
//    tlm.textContentManager?.enumerateTextElements(from: documentRange.location, using: { _ in
//      textElementCount += 1
//      return true
//    })
//
//    let scratchPad: String = """
//    Character count: \(self.string.count)
//    TextElement count: \(textElementCount)
//
//    Markdown.Elements count: \(self.elements.count)
//    Elements: \(self.condensedElementSummary)
//    """
//
//    return EditorInfo.Text(
//      scratchPad: scratchPad
//    )
//  }
//}

extension MarkdownTextView {
  var condensedElementSummary: String {
    let elementCounts = Dictionary(grouping: elements, by: { $0.syntax })
      .mapValues { $0.count }
    /// The below sorts by frequency within the source text
    //      .sorted { $0.value > $1.value }
    
    /// This sorts alphabetically
      .sorted { $0.key.name < $1.key.name }
    
    let summaries = elementCounts.map { syntax, count in
      count > 1 ? "\(syntax.name) (x\(count))" : syntax.name
    }
    
    return summaries.joined(separator: ", ")
  }
  
  func printElementSummary() {
    var textElementCount = 0
    textLayoutManager?.textContentManager?.enumerateTextElements(from: textLayoutManager?.documentRange.location, using: { _ in
      textElementCount += 1
      return true
    })
    
    print("Total elements: \(textElementCount)")
    print("Elements: \(condensedElementSummary)")
  }
}
