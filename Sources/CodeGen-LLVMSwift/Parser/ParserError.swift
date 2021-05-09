//
//  File.swift
//  
//
//  Created by Chirag Ramani on 09/05/21.
//

import Foundation

/*
 ParserError:
 A well-defined Error would be talking about the source range ie. where the error was there along with a lot of related awesome dev diagnostics but the objective of this project is to not go deeper but to go step by step in making a very simple compiler model.
 */
enum ParserError: Error {
    case expectedTokenKindFuncKeyword
    case expectedLeftParen
    case expectedIdentifier
    case expectedReturnKeyword
    case expectedPrintKeyword
    case expectedLetKeyword
    case expectedVarKeyword
    case expectedPrimitiveType
    case expectedLiteralValue
    
    case expectedFunctionArrow
    case unknown
}
