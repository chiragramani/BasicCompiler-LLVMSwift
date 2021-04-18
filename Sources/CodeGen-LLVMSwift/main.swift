import Foundation

let intermediateRepresentations: [IRGen] = [
    FunctionReturningSum().generateIR()
]

let code = """
func main() {
 let a: Int = 20
}
"""

let lexer = Lexer(input: code)
print(lexer.lex())
