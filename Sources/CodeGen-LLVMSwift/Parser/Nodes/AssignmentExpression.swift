//
//  File.swift
//  
//
//  Created by Chirag Ramani on 19/05/21.
//

import Foundation

struct AssignmentExpression: Expr, CustomStringConvertible {
    enum AssignmentExpressionLHS: CustomStringConvertible {
        case constant(ConstantDeclaration)
        case variable(VariableDeclaration)
        
        var description: String {
            switch self {
            case .constant(let constantDeclaration):
                return constantDeclaration.name
            case .variable(let variableDeclaration):
                return variableDeclaration.name
            }
        }
    }
    let lhs: AssignmentExpressionLHS
    let rhs: Expr
    let nodeVariantType: NodeVariantType = .assignmentExpression
    
    var description: String {
        "AssignmentExpression, lhs: \(lhs.description), rhs: \(rhs.description)"
    }
}

extension AssignmentExpression {
    var lhsName: String {
        switch lhs {
        case .constant(let constantDeclaration):
            return constantDeclaration.name
        case .variable(let variableDeclaration):
            return variableDeclaration.name
        }
    }
    
    var type: PrimitiveType {
        switch lhs {
        case .constant(let constantDeclaration):
            return constantDeclaration.type
        case .variable(let variableDeclaration):
            return variableDeclaration.type
        }
    }
}

