//
//  File.swift
//  
//
//  Created by Chirag Ramani on 19/05/21.
//

import Foundation

struct AssignmentExpression: Expr {
    enum AssignmentExpressionLHS {
        case constant(ConstantDeclaration)
        case variable(VariableDeclaration)
    }
    let lhs: AssignmentExpressionLHS
    let rhs: Expr
    let nodeVariantType: NodeVariantType = .assignmentExpression
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
}

