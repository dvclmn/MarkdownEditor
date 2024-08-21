//
//  Block.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 12/8/2024.
//

import SwiftUI
import Foundation
import BaseHelpers

extension MarkdownTextView {
  
  // TODO: This of course needs to be expanded to support *actual* styles, just placeholder yellow colour for now
  func addStyle(for element: Markdown.Element) {
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager,
          let tcs = self.textContentStorage
           else { return }
    
    tcm.performEditingTransaction {
      
//        let nsRange = NSRange(element.range, in: tcm)
      
//      tcs.textStorage?.setAttributesCustom(.highlighter, range: nsRange, with: self.typingAttributes)
      
    }
  } // END addStyle
  
}

//
//public class CodeBlockHighlightLayer: CALayer {
//  var highlightRects: [CGRect] = []
//  var fillColor: CGColor = NSColor.systemBlue.withAlphaComponent(0.1).cgColor
//  var strokeColor: CGColor = NSColor.systemBlue.withAlphaComponent(0.3).cgColor
//  var radius: CGFloat = 4.0
//  
//  public override func draw(in ctx: CGContext) {
//    ctx.setFillColor(fillColor)
//    ctx.setStrokeColor(strokeColor)
//    
//    for rect in highlightRects {
//      let path = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
//      ctx.addPath(path)
//      ctx.drawPath(using: .fillStroke)
//    }
//  }
//}
//
//public extension MDTextView {
//  var codeBlockLayer: CodeBlockHighlightLayer? {
//    return layer?.sublayers?.first { $0 is CodeBlockHighlightLayer } as? CodeBlockHighlightLayer
//  }
//  
//  func setupCodeBlockLayer() {
//    if codeBlockLayer == nil {
//      let layer = CodeBlockHighlightLayer()
//      layer.frame = bounds
//      layer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
//      self.layer?.addSublayer(layer)
//    }
//  }
//  
//  func updateCodeBlockHighlight(for range: NSRange) {
//    guard let layoutManager = self.layoutManager,
//          let textContainer = self.textContainer else {
//      return
//    }
//    
//    setupCodeBlockLayer()
//    
//    layoutManager.getGlyphs(in: range, glyphs: nil, properties: nil, characterIndexes: nil, bidiLevels: nil)
//    
//    
//    var rects: [CGRect] = []
//    layoutManager.enumerateEnclosingRects(forGlyphRange: range, withinSelectedGlyphRange: NSRange(location: NSNotFound, length: 0), in: textContainer) { (rect, stop) in
//      let viewRect = self.convert(rect, from: nil)
//      rects.append(viewRect)
//    }
//    
//    codeBlockLayer?.highlightRects = rects
//    codeBlockLayer?.setNeedsDisplay()
//  }
//  
//  func invalidateCodeBlockHighlight(for range: NSRange) {
//    let glyphRange = layoutManager?.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
//    if let glyphRange = glyphRange {
//      layoutManager?.invalidateDisplay(forGlyphRange: glyphRange)
//    }
//  }
//}
