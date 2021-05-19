//
//  File.swift
//  
//
//  Created by Chirag Ramani on 19/05/21.
//

import Foundation

/// Return type of a function.
enum ReturnType {
    // When the return type is not specified.
    case void
    
    // When the return type is specified
    case primitiveType(PrimitiveType)
}

struct FunctionBodyExpression: Expr {
    let expressions: [Expr]
    let nodeVariantType: NodeVariantType = .functionBodyExpression
}

/// An argument passed. An argument has a well defined name and a type.
/// For ex, "func main(a: Int)" - "a" is the name of the argument and "Int" is the type of the argument.
struct FunctionArgument {
    let name: String
    let type: PrimitiveType
}

struct FunctionDeclaration: Expr {
    let name: String
    let arguments: [FunctionArgument]
    let returnType: ReturnType
    let body: FunctionBodyExpression
    let nodeVariantType: NodeVariantType = .functionDeclaration
}
