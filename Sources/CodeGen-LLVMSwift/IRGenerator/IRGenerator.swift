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
    private var scopes = [Scope(name: "globalScope")]
    private var formatSpecifiers = [PrimitiveType: IRValue]()
    
    init(ast: AST) {
        self.ast = ast
        self.module = Module(name: "main")
        self.builder = IRBuilder(module: module)
    }
    
    func emitIR() throws {
        /// global assignment expressions and function signatures.
        try emitDeclarations()
        
        /// Emitting function declaration
        try ast.expressions.filter { $0.nodeVariantType == .functionDeclaration }
            .forEach {  try emitFunctionDeclaration($0) }
        
        /// Function calls
        try ast.expressions.filter { $0.nodeVariantType == .functionCallExpression }
            .forEach { try emitFunctionCallExpr($0.to(FunctionCallExpression.self)) }
    }
    
    // MARK: Private
    
    private func emitDeclarations() throws {
        try ast.expressions.forEach { (node) in
            switch node.nodeVariantType {
            case .assignmentExpression:
                try emitAssignmentExpression(try node.to(AssignmentExpression.self),
                                             isGlobal: true)
            case .functionDeclaration:
                try emitFunctionSignatureFor(declaration: try node.to(FunctionDeclaration.self))
            case .printStatement:
                _ = try emitPrintStatement((try node.to(PrintStatement.self)))
            default: break // Only assignments and functions are supported
            }
        }
    }
    
    private func irValuesFrom(arguments: [FunctionCallArgumentType]) throws -> [IRValue] {
        var irValues = [IRValue]()
        try arguments.forEach { argumentType in
            switch argumentType {
            case let .labelled(_, value):
                irValues.append(try emitExpr(value))
            case let .propertyReference(propertyReadExpression):
                irValues.append(try emitExpr(propertyReadExpression))
            }
        }
        return irValues
    }
    
    /// Emit LLVM IR for a function call
    @discardableResult
    private func emitFunctionCallExpr(_ expr: FunctionCallExpression) throws -> Call {
        guard let function = functions[expr.name] else {
            throw IRGeneratorError.unknownFunction(functionName: expr.name)
        }
        return builder.buildCall(function,
                                 args: try irValuesFrom(arguments: expr.arguments))
    }
    
    @discardableResult
    private func emitFunctionSignatureFor(declaration: FunctionDeclaration) throws -> Function {
        if let function = module.function(named: declaration.name) {
            return function
        }
        /// Return type
        let returnType: IRType = irType(for: declaration.returnType)
        /// Parameter types
        let parameterTypes: [IRType] = declaration.arguments.map { irType(for: $0.type) }
        let function = builder.addFunction(declaration.name,
                                           type: .init(parameterTypes, returnType))
        functions[declaration.name] = function
        return function
    }
    
    private func emitFunctionDeclaration(_ functionDeclaration: Expr) throws {
        guard let functionDeclaration = functionDeclaration as? FunctionDeclaration else {
            throw IRGeneratorError.expectedFunctionDeclaration
        }
        scopes.append(Scope(name: functionDeclaration.name))
        
        let function = try emitFunctionSignatureFor(declaration: functionDeclaration)
        for (idx, arg) in functionDeclaration.arguments.enumerated() {
            let param = function.parameter(at: idx)!
            updateScope(withIdentifier: arg.name,
                        havingValue: (irValue: param, type: arg.type))
        }
        
        let entry = function.appendBasicBlock(named: "entry")
        builder.positionAtEnd(of: entry)
        try functionDeclaration.body.expressions.forEach { try self.emitExpr($0) }
        scopes.removeLast()
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
        case .floatExpression:
            return LLVM.FloatType.float.constant(Double(try expr.to(FloatExpression.self).value))
        case .functionDeclaration:
            // Not supported.
            fatalError()
        case .ifStatement:
            // Not supported.
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
        case .constantDeclaration, .variableDeclaration:
            // Will be a part of Function Body.
            fatalError()
        case .functionCallExpression:
            return try emitFunctionCallExpr(try expr.to(FunctionCallExpression.self))
        case .functionBodyExpression, .functionCallArgumentType:
            // Will be a part of Function Declaration.
            fatalError()
        }
    }
    
    private func emitReturnStatement(_ expr: ReturnStatement) throws -> IRValue {
        return builder.buildRet(try emitExpr(expr.value))
    }
    
    private func emitPropertyReadExpression(_ expr: PropertyReadExpression) throws -> IRValue {
        guard let value = getValue(forIdentifier: expr.name) else {
            throw IRGeneratorError.couldntFindVariableInScope(variableName: expr.name)
        }
        return builder.buildLoad(value.irValue,
                                 type: irType(for: value.type))
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
    
    @discardableResult
    private func emitPrintStatement(_ expr: PrintStatement) throws -> IRValue {
        let printFunction = emitPrintf()
        guard let argumentType = expr.value.first else { return printFunction }
        switch argumentType {
        case .propertyReference(let propertyReadExpression):
            let variable = getValue(forIdentifier: propertyReadExpression.name)!
            let variableReferenced =
                builder.buildLoad(variable.irValue,
                                  type: irType(for: variable.type))
            return builder.buildCall(printFunction,
                                     args: [formatSpecifier(for: variable.type),
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
    
    @discardableResult
    private func emitAssignmentExpression(_ expr: AssignmentExpression,
                                          isGlobal: Bool = false) throws -> IRValue {
        let value = try emitExpr(expr.rhs)
        let variableName = expr.lhsName
        let storeInstruction: IRValue
        if isGlobal {
            let globalVariable = builder.addGlobal(variableName, initializer: value)
            updateScope(withIdentifier: variableName,
                        havingValue: (globalVariable, expr.type))
            storeInstruction = globalVariable
        } else {
            let localVariable = builder.buildAlloca(type: irType(for: expr.type),
                                                    name: variableName)
            storeInstruction = builder.buildStore(value,
                                                  to: localVariable)
            updateScope(withIdentifier: variableName,
                        havingValue: (localVariable, expr.type))
        }
        return storeInstruction
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


// MARK: Scope Management
private extension IRGenerator {
    
    final class Scope {
        var variableMap = [String: (irValue: IRValue, type: PrimitiveType)]()
        let name: String
        init(name: String) {
            self.name = name
        }
    }
    
    func updateScope(withIdentifier identifier: String,
                     havingValue value: (irValue: IRValue, type: PrimitiveType)) {
        guard let scope = scopes.last else { return }
        scope.variableMap[identifier] = value
    }
    
    private func getValue(forIdentifier identifier: String) -> (irValue: IRValue, type: PrimitiveType)? {
        for scope in scopes.reversed() {
            if let value = scope.variableMap[identifier] {
                return value
            }
        }
        return nil
    }
}
