//
//  File.swift
//  
//
//  Created by Chirag Ramani on 18/04/21.
//

import Foundation

enum BinaryOperator {
    case plus
    case minus
    case times
    case divide
    case mod
    case equals
}


// Supports
/// 1 Supports a very smaller subset of grammar
/// 2 How does the compile type or runtime metadata varies when different acess controls are provided
/// 3 How IR emission works? How is SIL benefitting us?
enum TokenKind {
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
    
    case comma
    case colon
    
    case binaryOperator(BinaryOperator)
    
    case functionArrow
    
    case integerLiteral(Int)
    case floatLiteral(Float)
    case stringLiteral(String)
    case booleanLiteral(Bool)
    
    case integerType
    case booleanType
    case stringType
    case floatType

    case identifier(String)
    
    static let singleLengthToken: Set<Character> = ["(", ")", "{", "}", ",", ":", "="]
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
            self = .binaryOperator(.equals)
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
            self = .integerType
        case "Bool":
            self = .booleanType
        case "String":
            self = .stringType
        case "Float":
            self = .floatType
            
        case _ where RegexKind.identifier.matches(lexeme):
            self = .identifier(lexeme)
        case _ where RegexKind.float.matches(lexeme):
            guard let floatValue = Float(lexeme) else { return nil }
            self = .floatLiteral(floatValue)
        case _ where RegexKind.integer.matches(lexeme):
            guard let integerValue = Int(lexeme) else { return nil }
            self = .integerLiteral(integerValue)
        case _ where RegexKind.string.matches(lexeme):
            self = .stringLiteral(lexeme)
        default:
            fatalError("Couldnt construct a token for lexeme: \(lexeme)")
        }
    }
}

enum RegexKind {
    static let float = try! NSRegularExpression(pattern: "[0-9]+\\.[0-9]*")
    static let integer = try! NSRegularExpression(pattern: "[0-9]+")
    static let string = try! NSRegularExpression(pattern: "\".*\"")
    static let identifier = try! NSRegularExpression(pattern: "[a-zA-Z][a-zA-Z0-9]*")
    static let spacesNewLinesTabs = try! NSRegularExpression(pattern: "[ \t\n]+")
}

extension NSRegularExpression {
    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}
