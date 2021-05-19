//
//  File.swift
//  
//
//  Created by Chirag Ramani on 19/05/21.
//

import Foundation

struct ReturnStatement: Expr {
    /// The value can be a simple expression such as a constant integer or maybe an expression involving some computation.
    let value: Expr
    let nodeVariantType: NodeVariantType = .returnStatement
}
