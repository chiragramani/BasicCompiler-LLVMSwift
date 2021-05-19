//
//  File.swift
//  
//
//  Created by Chirag Ramani on 19/05/21.
//

import Foundation

struct BinaryExpression: Expr, CustomStringConvertible {
    let lhs: Expr
    let rhs: Expr
    let op: BinaryOperator
    let nodeVariantType: NodeVariantType = .binaryExpression
    
    var description: String {
        "lhs: \(lhs.description), rhs: \(rhs.description), op: \(op)"
    }
}
