//
//  File.swift
//  
//
//  Created by Chirag Ramani on 19/05/21.
//

import Foundation

// For ex, "let a: Int"
struct ConstantDeclaration: Expr {
    let name: String
    let type: PrimitiveType
    let nodeVariantType: NodeVariantType = .constantDeclaration
}

// For ex, "var a: Int"
struct VariableDeclaration: Expr {
    let name: String
    let type: PrimitiveType
    let nodeVariantType: NodeVariantType = .variableDeclaration
}
