//
//  File.swift
//  
//
//  Created by Chirag Ramani on 19/05/21.
//

import Foundation

struct ConditionalBody: Expr {
    let value: [Expr]
    var nodeVariantType: NodeVariantType
    
    var description: String
    
    
}

/// It limits to one if-else pair and doesn't allow else if ladder. Else part is optional.
struct IfStatement: Expr, CustomStringConvertible {
    let condition: Expr
    let ifBody: ConditionalBody
    let elseBody: ConditionalBody?
    let nodeVariantType: NodeVariantType = .ifStatement
    
    var description: String {
        "IfStatement condition: \(condition.description), ifBody: \(ifBody.description), elseBody: \(elseBody?.description ?? "nil")"
    }
}
