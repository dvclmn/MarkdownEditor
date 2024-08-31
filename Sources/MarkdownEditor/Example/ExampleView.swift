//
//  SwiftUIView.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import SwiftUI
import Scrolling
import Geometry

struct ExampleView: View {
  
  @State private var text: String = Self.shortSample
  @State private var editorInfo: EditorInfo? = nil
  
  var body: some View {
    
    VStack(spacing: 0) {
      
//      Spacer()
      
      MarkdownEditor(
        text: $text,
        configuration: EditorConfiguration(isShowingFrames: false)) { info in
          self.editorInfo = info
        }
//        .frame(height: 300)
        .frame(maxWidth: .infinity, alignment: .top)
//        .border(Color.green.opacity(0.3))
      
      
      HStack(alignment: .bottom) {
        Text(self.editorInfo?.selection.summary ?? "nil")
        Spacer()
        Text(self.editorInfo?.scroll.summary ?? "nil")
        Spacer()
        Text(self.editorInfo?.text.summary ?? "nil")
      }
      .foregroundStyle(.secondary)
      .font(.callout)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 30)
      .padding(.top, 10)
      .padding(.bottom, 14)
      .background(.black.opacity(0.5))
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
    .frame(width: 400, height: 700)
  }
}

extension ExampleView {
  
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
