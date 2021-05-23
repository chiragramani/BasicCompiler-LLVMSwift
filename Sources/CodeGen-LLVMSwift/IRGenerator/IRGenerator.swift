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
    private var functions = [String: Function]()
    private var formatSpecifiers = [PrimitiveType: IRValue]()
    private var localVariables = [String: (irValue: IRValue, type: PrimitiveType)]()
    
    init(ast: AST) {
        self.ast = ast
        self.module = Module(name: "main")
        self.builder = IRBuilder(module: module)
    }
    
    func emitIR() throws {
        /// Registering function signatures.
        let functionDeclarations = ast.expressions.filter { $0.nodeVariantType == .functionDeclaration }
        try functionDeclarations.forEach { try emitFunctionSignatureFor(declaration: $0.to(FunctionDeclaration.self)) }
        
        /// Register global constants.
        
        
        try ast.expressions.forEach { node in
            switch node.nodeVariantType {
            case .functionDeclaration:
                try emitFunctionDeclaration(node)
            default: fatalError() // TODO: Add others.
            }
        }
    }
    
    // MARK: Private
    
    private func emitFunctionSignatureFor(declaration: FunctionDeclaration) throws {
        /// Return type
        let returnType: IRType
        switch declaration.returnType {
        case .primitiveType(let primitiveType):
            returnType = irType(for: primitiveType)
        case .void:
            returnType = VoidType()
        }
        /// Parameter types
        let parameterTypes: [IRType] = declaration.arguments.map { irType(for: $0.type) }
        let function = builder.addFunction(declaration.name,
                                           type: .init(parameterTypes, returnType))
        functions[declaration.name] = function
    }
    
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
        switch expr.nodeVariantType {
        case .assignmentExpression:
            return try emitAssignmentExpression(try expr.to(AssignmentExpression.self))
        case .binaryExpression:
            return try emitBinaryExpression(try expr.to(BinaryExpression.self))
        case .booleanExpression:
            return LLVM.IntType.int1.constant(try expr.to(BooleanExpression.self).value ? 1 : 0)
        case .constantDeclaration:
            fatalError()
        case .floatExpression:
            return LLVM.FloatType.float.constant(Double(try expr.to(FloatExpression.self).value))
        case .functionBodyExpression:
            fatalError()
        case .functionCallArgumentType:
            fatalError()
        case .functionCallExpression:
            fatalError()
        case .functionDeclaration:
            fatalError()
        case .ifStatement:
            fatalError()
        case .integerExpression:
            return LLVM.IntType.int32.constant(try expr.to(IntegerExpression.self).value)
        case .printStatement:
            return try emitPrintStatement((try expr.to(PrintStatement.self)))
        case .propertyReadExpression:
            return try emitPropertyReadExpression(try expr.to(PropertyReadExpression.self))
        case .returnStatement:
            return try emitReturnStatement(try expr.to(ReturnStatement.self))
        case .stringExpression:
            return LLVM.ArrayType.constant(string: try expr.to(StringExpression.self).value)
        case .variableDeclaration:
            fatalError()
        }
    }
    
    private func emitReturnStatement(_ expr: ReturnStatement) throws -> IRValue {
        return builder.buildRet(try emitExpr(expr.value))
    }
    
    private func emitPropertyReadExpression(_ expr: PropertyReadExpression) throws -> IRValue {
        let property = localVariables[expr.name]!
        return builder.buildLoad(property.irValue,
                                 type: irType(for: property.type))
    }
    
    private func emitBinaryExpression(_ expr: BinaryExpression) throws -> IRValue {
        let lhsValue = try emitExpr(expr.lhs)
        let rhsValue = try emitExpr(expr.rhs)
        
        switch expr.op {
        case .divide:
            return builder.buildDiv(lhsValue, rhsValue)
        case .minus:
            return builder.buildSub(lhsValue,
                                    rhsValue)
        case .mod:
            return builder.buildRem(lhsValue,
                                    rhsValue)
        case .plus:
            return builder.buildAdd(lhsValue,
                                    rhsValue)
        case .times:
            return builder.buildMul(lhsValue,
                                    rhsValue)
        }
    }
    
    private func emitPrintStatement(_ expr: PrintStatement) throws -> IRValue {
        let printFunction = emitPrintf()
        guard let argumentType = expr.value.first else { return printFunction }
        switch argumentType {
        case .propertyReference(let propertyReadExpression):
            let localVariable = localVariables[propertyReadExpression.name]!
            let variableReferenced =
                builder.buildLoad(localVariable.irValue,
                                  type: irType(for: localVariable.type))
            return builder.buildCall(printFunction,
                                     args: [formatSpecifier(for: localVariable.type),
                                            variableReferenced])
        default:
            return printFunction
        }
    }
    
    private func irType(for primitiveType: PrimitiveType) -> IRType {
        switch primitiveType {
        case .bool:
            return LLVM.IntType.int1
        case .float:
            return LLVM.FloatType.float
        case .integer:
            return LLVM.IntType.int64
        case .string:
            // MemoryLayout<Character>.alignment = 8
            // Hardcoding max number of characters to be limited to the length of the ASCII character set.
            return LLVM.ArrayType(elementType: IntType.int8, count: 128)
        case .void:
            return LLVM.VoidType()
        }
    }
    
    private func emitAssignmentExpression(_ expr: AssignmentExpression) throws -> IRValue {
        let value = try emitExpr(expr.rhs)
        let variableName = expr.lhsName
        let localVariable = builder.buildAlloca(type: irType(for: expr.type),
                                                name: variableName)
        let storedRef = builder.buildStore(value,
                                           to: localVariable)
        localVariables[variableName] = (localVariable, expr.type)
        return storedRef
    }
    
    private func emitPrintf() -> Function {
        if let function = module.function(named: "printf") { return function }
        let printfType = FunctionType([PointerType(pointee: IntType.int8)],
                                      IntType.int32,
                                      variadic: true)
        return builder.addFunction("printf", type: printfType)
    }
    
    private func formatSpecifier(for type: PrimitiveType) -> IRValue {
        if let formatSpecifier = formatSpecifiers[type] {
            return formatSpecifier
        }
        let value: IRValue
        switch type {
        case .float:
            value = builder.buildGlobalStringPtr("%f\n",
                                                 name: "print_float")
        case .integer, .bool:
            value = builder.buildGlobalStringPtr("%d\n",
                                                 name: "print_integer")
        case .string:
            value = builder.buildGlobalStringPtr("%s\n",
                                                 name: "print_string")
        case .void: fatalError()
        }
        formatSpecifiers[type] = value
        return value
    }
}

private extension Expr {
    func to<V: Expr>(_ type: V.Type) throws -> V {
        guard let toExpression = self as? V else {
            throw IRGeneratorError.failedCast
        }
        return toExpression
    }
}
