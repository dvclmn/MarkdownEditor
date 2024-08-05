//
//  OSDefinitions.swift
//  
//
//  Created by Manuel M T Chakravarty on 04/05/2021.
//
//  A set of aliases and the like to smooth ove some superficial macOS/iOS differences.

import SwiftUI


import AppKit

//typealias OSFontDescriptor = NSFontDescriptor
//typealias OSFont           = NSFont
//public
//typealias OSColor          = NSColor
//typealias OSBezierPath     = NSBezierPath
//typealias OSView           = NSView
//typealias OSTextView       = NSTextView
//typealias OSHostingView    = NSHostingView

let labelColor = NSColor.labelColor

//typealias TextStorageEditActions = NSTextStorageEditActions

extension NSFont {

  /// The constant adavance for a (horizontal) monospace font.
  ///
  var maximumHorizontalAdvancement: CGFloat { self.maximumAdvancement.width }
  
  /// The line height (which is an exting property on `UIFont`).
  /// 
  var lineHeight: CGFloat { ceil(ascender - descender - leading) }
}
extension NSColor {

  /// Create an AppKit colour from a SwiftUI colour if possible.
  ///
  convenience init?(color: Color) {
    guard let cgColor = color.cgColor else { return nil }
    self.init(cgColor: cgColor)
  }
}

extension NSView {

  /// Add a subview such that it is layered below its siblings.
  ///
  /// - Parameter view: The subview to add.
  ///
  func addBackgroundSubview(_ view: NSView) {
    addSubview(view, positioned: .below, relativeTo: nil)
  }
  
  /// Imitate UIKit interface.
  ///
  func insertSubview(_ view: NSView, aboveSubview siblingSubview: NSView) {
    addSubview(view, positioned: .above, relativeTo: siblingSubview)
  }

  /// Imitate UIKit interface.
  ///
  func insertSubview(_ view: NSView, belowSubview siblingSubview: NSView) {
    addSubview(view, positioned: .below, relativeTo: siblingSubview)
  }
}

