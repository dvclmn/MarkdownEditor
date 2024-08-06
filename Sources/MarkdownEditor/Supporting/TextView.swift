//
//  File.swift
//  
//
//  Created by Dave Coleman on 6/8/2024.
//


//  TextView.swift
//
//
//  Created by Manuel M T Chakravarty on 28/09/2020.
//
//  Text view protocol that extracts common functionality between 'UITextView' and 'NSTextView'.

import Foundation
import SwiftUI

// MARK: -
// MARK: The protocol

/// A protocol that bundles up the commonalities of 'UITextView' and 'NSTextView'.
///
//protocol TextView {
//  associatedtype Color
//  associatedtype Font

//  // This is necessary as these members are optional in AppKit and not optional in UIKit.
//  var optTextLayoutManager: NSTextLayoutManager? { get }
//  var optTextContainer: NSTextContainer? { get }
//  var optTextContentStorage: NSTextContentStorage? { get }
//  var optCodeStorage: MDTextStorage? { get }
//
//  var textBackgroundColor: Color? { get }
//  var textFont:            Font? { get }
//  var textContainerOrigin: CGPoint { get }

  /// The text displayed by the text view.
  ///
//  var text: String! { get set }
//
//  /// If the current selection is an insertion point (i.e., the selection length is 0), return its location.
//  ///
//  var insertionPoint: Int? { get }
//
//  /// The current (single range) selection of the text view.
//  ///
//  var selectedRange: NSRange { get set }
//
//  /// The set of lines that have characters that are included in the current selection. (This may be a multi-selection,
//  /// and hence, a non-contiguous range.)
//  ///
//  var selectedLines: Set<Int> { get }
//  
//  /// The bounds of the view.
//  ///
//  var bounds: CGRect { get set }
//
//  /// The visible portion of the text view. (This only accounts for portions of the text view that are obscured through
//  /// visibility in a scroll view.)
//  ///
//  var documentVisibleRect: CGRect { get }
//  
//  /// The size of the whole document (after layout).
//  ///
//  var contentSize: CGSize { get }
//
//  /// Temporarily highlight the visible part of the given range.
//  ///
//  func showFindIndicator(for range: NSRange)
//  
//  /// Marks the given rectangle of the current view as needing redrawing.
//  ///
//  func setNeedsDisplay(_ invalidRect: CGRect)
//}


// MARK: Shared code

extension MDTextView {

  /// The text view's line map.
  ///
  var optLineMap: LineMap<LineInfo>? {
    return (textStorage?.delegate as? MDTextStorageDelegate)?.lineMap
  }


  /// Determine the visible range of lines.
  ///
  var documentVisibleLines: Range<Int>? {
    guard let textLayoutManager = textLayoutManager,
          let textContentStorage = textLayoutManager.textContentManager as? NSTextContentStorage,
          let lineMap = (textStorage?.delegate as? MDTextStorageDelegate)?.lineMap,
          lineMap.lines.count > 1   // this ensure that the line map has been initialised
    else { return nil }

    if let textRange = textLayoutManager.textViewportLayoutController.viewportRange {
      return lineMap.linesOf(range: textContentStorage.range(for: textRange))
    } else { return nil }
  }

  /// Determine the bounding rectangle for fragments containing the characters in the given range.
  ///
  /// - Parameter range: The range of characters whose fragment bounding rectangle we desire. If nil, the entire text is
  ///     used.
  /// - Returns: The bounding rectangle if the character range is valid. The coordinates are relative to the origin of
  ///     the text view.
  ///
  func fragmentBoundingRect(for range: NSRange? = nil) -> CGRect? {
    guard let textLayoutManager  = textLayoutManager,
          let textContentStorage = textLayoutManager.textContentManager as? NSTextContentStorage
    else { return nil }

    let textRange = if let range,
                       let textRange = textContentStorage.textRange(for: range) { textRange }
                    else { textContentStorage.documentRange },
        rect      = textLayoutManager.textLayoutFragmentBoundingRect(for: textRange)
    return rect.offsetBy(dx: textContainerOrigin.x, dy: textContainerOrigin.y)
  }

  /// Invalidate the entire background area of the line containing the given text location.
  ///
  /// - Parameter textLocation: The text location whose line we want to invalidate.
  ///
  func invalidateBackground(forLineContaining textLocation: NSTextLocation) {
    invalidateBackground(forLinesContaining: NSTextRange(location: textLocation))
  }

  /// Invalidate the entire background area of the lines containing the given text range.
  ///
  /// - Parameter textRange: The text ranges whose lines we want to invalidate.
  ///
  func invalidateBackground(forLinesContaining textRange: NSTextRange) {

    guard let textLayoutManager = textLayoutManager else { return }

    if let (y: y, height: height) = textLayoutManager.textLayoutFragmentExtent(for: textRange),
       let invalidRect            = lineBackgroundRect(y: y, height: height)
    {
      if textRange.endLocation.compare(textLayoutManager.documentRange.endLocation) == .orderedSame {
        setNeedsDisplay(CGRect(origin: invalidRect.origin, size: CGSize(width: invalidRect.width, height: bounds.height - invalidRect.minY)))
      } else {
        setNeedsDisplay(invalidRect)
      }
    }
  }

  /// Draw the background of an entire line of text with a highlight colour.
  ///
  func drawBackgroundHighlight(
    within rect: CGRect,
    forLineContaining textLocation: NSTextLocation,
    withColour colour: NSColor)
  {
    guard let textLayoutManager = textLayoutManager else { return }

    colour.setFill()
    if let fragmentFrame = textLayoutManager.textLayoutFragment(for: textLocation)?.layoutFragmentFrameWithoutExtraLineFragment,
       let highlightRect = lineBackgroundRect(y: fragmentFrame.minY, height: fragmentFrame.height)
    {

      let clippedRect = highlightRect.intersection(rect)
      if !clippedRect.isNull { NSBezierPath(rect: clippedRect).fill() }

    } else
    if let previousLocation = textContentStorage?.location(textLocation, offsetBy: -1),
       let fragmentFrame    = textLayoutManager.textLayoutFragment(for: previousLocation)?.layoutFragmentFrameExtraLineFragment,
       let highlightRect    = lineBackgroundRect(y: fragmentFrame.minY, height: fragmentFrame.height)
    {

      let clippedRect = highlightRect.intersection(rect)
      if !clippedRect.isNull { NSBezierPath(rect: clippedRect).fill() }

    }
  }

  /// Compute the background rect from the extent of a line's fragement rect. On lines that contain a message view, the
  /// fragment rect doesn't cover the entire background. We, moreover, need to account for the space between the text
  /// container's right hand side and the divider of the minimap (if the minimap is visible).
  ///
  func lineBackgroundRect(y: CGFloat, height: CGFloat) -> CGRect? {

    // We start at x = 0 as it looks nicer in case we overscoll when horizontal scrolling is enabled (i.e., when lines
    // are not wrapped).
    return CGRect(x: 0, y: y, width: bounds.size.width, height: height)
  }
}


// MARK: -
// MARK: AppKit version
//
//import AppKit
//
//extension NSTextView: TextView {
//  typealias Color = NSColor
//  typealias Font  = NSFont
//
//  var optTextLayoutManager:  NSTextLayoutManager?  { textLayoutManager }
//  var optTextContainer:      NSTextContainer?      { textContainer }
//  var optTextContentStorage: NSTextContentStorage? { textContentStorage }
//  var optCodeStorage:        CodeStorage?          { textStorage as? CodeStorage }
//
//  var textBackgroundColor: Color? { backgroundColor }
//  var textFont:            Font? { font }
//  var textContainerOrigin: CGPoint { return CGPoint(x: textContainerInset.width, y: textContainerInset.height) }
//
//  var text: String! {
//    get { string }
//    set { string = newValue }
//  }
//
//  var insertionPoint: Int? {
//    if let selection = selectedRanges.first as? NSRange, selection.length == 0 { return selection.location }
//    else { return nil }
//  }
//
//  var selectedLines: Set<Int> {
//    guard let codeStorageDelegate = optCodeStorage?.delegate as? CodeStorageDelegate else { return Set() }
//
//    let lineRanges: [Range<Int>] = selectedRanges.map{ range in
//      if let range = range as? NSRange { return codeStorageDelegate.lineMap.linesContaining(range: range) }
//      else { return 0..<0 }
//    }
//    return lineRanges.reduce(Set<Int>()){ $0.union($1) }
//  }
//
//  var documentVisibleRect: CGRect { enclosingScrollView?.documentVisibleRect ?? bounds }
//
//  var contentSize: CGSize { bounds.size }
//}


