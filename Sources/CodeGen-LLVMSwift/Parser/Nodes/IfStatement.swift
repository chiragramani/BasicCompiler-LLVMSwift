//
//  File.swift
//  
//
//  Created by Chirag Ramani on 19/05/21.
//

import Foundation

struct ConditionalBody {
    let value: [Expr]
}

/// It limits to one if-else pair and doesn't allow else if ladder. Else part is optional.
struct IfStatement: Expr {
    let condition: Expr
    let ifBody: ConditionalBody
    let elseBody: ConditionalBody?
    let nodeVariantType: NodeVariantType = .ifStatement
}
