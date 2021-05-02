import Foundation

let intermediateRepresentations: [IRGen] = [
    FunctionReturningSum().generateIR()
]

let code = """
 func main() {
 let a = 10
 print(a)
}
"""
let lexer = Lexer(input: code)
let tokenKinds = lexer.lex()

let parser = Parser(tokenKinds: tokenKinds)
let ast = try parser.parse()
print(ast)
