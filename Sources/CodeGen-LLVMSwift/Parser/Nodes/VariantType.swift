//
//  File.swift
//  
//
//  Created by Chirag Ramani on 19/05/21.
//

import Foundation

enum NodeVariantType {
    case assignmentExpression
    case binaryExpression
    case propertyReadExpression
    
    case integerExpression
    case floatExpression
    case stringExpression
    case booleanExpression
    
    
    case functionCallExpression
    case functionBodyExpression
    
    case ifStatement
    case printStatement
    case returnStatement
    
    case functionCallArgumentType
    
    case constantDeclaration
    case variableDeclaration
    case functionDeclaration
}
