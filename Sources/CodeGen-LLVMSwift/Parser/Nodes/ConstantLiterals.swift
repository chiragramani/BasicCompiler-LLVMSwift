//
//  File.swift
//  
//
//  Created by Chirag Ramani on 19/05/21.
//

import Foundation

struct IntegerExpression: Expr, CustomStringConvertible {
    let value: Int
    let nodeVariantType: NodeVariantType = .integerExpression
    
    var description: String {
        "IntegerExpression value: \(value)"
    }
}

struct FloatExpression: Expr, CustomStringConvertible {
    let value: Float
    let nodeVariantType: NodeVariantType = .floatExpression
    
    var description: String {
        "FloatExpression value: \(value)"
    }
}

struct StringExpression: Expr, CustomStringConvertible {
    let value: String
    let nodeVariantType: NodeVariantType = .stringExpression
    
    var description: String {
        "StringExpression value: \(value)"
    }
}

struct BooleanExpression: Expr, CustomStringConvertible {
    let value: Bool
    let nodeVariantType: NodeVariantType = .booleanExpression
    
    var description: String {
        "BooleanExpression value: \(value)"
    }
}
