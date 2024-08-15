//
//  ScrollChanged.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 15/8/2024.
//

import SwiftUI

extension MarkdownTextView {
  
  public override func viewDidMoveToWindow() {
    
    super.viewDidMoveToWindow()
    
    if let info = self.calculateTextInfo() {
      self.onTextChange(info)
    }
    self.onEditorHeightChange(self.editorHeight)
    
    setupViewportLayoutController()
    
    self.testStyles()
    
    self.markdownBlocks = self.processMarkdownBlocks(highlight: true)
    
    if window != nil {
      startTimer()
    } else {
      stopTimer()
    }
    
    //    Task { @MainActor in
    //      if window != nil {
    //        await scrollOffsetMonitor.startMonitoring(for: self)
    //      } else {
    //        await scrollOffsetMonitor.stopMonitoring()
    //      }
    //    }
    
  }
  
  func startTimer() {
    Task { @MainActor in
      await timerActor.startTimer(interval: 0.2) { [weak self] count in
        
        self?.onTimerTick?(count)
        
      }
    }
  }
  
  func stopTimer() {
    Task { @MainActor in
      await timerActor.stopTimer()
    }
  }
  
  
  //  @MainActor
  //  func startTimer() {
  //    timer?.invalidate() // Stop any existing timer
  //    timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
  //      guard let self = self else { return }
  //      self.tickCount += 1
  //      self.onTimerTick?(self.tickCount)
  //    }
  //  }
  //
  //  func stopTimer() {
  //    timer?.invalidate()
  //    timer = nil
  //  }
  
  
  
  //  func reportScrollChange(_ offset: CGPoint) {
  //    onScrollChange?(offset)
  //  }
  
  //  deinit {
  //    scrollOffsetMonitor.stopMonitoring()
  //  }
  
}

actor TimerActor {
  private var timer: Timer?
  private var tickCount = 0
  private var onTimerTick: ((Int) -> Void)?
  
  func startTimer(interval: TimeInterval, onTick: @escaping (Int) -> Void) {
    stopTimer()
    onTimerTick = onTick
    timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
      Task { [weak self] in
        await self?.timerTicked()
      }
    }
  }
  
  func stopTimer() {
    timer?.invalidate()
    timer = nil
    tickCount = 0
  }
  
  private func timerTicked() {
    tickCount += 1
    onTimerTick?(tickCount)
  }
  
  deinit {
    stopTimer()
  }
}


//actor ScrollOffsetMonitor {
//  private var lastReportedOffset: CGPoint = .zero
//  private var task: Task<Void, Never>?
//
//  func startMonitoring(for textView: MarkdownTextView) async {
//    task = Task {
//      while !Task.isCancelled {
//        let currentOffset = await textView.visibleRect.origin
//        if currentOffset != lastReportedOffset {
//          lastReportedOffset = currentOffset
//          await textView.reportScrollChange(currentOffset)
//        }
//        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
//      }
//    }
//  }
//
//  func stopMonitoring() {
//    task?.cancel()
//    task = nil
//  }
//}
