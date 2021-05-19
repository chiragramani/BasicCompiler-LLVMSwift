//
//  File.swift
//  
//
//  Created by Chirag Ramani on 19/05/21.
//

import Foundation

struct PropertyReadExpression: Expr {
    let name: String
    let nodeVariantType: NodeVariantType = .propertyReadExpression
}
