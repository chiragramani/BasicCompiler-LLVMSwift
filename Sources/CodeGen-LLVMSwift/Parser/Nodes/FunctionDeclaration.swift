//
//  File.swift
//  
//
//  Created by Chirag Ramani on 19/05/21.
//

import Foundation

struct FunctionBodyExpression: Expr, CustomStringConvertible {
    let expressions: [Expr]
    let nodeVariantType: NodeVariantType = .functionBodyExpression
    
    var description: String {
        "FunctionBodyExpression expressions: \([expressions.map{ $0.description }])"
    }
}

/// An argument passed. An argument has a well defined name and a type.
/// For ex, "func main(a: Int)" - "a" is the name of the argument and "Int" is the type of the argument.
struct FunctionArgument {
    let name: String
    let type: PrimitiveType
}

struct FunctionDeclaration: Expr, CustomStringConvertible {
    let name: String
    let arguments: [FunctionArgument]
    let returnType: PrimitiveType
    let body: FunctionBodyExpression
    let nodeVariantType: NodeVariantType = .functionDeclaration
    
    var description: String {
        "FunctionDeclaration -> name: \(name),arguments: \(arguments),returnType: \(returnType),body: \(body)"
    }
}
