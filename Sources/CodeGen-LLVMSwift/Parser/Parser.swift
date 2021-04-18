//
//  File.swift
//  
//
//  Created by Chirag Ramani on 19/04/21.
//

import Foundation

final class Parser {
    
    private let tokenKinds: [TokenKind]
    private var index = 0
    
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
        index < tokenKinds.count
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
            return try parseBasicExpression()
        }
    }
    
    private var currentToken: TokenKind? {
        return index < tokenKinds.count ? tokenKinds[index] : nil
    }
    
    private func consumeToken(n: Int = 1) {
        index += n
    }
    
    private func parseReturnStatement() throws -> ReturnStatement {
        fatalError()
    }
    
    private func parsePrintStatement() throws -> PrintStatement {
        fatalError()
    }
    
    private func parseFunctionDeclaration() throws -> FunctionDeclaration {
        fatalError()
    }
    
    private func parseIfStatement() throws -> IfStatement {
        fatalError()
    }
    
    private func parseVariableDeclaration() throws -> VariableDeclaration {
        fatalError()
    }
    
    private func parseConstantDeclaration() throws -> ConstantDeclaration {
        fatalError()
    }
    
    private func parseBasicExpression() throws -> Expr {
        fatalError()
    }
}



