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
        while let char = currentChar, char.isAlphanumeric {
            str.append(char)
            advanceIndex()
        }
        return str
    }
    
    private func advanceIndex() {
        input.formIndex(after: &index)
    }
    
    private var currentChar: Character? {
        return index < input.endIndex ? input[index] : nil
    }
    
    private func advanceToNextToken() -> TokenKind? {
        // Skipping spaces
        while let char = currentChar,
              RegexKind.spacesNewLinesTabs.matches(String(char)) {
            advanceIndex()
        }
        // If there are no characters left, then we have finishing scanning the input.
        guard let char = currentChar else { return nil }
        if TokenKind.singleLengthToken.contains(char) {
            advanceIndex()
            return TokenKind(lexeme: String(char))!
        } else if let tokenKind = TokenKind(lexeme: successiveAlphaNumericString()) {
            return tokenKind
        } else {
            return advanceToNextToken()
        }
    }
}

private extension Character {
    var isAlphanumeric: Bool {
        RegexKind.alphaNumeric.matches(String(self))
    }
}
