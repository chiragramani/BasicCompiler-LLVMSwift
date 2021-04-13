//
//  File.swift
//  
//
//  Created by Chirag Ramani on 13/04/21.
//

import Foundation
import LLVM


typealias IRGen = String

protocol IRProviding {
    func generateIR() -> IRGen
}

struct FunctionReturningSum: IRProviding {
    
    func generateIR() -> IRGen {
        let module = Module(name: "main")
        let builder = IRBuilder(module: module)
        let main = builder.addFunction("main",
                                       type: FunctionType([], IntType.int64))
        let entry = main.appendBasicBlock(named: "entry")
        builder.positionAtEnd(of: entry)
        let constant = IntType.int64.constant(21)
        let sum = builder.buildAdd(constant, constant)
        builder.buildRet(sum)
        return module.description
    }
}
