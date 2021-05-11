# BasicCompiler-LLVMSwift
A work in progress project to make a basic compiler that takes in some source code(small grammar) and generates an executable. 

## Goals
1. Learn various stages of the compilation process by making basic versions of the sub-components - Lexer, Parser, Sema, LLVM IR Generator and other optimisations that can be explored.
2. To become more familiar with the LLVM environment. 
3. To learn different type inference algorithms - Hindley Milner Inference etc.
4. Better developer diagnostics - how Swift and other languages contribute to making this possible, their relative trade-offs and strengths etc.
5. Prototyping other explorations to see their respective impact and limitations.

## Installation

1. Install LLVM 11.0+ using your favorite package manager. For example:
```brew install llvm@11```
2. Ensure llvm-config is in your PATH
3. ```swift run Sources/Utils/make-pkgconfig.swift```
Once you do that, the project will build all file hopefully!

## What's the grammar of the acceptable language here?
1. It's a pretty basic subset of my favourite language - Swift :).
2. It supports primitive types and doesn't support custom types as of now but can be easily extended to support other types.
3. It supports functions, their call expressions, constants/variables, return values, if-else conditions.
4. The scope is intentionally kept small so that more focus is towards how these layers work and how can they be extended considering the above mentioned goals.

## Example
For the followig code,
```swift
func main() {
 let a = 10
 print(a)
}
```
It emits the following LLVM IR:
```swift
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
```
The above can be converted to binary using the following:
```
$ llc -filetype=obj main.ll -o main.o
$ clang main.o -o main
$ ./main
```
## References
1. https://github.com/llvm-swift/LLVMSwift
2. [2019 LLVM Developers’ Meeting: E. Christopher & J. Doerfert “Introduction to LLVM” ](https://www.youtube.com/watch?v=J5xExRGaIIY&t=3279s)
3. [Introduction To LLVM](https://www.youtube.com/watch?v=8pdQFUOlHLQ)
4. T[ypes and Programming Languages - Benjamin C. Pierce]( https://www.cis.upenn.edu/~bcpierce/tapl/)

