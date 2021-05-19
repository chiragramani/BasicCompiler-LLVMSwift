//
//  File.swift
//  
//
//  Created by Chirag Ramani on 19/04/21.
//

import Foundation

final class AST {
    let expressions: [Expr]
    
    init(expressions: [Expr]) {
        self.expressions = expressions
    }
}

protocol Expr {
    var nodeVariantType: NodeVariantType { get }
    var description: String { get }
}









