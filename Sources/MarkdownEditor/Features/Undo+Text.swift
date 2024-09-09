//
//  Undo+Text.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 9/9/2024.
//

import Foundation

class UndoRedoManager {
  struct Action {
    let oldText: String
    let oldRange: NSRange
    let newText: String
    let newRange: NSRange
    let syntax: Markdown.Syntax
  }
  
  private var undoStack: [Action] = []
  private var redoStack: [Action] = []
  
  func recordAction(oldText: String, oldRange: NSRange, newText: String, newRange: NSRange, syntax: Markdown.Syntax) {
    let action = Action(oldText: oldText, oldRange: oldRange, newText: newText, newRange: newRange, syntax: syntax)
    undoStack.append(action)
    redoStack.removeAll() // Clear redo stack when a new action is performed
  }
  
  func undo() -> Action? {
    guard let action = undoStack.popLast() else { return nil }
    redoStack.append(action)
    return action
  }
  
  func redo() -> Action? {
    guard let action = redoStack.popLast() else { return nil }
    undoStack.append(action)
    return action
  }
}
