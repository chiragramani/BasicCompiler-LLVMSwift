//
//  File.swift
//  
//
//  Created by Chirag Ramani on 19/05/21.
//

import Foundation

struct BinaryExpression: Expr {
    let lhs: Expr
    let rhs: Expr
    let op: BinaryOperator
    let nodeVariantType: NodeVariantType = .binaryExpression
}
