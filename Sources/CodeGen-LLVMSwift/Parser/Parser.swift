//
//  File.swift
//  
//
//  Created by Chirag Ramani on 19/04/21.
//

import Foundation

final class Parser {
    
    private let tokenKinds: [TokenKind]
    private var currentIndex = 0
    
    init(tokenKinds: [TokenKind]) {
        self.tokenKinds = tokenKinds
    }
    
    func parse() throws -> AST {
        var expressions = [Expr]()
        while tokensAvailable {
            expressions.append(try parseExpression())
        }
        return AST(expressions: expressions)
    }
    
    // MARK: Private
    
    private var tokensAvailable: Bool {
        currentIndex < tokenKinds.count
    }
    
    private func parseExpression() throws -> Expr {
        switch currentToken {
        case .funcKeyword:
            return try parseFunctionDeclaration()
        case .letKeyword:
            return try parseConstantDeclaration()
        case .varKeyword:
            return try parseVariableDeclaration()
        case .printKeyword:
            return try parsePrintStatement()
        case .returnKeyword:
            return try parseReturnStatement()
        case .ifKeyword:
            return try parseIfStatement()
        default:
            // This can be a function call: calculate(score: 5)
            // Or this can be an assignment a = 5; b = "Abc"; c = 10.
            // or even a revursive expression visit. 
            return try parseBasicExpression()
        }
    }
    
    private var currentToken: TokenKind? {
        return currentIndex < tokenKinds.count ? tokenKinds[currentIndex] : nil
    }
    
    private var nextToken: TokenKind? {
        let nextIndex = currentIndex + 1
        return nextIndex < tokenKinds.count ? tokenKinds[nextIndex] : nil
    }
    
    private func consumeToken(n: Int = 1) {
        currentIndex += n
    }
    
    private func parseReturnStatement() throws -> ReturnStatement {
        guard currentToken == .returnKeyword else {
            throw ParserError.expectedReturnKeyword
        }
        consumeToken()
        return ReturnStatement(value: try parseBasicExpression())
    }
    
    private func parsePrintStatement() throws -> PrintStatement {
        guard currentToken == .printKeyword else {
            throw ParserError.expectedPrintKeyword
        }
        consumeToken()
        return PrintStatement(value: try parseFunctionCallArguments())
    }
    
    private func parseFunctionDeclaration() throws -> FunctionDeclaration {
        guard currentToken == .funcKeyword else {
            throw ParserError.expectedTokenKindFuncKeyword
        }
        consumeToken()
        guard case let .identifier(functionName) = currentToken else {
            throw ParserError.expectedIdentifier
        }
        // Parse arguments
        consumeToken()
        let arguments = try parseFunctionArguments()
        
        // Parse Return type
        let returnType = try parseReturnType()
        
        // Parse body
        if let body = try parseBasicExpression() as? FunctionBodyExpression {
            let functionDeclaration = FunctionDeclaration(name: functionName,
                                                          arguments: arguments,
                                                          returnType: returnType,
                                                          body: body)
            return functionDeclaration
        } else {
            throw ParserError.invalidFunctionBodyExpression
        }
    }
    
    private func parseFunctionArguments() throws -> [FunctionArgument] {
        var arguments = [FunctionArgument]()
        guard currentToken == .leftParen else {
            throw ParserError.expectedLeftParen
        }
        consumeToken()
        while currentToken != .rightParen {
            /// Argument Name
            guard case let .identifier(argumentName) = currentToken else {
                throw ParserError.expectedIdentifier
            }
            consumeToken()
            guard case .colon = currentToken else {
                throw ParserError.expectedColon
            }
            consumeToken()
            /// Argument type
            guard case let .primitiveType(type) = currentToken else {
                throw ParserError.expectedIdentifier
            }
            let argument = FunctionArgument(name: argumentName,
                                            type: type)
            arguments.append(argument)
            consumeToken()
            if currentToken == .comma {
                consumeToken()
            }
        }
        consumeToken()
        return arguments
    }
    
    private func parseReturnType() throws -> PrimitiveType {
        guard currentToken != .leftBrace else {
            return .void
        }
        guard currentToken == .functionArrow else {
            throw ParserError.expectedFunctionArrow
        }
        consumeToken()
        guard case let .primitiveType(type) = currentToken else {
            throw ParserError.expectedIdentifier
        }
        consumeToken()
        return type
    }
    
    private func parseIfStatement() throws -> IfStatement {
        fatalError()
    }
    
    private func parseVariableDeclaration() throws -> Expr {
        guard currentToken == .varKeyword else {
            throw ParserError.expectedVarKeyword
        }
        consumeToken()
        
        guard case let .identifier(name) = currentToken else {
            throw ParserError.expectedIdentifier
        }
        consumeToken()
        // The current token can be either an assignment or : (for type).
        var type: PrimitiveType?
        // TODO: Type to be more expressive - when its supposed to be inferred and when its not supposed to be inferred.
        let variableDeclaration = VariableDeclaration(name: name,
                                                      type: type!)
        
        if case .colon = currentToken {
            consumeToken()
            type = try getType()
        }
        
        
        if .equals == currentToken {
            return AssignmentExpression(lhs: .variable(variableDeclaration),
                                        rhs: try parseBasicExpression())
        }
        return variableDeclaration
    }
    
    private func getType() throws -> PrimitiveType {
        guard case let .primitiveType(primitiveType) = currentToken else {
            throw ParserError.expectedPrimitiveType
        }
        consumeToken()
        return primitiveType
    }
    
    private func parseConstantDeclaration() throws -> Expr {
        guard currentToken == .letKeyword else {
            throw ParserError.expectedLetKeyword
        }
        consumeToken()
        
        guard case let .identifier(name) = currentToken else {
            throw ParserError.expectedIdentifier
        }
        consumeToken()
        // The current token can be either an assignment or : (for type).
        var type: PrimitiveType = .void
        // TODO: Type to be more expressive - when its supposed to be inferred and when its not supposed to be inferred.
        
        
        if case .colon = currentToken {
            consumeToken()
            type = try getType()
        }
        
        let constantDeclaration = ConstantDeclaration(name: name,
                                                      type: type)
        
        if .equals == currentToken {
            consumeToken()
            return AssignmentExpression(lhs: .constant(constantDeclaration),
                                        rhs: try parseBasicExpression())
        }
        return constantDeclaration
    }
    
    // This can be a function call: main(score: 5)
    // Or this can be an assignment a = 5; b = "Abc"; c = 10.
    // Or an opening of a new function scope.
    // or an opening of a new parentheses.
    private func parseBasicExpression() throws -> Expr {
        switch currentToken {
        case .leftBrace:
            return try parseOpenBrace()
        case .leftParen:
            return try parseOpenParen()
        case .identifier(let name):
            if nextToken == .leftParen {
                consumeToken()
                let arguments = try parseFunctionCallArguments()
                return FunctionCallExpression(name: name,
                                              arguments: arguments)
            } else {
                consumeToken()
                let propertyReferenceExpression = PropertyReadExpression(name: name)
                if currentToken?.isBinaryOperator == true {
                    return try parseBinaryOperator(lhs: propertyReferenceExpression)
                } else {
                    return propertyReferenceExpression
                }
            }
        case .floatLiteral(let floatValue):
            consumeToken()
            let floatExpression = FloatExpression(value: floatValue)
            if currentToken?.isBinaryOperator == true {
                return try parseBinaryOperator(lhs: floatExpression)
            } else {
                return floatExpression
            }
        case .booleanLiteral(let booleanValue):
            consumeToken()
            let booleanExpression = BooleanExpression(value: booleanValue)
            if currentToken?.isBinaryOperator == true {
                return try parseBinaryOperator(lhs: booleanExpression)
            } else {
                return booleanExpression
            }
        case .stringLiteral(let stringValue):
            consumeToken()
            let stringExpression = StringExpression(value: stringValue)
            if currentToken?.isBinaryOperator == true {
                return try parseBinaryOperator(lhs: stringExpression)
            } else {
                return stringExpression
            }
        case .integerLiteral(let integerValue):
            consumeToken()
            let integerExpression = IntegerExpression(value: integerValue)
            if currentToken?.isBinaryOperator == true {
                return try parseBinaryOperator(lhs: integerExpression)
            } else {
                return integerExpression
            }
        default:
            throw ParserError.unknown
        }
    }
    
    /// Doesnt take precendence into account
    private func parseBinaryOperator(lhs: Expr) throws -> Expr {
        var leftExpression = lhs
        while case .binaryOperator(let op) = currentToken {
            consumeToken()
            let rhs = try parseBasicExpression()
            leftExpression = BinaryExpression(lhs: leftExpression,
                                            rhs: rhs,
                                            op: op)
        }
        return leftExpression
    }
    
    private func parseFunctionCallArguments() throws -> [FunctionCallArgumentType] {
        guard case .leftParen = currentToken else {
            throw ParserError.expectedIdentifier
        }
        consumeToken()
        var arguments: [FunctionCallArgumentType] = []
        while currentToken != .rightParen {
            guard case let .identifier(name) = currentToken else {
                throw ParserError.expectedIdentifier
            }
            consumeToken()
            if currentToken == .colon, let nextToken = nextToken {
                switch nextToken {
                case .floatLiteral(let floatValue):
                    arguments.append(.labelled(labelName: name,
                                               value: FloatExpression(value: floatValue)))
                case .booleanLiteral(let booleanValue):
                    arguments.append(.labelled(labelName: name,
                                               value: BooleanExpression(value: booleanValue)))
                case .stringLiteral(let stringValue):
                    arguments.append(.labelled(labelName: name,
                                               value: StringExpression(value: stringValue)))
                case .integerLiteral(let integerValue):
                    arguments.append(.labelled(labelName: name,
                                               value: IntegerExpression(value: integerValue)))
                default:
                    throw ParserError.expectedLiteralValue
                }
                consumeToken(n: 2)
                if currentToken == .comma {
                    consumeToken()
                }
            } else if currentToken == .comma {
                arguments.append(.propertyReference(PropertyReadExpression(name: name)))
                consumeToken()
            } else if currentToken == .rightParen {
                arguments.append(.propertyReference(PropertyReadExpression(name: name)))
            } else {
                throw ParserError.unknown
            }
        }
        consumeToken()
        return arguments
    }
    
    private func parseOpenBrace() throws -> Expr {
        guard currentToken == .leftBrace else {
            throw ParserError.expectedTokenKindFuncKeyword
        }
        consumeToken()
        var body = [Expr]()
        while currentToken != .rightBrace {
            let expression = try parseExpression()
            body.append(expression)
        }
        consumeToken()
        return FunctionBodyExpression(expressions: body)
    }
    
    private func parseOpenParen() throws -> Expr {
        guard currentToken == .leftParen else {
            throw ParserError.expectedTokenKindFuncKeyword
        }
        consumeToken()
        let expression = try parseBasicExpression()
        guard currentToken == .rightParen else {
            throw ParserError.expectedTokenKindFuncKeyword
        }
        consumeToken()
        return expression
    }
}
