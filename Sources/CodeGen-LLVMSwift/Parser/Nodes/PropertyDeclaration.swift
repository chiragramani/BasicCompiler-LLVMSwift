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
    
    var description: String {
        """
        ConstantDeclaration
            name: \(name),
            type: \(type)
        """
    }
}

// For ex, "var a: Int"
struct VariableDeclaration: Expr {
    let name: String
    let type: PrimitiveType
    let nodeVariantType: NodeVariantType = .variableDeclaration
    
    var description: String {
        "VariableDeclaration name: \(name), type: \(type)"
    }
}
