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
    let module: Module
    private let builder: IRBuilder
    private var localVariables = [String: IRValue]()
    
    init(ast: AST) {
        self.ast = ast
        self.module = Module(name: "main")
        self.builder = IRBuilder(module: module)
    }
    
    
    func emitIR() throws {
        try ast.nodes.forEach { node in
            switch node {
            case .functionDeclaration(let functionDeclaration):
                try emitFunctionDeclaration(functionDeclaration)
            default: fatalError() // TODO: Add others.
            }
        }
    }
    
    // MARK: Private
    
    private func emitFunctionDeclaration(_ functionDeclaration: FunctionDeclaration) throws {
        let mainFunction = builder.addFunction(functionDeclaration.name,
                                               type: .init([], VoidType()))
        let entry = mainFunction.appendBasicBlock(named: "entry")
        builder.positionAtEnd(of: entry)
        if let bodyExpr = functionDeclaration.body as? FunctionBodyExpression {
            try bodyExpr.body.forEach { try self.emitExpr($0) }
        }
        builder.buildRetVoid()
    }
    
   @discardableResult
    private func emitExpr(_ expr: Expr) throws -> IRValue {
        if let assignmentExpression = expr as? AssignmentExpression {
            return try emitAssignmentExpression(assignmentExpression)
        } else if let integerExpression = expr as? IntegerExpression {
            return LLVM.IntType.int32.constant(integerExpression.intValue)
        } else if let printStatement = expr as? PrintStatement {
            return try emitPrintStatement(printStatement)
        } else {
            fatalError()
        }
    }
    
    private func emitPrintStatement(_ expr: PrintStatement) throws -> IRValue {
        let printFunction = emitPrintf()
        guard let argumentType = expr.value.first else { return printFunction }
        switch argumentType {
        case .propertyReference(let propertyReadExpression):
            let variableReferenced =
            builder.buildLoad(localVariables[propertyReadExpression.name]!,
                              type: LLVM.IntType.int32) // Update code to support other types
            return builder.buildCall(printFunction,
                                     args: [formatSpecifier(of: variableReferenced),
                                            variableReferenced])
        default:
            return printFunction
        }
    }
    
    private func emitAssignmentExpression(_ expr: AssignmentExpression) throws -> IRValue {
        let value = try emitExpr(expr.value)
        let variableName = expr.name
        let localVariable = builder.buildAlloca(type: LLVM.IntType.int32,
                                                name: variableName)
        let storedRef = builder.buildStore(value,
                                           to: localVariable)
        localVariables[variableName] = localVariable
        return storedRef
    }
    
    private func emitPrintf() -> Function {
       if let function = module.function(named: "printf") { return function }
        let printfType = FunctionType([PointerType(pointee: IntType.int8)],
                                      IntType.int32,
                                      variadic: true)
       return builder.addFunction("printf", type: printfType)
     }
    
    private func formatSpecifier(of value: IRValue) -> IRValue {
        if let _ = (value.type as? LLVM.IntType) {
            return builder.buildGlobalStringPtr("%d\n",
                                                name: "PRINTF_INTEGER")
        }
        fatalError()
    }
}

private extension AssignmentExpression {
    var name: String {
        switch lhs {
        case .constant(let constantDeclaration):
            return constantDeclaration.name
        case .variable(let variableDeclaration):
            return variableDeclaration.name
        }
    }
}
