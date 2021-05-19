//
//  File.swift
//  
//
//  Created by Chirag Ramani on 19/05/21.
//

import Foundation

struct FunctionCallExpression: Expr, CustomStringConvertible {
    let name: String
    let arguments: [FunctionCallArgumentType]
    let nodeVariantType: NodeVariantType = .functionCallExpression
    
    var description: String {
        "FunctionCallExpression name: \(name), arguments: \(arguments)"
    }
}
