import Foundation

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
let irGenerator = IRGenerator(ast: ast)

try? irGenerator.emitIR()
try? irGenerator.module.verify()

print(irGenerator.module.dump())

/*
; ModuleID = 'main'
source_filename = "main"

@PRINTF_INTEGER = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1

define void @main() {
entry:
  %a = alloca i32, align 4
  store i32 10, i32* %a, align 4
  %0 = load i32, i32* %a, align 4
  %1 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @PRINTF_INTEGER, i32 0, i32 0), i32 %0)
  ret void
}

declare i32 @printf(i8* %0, ...)
*/

