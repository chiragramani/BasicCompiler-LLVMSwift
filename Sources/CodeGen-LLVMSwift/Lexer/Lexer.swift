//
//  Lexer.swift
//  
//
//  Created by Chirag Ramani on 18/04/21
//

import Foundation

/*
 Lexer: The lexer is responsible for dividing the input stream into individual tokens,
 identifying the token type, and then passing the tokens to the next stage of the compiler which is the Parser.
 */
 
final class Lexer {
    
    init(input: String) {
        self.input = input
        self.index = input.startIndex
    }
    
    func lex() -> [TokenKind] {
        var toks = [TokenKind]()
        while let tok = advanceToNextToken() {
            toks.append(tok)
        }
        return toks
    }
    
    // MARK: Private
    
    private let input: String
    private var index: String.Index
    
    private func successiveAlphaNumericString() -> String {
        var str = ""
        let shouldSkipWhitespaces = currentChar == "\""
        while let char = currentChar,
              isEligible(char: char,
                         shouldSkipWhitespaces: shouldSkipWhitespaces) {
            str.append(char)
            advanceIndex()
        }
        return str
    }
    
    private func isEligible(char: Character,
                      shouldSkipWhitespaces: Bool) -> Bool {
        /// multi-line string isn't supported in this small project.
        if (char.isWhitespace && !char.isNewline) && shouldSkipWhitespaces {
            return true
        }
        if char == "\"" {
            return true
        }
        if char == "." {
            return true
        }
        if char == ">" {
            return true
        }
        if char == "-" {
            return true
        }
        return char.isAlphanumeric
    }
    
    private func advanceIndex() {
        input.formIndex(after: &index)
    }
    
    private var currentChar: Character? {
        return index < input.endIndex ? input[index] : nil
    }
    
    private var nextIndex: String.Index {
        input.index(after: index)
    }
    
    private var nextChar: Character? {
        return nextIndex < input.endIndex ? input[nextIndex] : nil
    }
    
    private func advanceToNextToken() -> TokenKind? {
        // Skipping spaces
        while let char = currentChar,
              RegexKind.spacesNewLinesTabs.matches(String(char)) {
            advanceIndex()
        }
        // If there are no characters left, then we have finishing scanning the input.
        guard let char = currentChar else { return nil }
        
        if isEligibleSingleLengthToken(char),
           let tokenKind = TokenKind(lexeme: String(char)){
            advanceIndex()
            return tokenKind
        } else if let tokenKind = TokenKind(lexeme: successiveAlphaNumericString()) {
            return tokenKind
        } else {
            return advanceToNextToken()
        }
    }
    
    private func isEligibleSingleLengthToken(_ character: Character) -> Bool {
        if character == "-" && nextChar == ">" {
            return false
        }
        return TokenKind.singleLengthTokens.contains(character)
    }
}

private extension Character {
    var isAlphanumeric: Bool {
        RegexKind.alphaNumeric.matches(String(self))
    }
}
