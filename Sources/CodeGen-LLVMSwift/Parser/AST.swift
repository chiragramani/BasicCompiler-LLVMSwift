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
                addFunctionDeclaration(functionDeclaration)
            } else if let constantDeclaration = expr as? ConstantDeclaration {
                addConstantDeclaration(constantDeclaration)
            } else if let variableDeclaration = expr as? VariableDeclaration {
                addVariableDeclaration(variableDeclaration)
            } else if let printStatement = expr as? PrintStatement {
                addPrintStatement(printStatement)
            } else if let returnStatement = expr as? ReturnStatement {
                addReturnStatement(returnStatement)
            } else if let ifStatement = expr as? IfStatement {
                addIfStatement(ifStatement)
            } else {
                fatalError("Currently accepting a limited set of expressions for construct the high level AST :)")
            }
        }
    }
    
    private func addFunctionDeclaration(_ functionDeclaration: FunctionDeclaration) {
        nodes.append(.functionDeclaration(functionDeclaration))
    }
    
    private func addConstantDeclaration(_ constantDeclaration: ConstantDeclaration) {
        nodes.append(.constantDeclaration(constantDeclaration))
    }
    
    private func addVariableDeclaration(_ variableDeclaration: VariableDeclaration) {
        nodes.append(.variableDeclaration(variableDeclaration))
    }
    
    private func addPrintStatement(_ printStatement: PrintStatement) {
        nodes.append(.printStatement(printStatement))
    }
    
    private func addReturnStatement(_ returnStatement: ReturnStatement) {
        nodes.append(.returnStatement(returnStatement))
    }
    
    private func addIfStatement(_ ifStatement: IfStatement) {
        nodes.append(.ifStatement(ifStatement))
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
