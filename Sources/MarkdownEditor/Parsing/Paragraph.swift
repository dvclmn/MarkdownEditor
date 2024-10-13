//
//  Paragraph.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 12/10/2024.
//

import AppKit

class MarkdownParagraph: NSTextParagraph {
  
  var attachmentRanges: Array<NSRange>
  
  init(
    attributedString:NSAttributedString,
    textContentManager: NSTextContentManager,
    elementRange: NSTextRange?,
    attachmentRanges ranges:Array<NSRange>
  ) {
    attachmentRanges = ranges
    super.init(attributedString: attributedString)
    self.textContentManager = textContentManager
    self.elementRange = elementRange
  }
  
}


class MarkdownLayoutFragment: NSTextLayoutFragment {
  
//  var frameChangeSubscriber : Cancellable? = nil
  
  init(
    textElement:MarkdownParagraph,
    range: NSTextRange?
  ) {
    super.init(textElement: textElement, range: range)
    
//    let frameChangePublisher = self.publisher(for: \.layoutFragmentFrame, options: [.new])
//    
//    let frameChangeSubscriber = frameChangePublisher.throttle(for: .seconds(1), scheduler: RunLoop.main, latest: true).sink(receiveValue: {[weak self] newFrame in
//      if let layoutFragment = self {
//        Task { @MainActor () -> Void in
//          layoutFragment.textViewController?.updateSubiewLocations(layoutFragment.paragraphItemPersistentIDs, layoutFragment: layoutFragment)
//        }
//      }
//    })
//    self.frameChangeSubscriber = frameChangeSubscriber
    
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  
  var textView: MarkdownTextView? {
    get {
      return self.textLayoutManager?.textContainer?.textView as? MarkdownTextView
    }
  }
  
//  var textViewController: MarkdownViewController? {
//    get {
//      return self.textView?.viewController
//    }
//  }
  
//  var paragraphItemAttachments: Array<ParagraphItemAttachment2> {
//    get {
//      var parItemAttachments: Array<ParagraphItemAttachment2> = Array()
//      if let textElement = self.textElement as? ParItemAttachmentTextParagraph {
//        let attributedString = textElement.attributedString
//        let range = NSRange(location: 0, length: attributedString.length)
//        attributedString.enumerateAttribute(.attachment, in: range) { (attachment: Any?, characterRange:NSRange, stopIt: UnsafeMutablePointer<ObjCBool>) in
//          if let parItemAttachment = attachment as? ParagraphItemAttachment2 {
//            parItemAttachments.append(parItemAttachment)
//          }
//        }
//      }
//      return parItemAttachments
//    }
//  }
  
//  var paragraphItemPersistentIDs: Array<PersistentIdentifier> {
//    get {
//      let parItemAttachments = self.paragraphItemAttachments
//      let theParItems = parItemAttachments.compactMap({
//        return $0.persistentIdentifier
//      })
//      return theParItems
//    }
//  }
  
  
}
