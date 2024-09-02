//
//  SwiftUIView.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import SwiftUI

struct ExampleView: View {
  
  @State private var text: String = Self.exampleMarkdown
  @State private var editorInfo: EditorInfo? = nil
  @State private var config = MarkdownEditorConfiguration(
    fontSize: 11,
    lineHeight: 1.0,
    renderingAttributes: .markdownRenderingDefaults,
    insertionPointColour: .pink,
    codeColour: .green,
    hasLineNumbers: false,
    isShowingFrames: false,
    insets: 20
  )
  
  var body: some View {
    
    VStack(spacing: 0) {
      
//      Spacer()
      
      MarkdownEditor(text: $text, configuration:config) { info in
          self.editorInfo = info
        }
//        .frame(height: 300)
        .frame(maxWidth: .infinity, alignment: .top)
//        .border(Color.green.opacity(0.3))
      
      
//      HStack(alignment: .bottom) {
//        Text(self.editorInfo?.selection.summary ?? "nil")
//        Spacer()
//        Text(self.editorInfo?.scroll.summary ?? "nil")
//        Spacer()
//        Text(self.editorInfo?.text.scratchPad ?? "nil")
//      }
//      .textSelection(.enabled)
//      .foregroundStyle(.secondary)
//      .font(.callout)
//      .frame(maxWidth: .infinity, alignment: .leading)
//      .padding(.horizontal, 30)
//      .padding(.top, 10)
//      .padding(.bottom, 14)
//      .background(.black.opacity(0.5))
    }
//    .overlay(alignment: .topTrailing) {
//      VStack {
//        //              Text("Local editor height \(self.editorInfo?.frame.height.description ?? "nil")")
//      }
//      .allowsHitTesting(false)
//      .foregroundStyle(.secondary)
//    }
    .background(.black.opacity(0.5))
    .background(.purple.opacity(0.1))
    .frame(width: 300, height: 600)
    
    /// Interestingly, the below 'simulates' text being added to the NSTextView, but NOT
    /// in the same as a user actually focusing the view and typing into it. There appears
    /// to be a difference between these two methods of the text being mutated.
    ///
//    .task {
//      do {
//        try await Task.sleep(for: .seconds(0.8))
//        
//        self.text += "Hello"
//      } catch {
//        
//      }
//    }
  }
}

extension ExampleView {
  
  static let twoInlineCode: String = """
  This brief `inline code`, with text contents, lines `advance expanding` the view in the current writing direction.
  
  It does have more than two paragraphs, which I'm hoping will help me to verify that the code is able to count elements of a particular kind of markdown syntax, not just fragments or paragraphs.
  
  We'll have to just see if it works.
  
  Thank you for sharing your code and explaining your setup. It's great to see you're working on a markdown parsing and styling system using TextKit 2. Let's address your questions and then discuss some ideas for your implementation.
  
  Invalidating Attributes:
  
  When you call invalidateAttributes(in: NSRange) on a text storage, you're essentially telling the text system that the attributes in the specified range may have changed and need to be recalculated. This doesn't `remove` or modify the attributes directly; instead, it triggers the text system to update its internal caches and redraw the affected text. This is useful when you've made `changes` to the text or its `attributes and want` to ensure that the display is updated correctly.
  
  Regarding your markdown parsing and styling setup:
  
  Your approach of separating the parsing (which is more expensive) and the styling (which should be more nimble) is a good strategy. Here are some ideas and suggestions to potentially improve `your implementation`.
  """
  
  static let shortSample: String = """
  This *brief* block quote, with ==text contents==, lines `advance 
  expanding` the view in the current writing direction.ExampleView".
  
  Includes one line break.
  
  Followed by another. In addition, here is a list:
  
  - [AttributeContainer](http://apple.com) is a container for attributes.
  - By configuring the container, we can set, replace, and merge
  - A large number of attributes for a string (or fragment) at once.
  """
  
  static let exampleMarkdown: String = """
    # Markdown samples
    ## Overview of the sample
    
    ```swift
    @State private var selectionInfo: EditorInfo.Selection? = nil
    // @State private var editorHeight: CGFloat = .zero
    ```
    
    Usually, `NSTextView` manages the *layout* process inside **the viewport** interacting ~~with its delegate~~.
    
    - [AttributeContainer](http://apple.com) is a container for attributes.
    - By configuring the container, we can set, replace, and merge
    - A large number of attributes for a string (or fragment) at once.
    
    ```python
    // There is also some basic code
    var x = y
    ```
    
    ### Markdown syntax summary
    A `viewport` is a _rectangular_ area within a ==flipped coordinate system== expanding along the y-axis, with __bold alternate__, as well as ***bold italic*** emphasis.
    
    1. You’d mentioned this is rendered within an OpenGL window
    2. Despite the implementation details under the hood
    3. They can only speculate, but perhaps OpenGL here is useful
    
    > This *brief* block quote, with ==text contents==, lines `advance expanding` the view in the current writing direction.ExampleView
    
    ```swift
    import SwiftUI
    import Combine
    
    class ChatsViewModel: ObservableObject {
      @Dependency(.carerDatabase) var carerDatabase
      @Published var chats = [Chat]()
      @Published var messagesByChatId = [Int64: [Message]]()
    
      func loadChatsAndMessages(forCarer carerId: Int64) async {
          do {
              let chats = try await carerDatabase.fetchChatsForCarer(carerId)
              self.chats = chats
              for chat in chats {
                  let messages = try await carerDatabase.fetchMessagesForChat(chat.id)
                  messagesByChatId[chat.id] = messages
              }
          } catch {
              print("Error fetching chats or messages: ")
          }
      }
    }
    ```
    
    ### Step 2: Create the SwiftUI View
    
    Now, let's create a SwiftUI view that uses this ViewModel to display the chats and their corresponding messages.
    
    1. You’d mentioned this is rendered within an OpenGL window
    2. Despite the implementation details under the hood
    3. They can only speculate, but perhaps OpenGL here is useful
    
    > This *brief* block quote, with ==text contents==, lines `advance expanding` the view in the current writing direction.ExampleView
    
    ```swift
    import SwiftUI
    import Combine
    
    class ChatsViewModel: ObservableObject {
      @Dependency(.carerDatabase) var carerDatabase
      @Published var chats = [Chat]()
      @Published var messagesByChatId = [Int64: [Message]]()
    
      func loadChatsAndMessages(forCarer carerId: Int64) async {
          do {
              let chats = try await carerDatabase.fetchChatsForCarer(carerId)
              self.chats = chats
              for chat in chats {
                  let messages = try await carerDatabase.fetchMessagesForChat(chat.id)
                  messagesByChatId[chat.id] = messages
              }
          } catch {
              print("Error fetching chats or messages: ")
          }
      }
    }
    ```
    
    ### Step 2: Create the SwiftUI View
    
    Now, let's create a SwiftUI view that uses this ViewModel to display the chats and their corresponding messages.
    
    """
}

#Preview {
  ExampleView()
  
}
