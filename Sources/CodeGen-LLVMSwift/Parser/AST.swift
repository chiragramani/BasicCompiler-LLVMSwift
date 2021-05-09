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
    case other(Expr)
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
                nodes.append(.other(expr))
            }
        }
    }
}

protocol Expr {}

struct ReturnStatement: Expr {
    let value: Expr
}
struct PrintStatement: Expr {
    let value: [FunctionCallArgumentType]
}

enum ReturnType {
    case void
    case primitiveType(PrimitiveType)
}

struct FunctionDeclaration: Expr {
    let name: String
    let arguments: [FunctionArgument]
    let returnType: ReturnType
    let body: Expr
}

struct FunctionArgument {
    let name: String
    let type: PrimitiveType
}

struct VariableDeclaration: Expr {
    let name: String
    let type: PrimitiveType
}

struct ConstantDeclaration: Expr {
    let name: String
    let type: PrimitiveType?
}

struct PropertyReadExpression: Expr {
    let name: String
}

struct IfStatement: Expr {
    let condition: Expr
    let body: [Expr]
}

struct FunctionCallExpression: Expr {
    let name: String
    let arguments: [FunctionCallArgumentType]
}

enum FunctionCallArgumentType: Expr {
    case labelled(labelName: String, value: Expr)
    case propertyReference(PropertyReadExpression)
}

struct IntegerExpression: Expr {
    let intValue: Int
}

struct FloatExpression: Expr {
    let floatValue: Float
}

struct StringExpression: Expr {
    let stringValue: String
}

struct BooleanExpression: Expr {
    let booleanValue: Bool
}

struct AssignmentExpression: Expr {
    enum AssignmentExpressionLHS {
        case constant(ConstantDeclaration)
        case variable(VariableDeclaration)
    }
    let lhs: AssignmentExpressionLHS
    let value: Expr
}

struct BinaryOperatorExpression: Expr {
    let lhs: Expr
    let rhs: Expr
    let op: BinaryOperator
}

struct FunctionBodyExpression: Expr {
    let body: [Expr]
}
