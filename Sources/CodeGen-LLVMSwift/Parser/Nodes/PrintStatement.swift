//
//  File.swift
//  
//
//  Created by Chirag Ramani on 19/05/21.
//

import Foundation

enum FunctionCallArgumentType: Expr {
    case labelled(labelName: String, value: Expr)
    case propertyReference(PropertyReadExpression)
    
    var nodeVariantType: NodeVariantType  {
        .functionCallExpression
    }
}

struct PrintStatement: Expr {
    /// Print is basically a function all - either printing some constant or some expression's description post evaluation.
    let value: [FunctionCallArgumentType]
    let nodeVariantType: NodeVariantType = .printStatement
}
