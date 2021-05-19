//
//  File.swift
//  
//
//  Created by Chirag Ramani on 19/05/21.
//

import Foundation

enum FunctionCallArgumentType: Expr, CustomStringConvertible {
    case labelled(labelName: String, value: Expr)
    case propertyReference(PropertyReadExpression)
    
    var nodeVariantType: NodeVariantType  {
        .functionCallExpression
    }
    
    var description: String {
        "FunctionCallArgumentType: \(debugDescription)"
    }
    
    private var debugDescription: String {
        switch self {
        case let .labelled(labelName, value):
            return "labelName: \(labelName), \(value)"
        case .propertyReference(let propertyReference):
            return propertyReference.description
        }
    }
}

struct PrintStatement: Expr, CustomStringConvertible {
    /// Print is basically a function all - either printing some constant or some expression's description post evaluation.
    let value: [FunctionCallArgumentType]
    let nodeVariantType: NodeVariantType = .printStatement
    
    var description: String {
        "PrintStatement values: \(value.map { $0.description })"
    }
}
