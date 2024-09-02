//
//  Styling.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 1/9/2024.
//


import AppKit
import BaseHelpers
import STTextKitPlus
import TextCore


extension MarkdownTextView {
  
//  func applyRenderingStyles(to element: Markdown.Element) {
//    
//    guard let tlm = self.textLayoutManager,
//          let tcm = tlm.textContentManager
//
//    else { return }
//    
//
//    let removableRenderingAttributes: [Attributes.Key] = [
//      .foregroundColor,
//      .backgroundColor
//    ]
//    
//    tcm.performEditingTransaction {
//
//      for attribute in removableRenderingAttributes {
//        tlm.removeRenderingAttribute(attribute, for: element.range.content)
//      }
//
//      guard let defaultRenderingAttributes = self.configuration.renderingAttributes.getAttributes()
//      else { return }
//      
//      
//      tlm.setRenderingAttributes(defaultRenderingAttributes, for: element.range.content)
//      
//
//      tlm.setRenderingAttributes(element.syntax.contentRenderingAttributes, for: element.range.content)
//
//    } // END perform editing
//    //    } // END task
//  }
//  
//  func applyMarkdownStyles() {
//    
//    guard let tlm = self.textLayoutManager,
//          let tcm = tlm.textContentManager,
//          let tcs = self.textContentStorage,
//          let viewportRange = tlm.textViewportLayoutController.viewportRange,
//          let viewportString = tcm.attributedString(in: viewportRange)?.string
//            
//    else { return }
//    
//    /// Whilst this is 'only' the viewport range, we can/should squeeze out more
//    /// performance here, by only affecting the range absolutely neccesary, right
//    /// where the user is making edits.
//    ///
//    let nsViewportRange = NSRange(viewportRange, in: tcm)
//    
//    
////    self.parsingTask?.cancel()
////    self.parsingTask = Task {
//      
//      let removableRenderingAttributes: [Attributes.Key] = [
//        .foregroundColor,
//        .backgroundColor
//      ]
//      
//      
//      tcm.performEditingTransaction {
//        
//        /// I need to verify whether I treat certain attributes differently, based
//        /// on whether they are rendering vs
//        for attribute in removableRenderingAttributes {
//          tlm.removeRenderingAttribute(attribute, for: viewportRange)
//        }
//        
//        
//        /// This (`tcs.textStorage?.removeAttribute`) is great —
//        /// this does verifyably remove all specified attributes, for the
//        /// specified range (`NSRange`).
//        ///
//        tcs.textStorage?.removeAttribute(.font, range: nsViewportRange)
//        
//        guard let defaultFontAttributes = self.configuration.fontAttributes.getAttributes(),
//              let defaultRenderingAttributes = self.configuration.renderingAttributes.getAttributes()
//        else { return }
//        
//        
//        tlm.setRenderingAttributes(defaultRenderingAttributes, for: viewportRange)
//        
//        tcs.textStorage?.addAttributes(defaultFontAttributes, range: nsViewportRange)
//        
//        
//        
//        
//        /// What am I trying to do?
//        /// 1. The app starts, text is there, should be styled via a first pass
//        /// 2. I think the code should know what markdown syntax the user's
//        /// insertion point is in right now
//        
//        
//        /// `element` here is type `Markdown.Element`
//        ///
//        /// We are looping through all elements found by the `parseMarkdown` function.
//        ///
//        for element in self.elements {
//          
//          guard let markdownNSTextRange = element.markdownNSTextRange(
//            element.range,
//            in: viewportString,
//            syntax: element.syntax,
//            provider: tcm
//          ) else { break }
//          
//          guard markdownNSTextRange.content.intersects(viewportRange) else { break }
//          
//          let contentNSRange = NSRange(markdownNSTextRange.content, in: tcm)
//          
//          //          print("Text range, for rendering attributes: \(markdownNSTextRange.content)")
//          
//          //          tcs.textStorage?.invalidateAttributes(in: contentNSRange)
//          
//          //          tcs.textStorage?.removeAttribute(.font, range: contentNSRange)
//          
//          
//          
//          if let fontAttributes = element.syntax.contentFontAttributes {
//            tcs.textStorage?.addAttributes(fontAttributes, range: contentNSRange)
//          }
//          
//          tlm.setRenderingAttributes(element.syntax.contentRenderingAttributes, for: markdownNSTextRange.content)
//          
//          
//          
//          //          tlm.setRenderingAttributes(element.syntax.contentAttributes, for: markdownNSTextRange.content)
//          //          tlm.setRenderingAttributes(element.syntax.syntaxAttributes, for: markdownNSTextRange.leading)
//          //          tlm.setRenderingAttributes(element.syntax.syntaxAttributes, for: markdownNSTextRange.trailing)
//          
//          //          tcm.attributedString(in: markdownNSTextRange.content).attr
//          
//          
//          
//        } // END loop over elements
//        
//      } // END perform editing
////    } // END task
//  }
}




extension MarkdownEditor {
  
  
  /// Style syntax characters
  ///
//  private static func applySyntaxAttributes(
//    for syntax: Markdown.Syntax,
//    to attributedString: NSMutableAttributedString,
//    in range: NSRange
//  ) {
//    
//    for (key, value) in syntax.syntaxRenderingAttributes {
//      attributedString.addAttribute(key, value: value, range: range)
//    }
//  }
  
  //  func setCodeBlockBackgrounds(for textView: MDTextView) {
  
  //    let ranges = [NSRange]()
  
  
  
  // Clear previous highlights
  //    textView.codeBlockLayer?.highlightRects = []
  
  // Update highlights for each code block
  //    for range in ranges {
  //      updateCodeBlockHighlight(for: range)
  //    }
  
  
  //  }
  
  
  //  static func getHighlightedText(
  //    text: String
  //  ) -> NSMutableAttributedString {
  //
  //    print("Let's get the highlighted text and return it")
  //
  //    let highlightedString = NSMutableAttributedString(string: text)
  //    let all = NSRange(location: 0, length: text.utf16.count)
  //
  //    highlightedString.addAttribute(.font, value: NSFont.systemFont(ofSize: MarkdownDefaults.fontSize), range: all)
  //    highlightedString.addAttribute(.foregroundColor, value: NSColor.labelColor, range: all)
  //
  //    /// Defining the order manually here, but should test to make sure that this actually makes a difference
  //    let orderedSyntax: [Markdown.Syntax] = [
  //      .boldItalic,
  //      .boldItalicAlt,
  //      .bold,
  //      .boldAlt,
  //      .italic,
  //      .italicAlt,
  //      .inlineCode,
  //      .h1,
  //      .h2,
  //      .h3,
  //      .codeBlock,
  //      .quoteBlock
  //    ]
  //
  //    for syntax in orderedSyntax {
  //      applyStylesToContent(for: syntax, to: highlightedString, in: all)
  //    }
  //
  //    return highlightedString
  //  }
  
  
  //  private static func applyStylesToContent(
  //    for syntax: Markdown.Syntax,
  //    to attributedString: NSMutableAttributedString,
  //    in range: NSRange
  //  ) {
  //
  //    print("Let's apply the highlight syntaxes")
  //    let text = attributedString.string
  //
  //    let regex = syntax.regex
  //
  //    regex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
  //
  //      guard let matchRange = match?.range else { return }
  //
  //      for (key, value) in syntax.contentAttributes {
  //        attributedString.addAttribute(key, value: value, range: matchRange)
  //      }
  //
  ////      if syntax == .codeBlock {
  //
  ////              attributedString.addCodeBlockBackground(to: range)
  ////      }
  //
  //      let characters = syntax.syntaxCharacters
  //
  //      //    if syntax.isSyntaxSymmetrical {
  //      //
  //      //    }
  //
  //      /// What questions are we asking
  //      /// 1. How many syntax characters
  //      /// 2. Are they on the left or the right
  //      /// 3. Is this a block, line or inline type of syntax
  //
  //      /// Process syntax characters on the left
  //      ///
  //      let syntaxRange = NSRange(location: matchRange.location, length: characters.count + 1)
  //
  //      applySyntaxAttributes(for: syntax, to: attributedString, in: syntaxRange)
  //
  //      /// Process syntax characters on the right
  //      ///
  //      if characters.count > 1 {
  //        let closingStart = matchRange.location + matchRange.length - characters.count
  //        let closingRange = NSRange(location: closingStart, length: characters.count)
  //        applySyntaxAttributes(for: syntax, to: attributedString, in: closingRange)
  //      }
  //    }
  //
  //  } // END
  
  
  
  //
  //  func addAttributes(
  //    for syntax: Markdown.Syntax,
  //    to type: SyntaxType
  //    to attributedString: NSMutableAttributedString,
  //    in range: NSRange
  //  ) {
  //
  //  }
  
}


