//
//  File.swift
//  
//
//  Created by Chirag Ramani on 19/05/21.
//

import Foundation

struct IntegerExpression: Expr {
    let value: Int
    let nodeVariantType: NodeVariantType = .integerExpression
}

struct FloatExpression: Expr {
    let value: Float
    let nodeVariantType: NodeVariantType = .floatExpression
}

struct StringExpression: Expr {
    let value: String
    let nodeVariantType: NodeVariantType = .stringExpression
}

struct BooleanExpression: Expr {
    let value: Bool
    let nodeVariantType: NodeVariantType = .booleanExpression
}
