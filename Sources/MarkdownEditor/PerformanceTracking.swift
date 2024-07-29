//
//  PerformanceTracking.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 29/7/2024.
//

import SwiftUI

public class PerformanceTrackingTextView: NSTextView {
    public override init(
        frame frameRect: NSRect,
        textContainer container: NSTextContainer?
    ) {
        super.init(frame: frameRect, textContainer: container)
        setupTracking()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //    func measure<T>(_ name: String, block: () -> T) -> T {
    //        let start = DispatchTime.now()
    //        let result = block()
    //        let end = DispatchTime.now()
    //        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
    //        let timeInterval = Double(nanoTime) / 1_000_000_000
    //        print("\(name) executed in \(timeInterval) seconds")
    //        return result
    //    }
    
    private func setupTracking() {
        _ = trackingLayoutManager()
        
        // Replace the default text container with a tracking one
//        let trackingContainer = NSTextContainer(size: textContainer?.size ?? .zero)
//        trackingContainer.widthTracksTextView = ((textContainer?.widthTracksTextView) != nil)
//        trackingContainer.heightTracksTextView = ((textContainer?.heightTracksTextView) != nil)
        
        //        layoutManager?.replaceTextContainer(at: 0, with: trackingContainer)
        
        // Replace the default text storage with a tracking one
//        if let textStorage = textStorage, let layoutManager = layoutManager {
//            
//            let trackingStorage = NSTextStorage(attributedString: textStorage)
//            trackingStorage.addLayoutManager(layoutManager)
//        }
        
        // Set up method swizzling for tracking
        swizzleMethod(#selector(replaceCharacters(in:with:)), with: #selector(trackingReplaceCharacters(in:with:)))
    }
    
    @objc func trackingReplaceCharacters(in range: NSRange, with string: String) {
        let start = DispatchTime.now()
        //            self.trackingReplaceCharacters(in: range, with: string)
        let end = DispatchTime.now()
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000_000
        PerformanceMetrics.shared.recordTiming("text_replace", time: timeInterval)
        PerformanceMetrics.shared.increment("text_replace_count")
    }
    
    // Helper function for method swizzling
    public func swizzleMethod(_ originalSelector: Selector, with swizzledSelector: Selector) {
        guard let originalMethod = class_getInstanceMethod(PerformanceTrackingTextView.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(PerformanceTrackingTextView.self, swizzledSelector) else {
            return
        }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}


public struct PerformanceTrackingTextViewRepresentable: NSViewRepresentable {
    @Binding var text: String
    
    public init(
        text: Binding<String>
    ) {
        self._text = text
    }
    
    public func makeNSView(context: Context) -> PerformanceTrackingTextView {
        
        
        
        let textView = PerformanceTrackingTextView(frame: .zero, textContainer: NSTextContainer())
        textView.delegate = context.coordinator
        return textView
    }
    
    public func updateNSView(_ nsView: PerformanceTrackingTextView, context: Context) {
        nsView.string = text
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, NSTextViewDelegate {
        var parent: PerformanceTrackingTextViewRepresentable
        
        init(_ parent: PerformanceTrackingTextViewRepresentable) {
            self.parent = parent
        }
        
        public func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }
    }
}




@MainActor
public class PerformanceMetrics: ObservableObject {
    public static let shared = PerformanceMetrics()
    
    @Published var metrics: [String: Int] = [:]
    @Published var timings: [String: TimeInterval] = [:]
    
    func increment(_ key: String) {
        DispatchQueue.main.async {
            self.metrics[key, default: 0] += 1
        }
    }
    
    func recordTiming(_ key: String, time: TimeInterval) {
        DispatchQueue.main.async {
            self.timings[key] = time
        }
    }
    
    func reset() {
        DispatchQueue.main.async {
            self.metrics.removeAll()
            self.timings.removeAll()
        }
    }
}




@MainActor
public class PerformanceLogger {
    static var shared = PerformanceLogger()
    var metrics: [String: Int] = [:]
    
    func increment(_ key: String) {
        metrics[key, default: 0] += 1
    }
    
    func log() {
        // Display in console or custom UI
        for (key, value) in metrics {
            print("\(key): \(value)")
        }
    }
}

// Usage
//PerformanceLogger.shared.increment("regex_matches")


public extension NSTextStorage {
    @MainActor func trackingReplaceCharacters(in range: NSRange, with str: String) {
        let start = DispatchTime.now()
        replaceCharacters(in: range, with: str)
        let end = DispatchTime.now()
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000_000
        PerformanceMetrics.shared.recordTiming("text_replace", time: timeInterval)
        PerformanceMetrics.shared.increment("text_replace_count")
    }
}

public extension NSTextView {
    func trackingLayoutManager() -> NSLayoutManager? {
        let layoutManager = layoutManager
        layoutManager?.allowsNonContiguousLayout = true
        layoutManager?.addObserver(self, forKeyPath: "numberOfGlyphs", options: .new, context: nil)
        return layoutManager
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "numberOfGlyphs" {
            PerformanceMetrics.shared.increment("layout_passes")
        }
    }
}

public extension NSTextContainer {
    @MainActor func trackingLineFragmentRect(forProposedRect proposedRect: NSRect, at characterIndex: Int, writingDirection baseWritingDirection: NSWritingDirection, remaining remainingRect: UnsafeMutablePointer<NSRect>?) -> NSRect {
        let start = DispatchTime.now()
        let result = lineFragmentRect(forProposedRect: proposedRect, at: characterIndex, writingDirection: baseWritingDirection, remaining: remainingRect)
        let end = DispatchTime.now()
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000_000
        PerformanceMetrics.shared.recordTiming("line_fragment_calculation", time: timeInterval)
        PerformanceMetrics.shared.increment("line_fragment_calculations")
        return result
    }
}


public extension NSAttributedString {
    @MainActor func trackingEnumerateAttribute(_ attrName: NSAttributedString.Key, in enumerationRange: NSRange, options opts: NSAttributedString.EnumerationOptions = [], using block: (Any?, NSRange, UnsafeMutablePointer<ObjCBool>) -> Void) {
        let start = DispatchTime.now()
        enumerateAttribute(attrName, in: enumerationRange, options: opts, using: block)
        let end = DispatchTime.now()
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000_000
        PerformanceMetrics.shared.recordTiming("attribute_enumeration", time: timeInterval)
        PerformanceMetrics.shared.increment("attribute_enumerations")
    }
}


public extension NSLayoutManager {
    @MainActor func trackingGlyphRange(forCharacterRange range: NSRange, actualCharacterRange: NSRangePointer?) -> NSRange {
        let start = DispatchTime.now()
        let result = glyphRange(forCharacterRange: range, actualCharacterRange: actualCharacterRange)
        let end = DispatchTime.now()
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000_000
        PerformanceMetrics.shared.recordTiming("glyph_range_calculation", time: timeInterval)
        PerformanceMetrics.shared.increment("glyph_range_calculations")
        return result
    }
}






// Usage
//let result = measure("regex_matching") {
// Your regex matching code here
//}


public extension NSRegularExpression {
    func performanceMatch(in string: String, options: NSRegularExpression.MatchingOptions = [], range: NSRange) -> [NSTextCheckingResult] {
        let start = DispatchTime.now()
        let results = matches(in: string, options: options, range: range)
        let end = DispatchTime.now()
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000_000
        print("Regex match executed in \(timeInterval) seconds with \(results.count) results")
        return results
    }
}

public extension NSMutableAttributedString {
    @MainActor func trackingAddAttribute(_ name: NSAttributedString.Key, value: Any, range: NSRange) {
        addAttribute(name, value: value, range: range)
        print("Applied attribute \(name) to range of length \(range.length)")
        PerformanceLogger.shared.increment("attribute_applications")
    }
}

