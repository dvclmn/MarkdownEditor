//
//  Changed+Appeared.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import SwiftUI

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
        
        guard let paragraph = fragment.textElement as? NSTextParagraph else { return false }
        
        let string = paragraph.attributedString.string
        
        guard let paragraphRange = paragraph.elementRange,
              let range = NSTextRange(location: paragraphRange.location, end: paragraphRange.endLocation),
              let nsRange = tcm.range(for: range)
                
        else {
          print("Returned false: \(string)")
          return false
        }

//        for syntax in Markdown.Syntax.testCases {
          
          do {
            
            guard let regexPattern = Markdown.Syntax.inlineCode.nsRegex else { return false }
//            guard let regexPattern = syntax.nsRegex else { continue }
            
            let regex = try NSRegularExpression(pattern: regexPattern, options: [.anchorsMatchLines])
            
            regex.enumerateMatches(in: string, range: nsRange) { result, flags, stop in
              
              if let result = result {
                print("""
              Results of matching `NSRegularExpression`:
              Result: \(result)
              Flags: \(flags)
              Stop: \(stop)
              """)
                
//                guard let nsTextRange = tcm.textRange(for: result.range) else { return }
                
//                tlm.setRenderingAttributes(syntax.contentRenderingAttributes, for: nsTextRange)
                
              }
              
            } // END enumerate matches
          } catch {
            print("Error with regex")
          }
          
          
//        } // END syntax loop
        
        
        
        return true
        
      } // END enumerate fragments
      
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
