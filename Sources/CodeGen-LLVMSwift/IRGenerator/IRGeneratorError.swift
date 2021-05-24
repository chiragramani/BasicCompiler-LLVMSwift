//
//  File.swift
//  
//
//  Created by Chirag Ramani on 19/05/21.
//

import Foundation

enum IRGeneratorError: Error {
    case expectedFunctionDeclaration
    case failedCast
    case unknownFunction(functionName: String)
    
    case couldntFindVariableInScope(variableName: String)
}
