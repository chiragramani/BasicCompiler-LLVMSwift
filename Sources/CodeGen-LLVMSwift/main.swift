import Foundation

let intermediateRepresentations: [IRGen] = [
    FunctionReturningSum().generateIR()
]

let code = """
func main() {
 let a: Int = 20
 print(a)
}
"""

let lexer = Lexer(input: code)
print(lexer.lex())
