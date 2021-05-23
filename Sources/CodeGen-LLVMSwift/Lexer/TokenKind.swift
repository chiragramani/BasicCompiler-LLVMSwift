//
//  File.swift
//  
//
//  Created by Chirag Ramani on 18/04/21.
//

import Foundation

enum TokenKind: Equatable {
    case funcKeyword
    case letKeyword
    case varKeyword
    case ifKeyword
    case elseKeyword
    case returnKeyword
    case printKeyword
    
    case leftParen
    case rightParen
    case leftBrace
    case rightBrace
    
    case equals
    
    case comma
    case colon
    
    case binaryOperator(BinaryOperator)
    
    case functionArrow
    
    case integerLiteral(Int)
    case floatLiteral(Float)
    case stringLiteral(String)
    case booleanLiteral(Bool)
    
    case primitiveType(PrimitiveType)

    case identifier(String)
}

extension TokenKind {
    init?(lexeme: String) {
        guard !lexeme.isEmpty else { return nil }
        switch lexeme {
        case _ where RegexKind.spacesNewLinesTabs.matches(lexeme):
            return nil
        case "func":
            self = .funcKeyword
        case "let":
            self = .letKeyword
        case "var":
            self = .varKeyword
        case "if":
            self = .ifKeyword
        case "else":
            self = .elseKeyword
        case "return":
            self = .returnKeyword
        case "print":
            self = .printKeyword
            
        case "(":
            self = .leftParen
        case ")":
            self = .rightParen
        case "{":
            self = .leftBrace
        case "}":
            self = .rightBrace
        case ",":
            self = .comma
        case ":":
            self = .colon
            
        case "+":
            self = .binaryOperator(.plus)
        case "-":
            self = .binaryOperator(.minus)
        case "=":
            self = .equals
        case "%":
            self = .binaryOperator(.mod)
        case "*":
            self = .binaryOperator(.times)
        case "/":
            self = .binaryOperator(.divide)
            
        case "->":
            self = .functionArrow
            
        case "true":
            self = .booleanLiteral(true)
        case "false":
            self = .booleanLiteral(false)
            
        case "Int":
            self = .primitiveType(.integer)
        case "Bool":
            self = .primitiveType(.bool)
        case "String":
            self = .primitiveType(.string)
        case "Float":
            self = .primitiveType(.float)
            
        case _ where RegexKind.identifier.matches(lexeme):
            self = .identifier(RegexKind.identifier.firstMatched(lexeme))
        case _ where RegexKind.float.matches(lexeme):
            guard let floatValue = Float(lexeme) else { return nil }
            self = .floatLiteral(floatValue)
        case _ where RegexKind.integer.matches(lexeme):
            guard let integerValue = Int(lexeme) else { return nil }
            self = .integerLiteral(integerValue)
        case _ where RegexKind.string.matches(lexeme):
            self = .stringLiteral(RegexKind.string.firstMatched(lexeme))
        default:
            fatalError("Couldnt construct a token for lexeme: \(lexeme)")
        }
    }
    
    var isBinaryOperator: Bool {
        switch self {
        case .binaryOperator:
            return true
        default:
            return false
        }
    }
    
    static let singleLengthTokens: Set<Character> = ["(", ")", "{", "}", ",", ":", "=", "+", "-", "*", "/", "%"]
    
}
