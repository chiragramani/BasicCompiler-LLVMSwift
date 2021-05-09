//
//  IRGenerator.swift
//  
//
//  Created by Chirag Ramani on 09/05/21.
//

import Foundation
import LLVM

final class IRGenerator {
    
    private let ast: AST
    private let builder: IRBuilder
    
    init(ast: AST) {
        self.ast = ast
        let module = Module(name: "main")
        self.builder = IRBuilder(module: module)
    }
}
