//
//  File.swift
//  
//
//  Created by Chirag Ramani on 19/04/21.
//

import Foundation

enum Node {
    case functionDeclaration(FunctionDeclaration)
    case constantDeclaration(ConstantDeclaration)
    case variableDeclaration(VariableDeclaration)
    case printStatement(PrintStatement)
    case returnStatement(ReturnStatement)
    case ifStatement(IfStatement)
}

final class AST {
    private(set) var nodes: [Node] = []
    
    init(expressions: [Expr]) {
        constructNodes(fromExpressions: expressions)
    }
    
    // MARK: Private
    
    private func constructNodes(fromExpressions exprs: [Expr]) {
        exprs.forEach { (expr) in
            if let functionDeclaration = expr as? FunctionDeclaration {
                nodes.append(.functionDeclaration(functionDeclaration))
            } else if let constantDeclaration = expr as? ConstantDeclaration {
                nodes.append(.constantDeclaration(constantDeclaration))
            } else if let variableDeclaration = expr as? VariableDeclaration {
                nodes.append(.variableDeclaration(variableDeclaration))
            } else if let printStatement = expr as? PrintStatement {
                nodes.append(.printStatement(printStatement))
            } else if let returnStatement = expr as? ReturnStatement {
                nodes.append(.returnStatement(returnStatement))
            } else if let ifStatement = expr as? IfStatement {
                nodes.append(.ifStatement(ifStatement))
            } else {
                fatalError("Currently accepting a limited set of expressions for construct the high level AST :)")
            }
        }
    }
}

protocol Expr {}

struct ReturnStatement: Expr {
    let value: Expr
}
struct PrintStatement: Expr {
    let value: Expr
}

struct FunctionDeclaration: Expr {
    let name: String
    let arguments: [ConstantDeclaration]
    let body: Expr
}

struct VariableDeclaration: Expr {
    let name: String
    let value: Expr
}

struct ConstantDeclaration: Expr {
    let name: String
    let value: Expr
}

struct IfStatement: Expr {
    let condition: Expr
    let body: [Expr]
}
