//
//  Regex.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 20/8/2024.
//

import RegexBuilder



extension Markdown.Syntax {
  
  /// # Regex reference
  ///
  /// ## Basics
  ///
  /// 1. Starting Position:
  /// The regex engine starts at the beginning of the string.
  ///
  /// 2. Matching Attempt:
  /// It tries to match the pattern from the current position.
  ///
  /// 3. Success or Failure:
  /// If a match is found, it's recorded. If not, the engine moves to the next position.
  ///
  /// 4. Repeat:
  /// Steps 2 and 3 are repeated until the end of the string is reached.
  ///
  /// ## Character classes
  ///
  /// `[abc]` One or more characters enclosed in square brackets. Character classes
  /// match any one character from the set of characters specified within the brackets.
  ///
  /// To better understand how character classes work, let's compare them to specifying
  /// a simple character (or run of characters), say `a`. In this case, the engine will check for
  /// the presence of an `a`, at each position in the text.
  ///
  /// Suppose we have the regex pattern `cat` and the string "I have a cat and a dog".
  ///
  /// 1. The engine starts at 'I'.
  /// 2. It checks if 'Iha' matches 'cat'. It doesn't.
  /// 3. It moves to 'h' and checks 'hav'. No match.
  /// 4. This continues until it reaches the 'c' in 'cat'.
  /// 5. It checks 'cat' against 'cat'. It matches!
  /// 6. The match is recorded, and the process continues for the rest of the string.
  ///
  /// Now, let's consider character classes:
  ///
  /// With the regex [cd]at and the same string:
  ///
  /// 1. The engine starts at 'I' and proceeds as before.
  /// 2. When it reaches 'c', it checks if 'c' matches either 'c' or 'd' (the character class).
  /// 3. It does, so it then checks if 'a' follows, then 't'.
  /// 4. The full match 'cat' is found and recorded.
  ///
  /// The key difference with character classes is that at each position, the engine is checking against a set of possible characters, rather than a specific character.
  ///
  /// Another way of looking at it is this. Take the pattern `ab`. This will only match an
  /// `a` directly next to a `b`. In contrast, `[ab]` will match any old `a` it finds, as
  /// well as any old `b`.
  ///
  ///
  /// Non-greedy matching: `.*?` is used in several patterns to match any characters
  /// in a non-greedy manner, ensuring the shortest possible match.
  ///
  /// Character negation: `[^\]]` and `[^\)]` are used to match any character
  /// except closing square brackets and closing parentheses, respectively.
  ///
  /// 3. Multiline mode: `(?m)` is used in the code block pattern to enable multiline
  /// mode, allowing `^` to match the start of each line.
  ///
  /// 4. Positive lookahead: `(?!`)` is used in the inline code pattern to ensure that the closing backtick is not followed by another backtick.
  ///
  /// 5. Escaping special characters: `\*`, `\_`, and `\[` are used to match literal
  /// asterisks, underscores, and square brackets, respectively.
  ///
  /// 6. Matching any character including newlines: `[\s\S]` is used in the code block
  /// pattern to match any character, including newlines.
  ///
  ///
  public var regex: Regex<(
    Substring,
    leading: Substring,
    content: Substring,
    trailing: Substring
  )> {
    switch self {
        
        /// `^# ` The caret ensures this only matches if the string starts on a new line
        /// The `$` matches the end of a line.
        ///
      case .heading(let level):
        
        if level == 1 {
          return /^(?<leading>#) (?<content>.*$)(?<trailing>)/
          
        } else if level == 2 {
          return /^(?<leading>##) (?<content>.*$)(?<trailing>)/
          
        } else if level == 3 {
          return /^(?<leading>###) (?<content>.*$)(?<trailing>)/
          
        } else if level == 4 {
          return /^(?<leading>####) (?<content>.*$)(?<trailing>)/
          
        } else if level == 5 {
          return /^(?<leading>#####) (?<content>.*$)(?<trailing>)/
          
        } else {
          return /^(?<leading>######) (?<content>.*$)(?<trailing>)/
        }
        
      case .bold:
        
        return /(?<leading>__|\*\*)(?<content>[^_|\*]*?)(?<trailing>__|\*\*)/
//        switch style {
            
            /// `[^\*]` This is a 'negated set' or 'negated character class'. The caret here means 'match
            /// anything that *isn't* the following character(s). The character being negated is an asterisk,
            /// which needs to be escaped, hence the backslash.
            ///
            /// The non-escaped asterisk (the one performing an active role in the regex!) is a 'quantifier'.
            /// It means 'match zero or more of the preceding token'. The question mark `?` makes the
            /// expression 'lazy' / 'non-greedy' / 'reluctant'. It will match as few characters as possible,
            /// preventing the match from spilling out and finding matches that — depending on your
            /// needs — you may not want to have matched.
            ///
//          case .asterisk:
//            return /\*\*[^\*]*?\*\*/
            
            /// Matches bold text with underscores: Two underscores, followed by any characters (non-greedy), ending with two underscores
            ///
//          case .underscore:
//            return /__[^_]*?__/
        
      case .italic(let style):
        switch style {
            
            /// Matches italic text with asterisks: One asterisk, followed by any characters (non-greedy), ending with one asterisk
            ///
          case .asterisk:
            return /\*[^\*]*?\*/
            
            
            /// Matches italic text with underscores: One underscore, followed by any characters (non-greedy), ending with one underscore
            ///
          case .underscore:
            return /_.*?_/
        }
        
      case .boldItalic(let style):
        switch style {
            
            /// Matches bold and italic text with asterisks: Three asterisks, followed by any characters (non-greedy), ending with three asterisks
            ///
          case .asterisk:
            return /\*\*\*.*?\*\*\*/
            
            /// Matches bold and italic text with underscores: Three underscores, followed by any characters (non-greedy), ending with three underscores
            ///
          case .underscore:
            return /___.*?___/
        }
        
        
        /// Matches strikethrough text: Two tildes, followed by any characters (non-greedy), ending with two tildes
      case .strikethrough:
        return /~~.*?~~/
        
        /// Matches highlighted text: Two equal signs, followed by any characters (non-greedy), ending with two equal signs
      case .highlight:
        return /==.*?==/
        
        /// Matches inline code: A backtick, followed by one or more characters that are not newlines or backticks,
        /// not followed by two backticks, ending with a backtick not followed by another backtick
        /// Note: This complex pattern ensures that it doesn't match multi-line code blocks or nested backticks
      case .inlineCode:
        return /`[^\n`]+(?!``)`(?!`)/
        
        /// Matches a simple list item: A hyphen followed by a space and any characters until the end of the line
        /// Note: This is a placeholder and needs proper implementation for nested lists
      case .list(_):
        return /- .*?/
        
        /// Matches a horizontal rule: Three hyphens
      case .horizontalRule:
        return /---/
        
        /// Matches a code block: Starts with three backticks, includes any characters (including newlines),
        /// and ends with three backticks at the start of a line
        /// Note: (?m) enables multiline mode, [\s\S] matches any character including newlines
      case .codeBlock:
        return /(?m)^```[\s\S]*?^```/
        
        /// Matches a quote block: A '>' followed by a space at the start of a line, then any characters until the end of the line
      case .quoteBlock:
        return /^> .*/
        
        /// Matches a link: Text in square brackets followed by a URL in parentheses
        /// Note: `[^\]]+` matches one or more characters that are not closing square brackets
        /// `[^\)]+` matches one or more characters that are not closing parentheses
      case .link:
        return  /\[[^\]]+\]\([^\)]+\)/
        
        /// Matches an image reference: Similar to a link, but prefixed with an exclamation mark
        /// Note: The pattern is identical to the link pattern, just with a leading '!'
        ///
      case .image:
        return  /!\[[^\]]+\]\([^\)]+\)/
    }
  }
  
  
  
  
}
