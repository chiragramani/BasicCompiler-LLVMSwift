//
//  File.swift
//  
//
//  Created by Chirag Ramani on 19/05/21.
//

import Foundation

struct PropertyReadExpression: Expr, CustomStringConvertible {
    let name: String
    let nodeVariantType: NodeVariantType = .propertyReadExpression
    
    var description: String {
        "PropertyReadExpression (name: \(name))"
    }
}
