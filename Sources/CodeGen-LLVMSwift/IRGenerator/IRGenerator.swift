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
        try ast.expressions.forEach { node in
            switch node.nodeVariantType {
            case .functionDeclaration:
                try emitFunctionDeclaration(node)
            default: fatalError() // TODO: Add others.
            }
        }
    }
    
    // MARK: Private
    
    private func emitFunctionDeclaration(_ functionDeclaration: Expr) throws {
        guard let functionDeclaration = functionDeclaration as? FunctionDeclaration else {
            throw IRGeneratorError.expectedFunctionDeclaration
        }
        let mainFunction = builder.addFunction(functionDeclaration.name,
                                               type: .init([], VoidType()))
        let entry = mainFunction.appendBasicBlock(named: "entry")
        builder.positionAtEnd(of: entry)
        try functionDeclaration.body.expressions.forEach { try self.emitExpr($0) }
        builder.buildRetVoid()
    }
    
   @discardableResult
    private func emitExpr(_ expr: Expr) throws -> IRValue {
        if let assignmentExpression = expr as? AssignmentExpression {
            return try emitAssignmentExpression(assignmentExpression)
        } else if let integerExpression = expr as? IntegerExpression {
            return LLVM.IntType.int32.constant(integerExpression.value)
        } else if let printStatement = expr as? PrintStatement {
            return try emitPrintStatement(printStatement)
        } else if let stringExpression = expr as? StringExpression {
            return LLVM.ArrayType.constant(string: stringExpression.value)
        } else if let floatExpression = expr as? FloatExpression {
            return LLVM.FloatType.float.constant(Double(floatExpression.value))
        } else if let booleanExpression = expr as? BooleanExpression {
            return LLVM.IntType.int1.constant(booleanExpression.value ? 1 : 0)
        }  else {
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
        let value = try emitExpr(expr.rhs)
        let variableName = expr.lhsName
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
