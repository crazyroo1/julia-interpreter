//
//  InterpreterProject.swift
//  Interpreter
//
//  Created by Turner Eison on 2/14/22.
//

import Foundation

@main
struct Main {
    static func main() async throws {
        let scanner = LexicalAnalyzer()
        
        let tokens = scanner.tokens(for: scanner.contents(of: "Test3.jl"), shouldPrint: false)
        
        let parser = SyntaxAnalyzer()
        let parseTree = try parser.buildProgram(from: tokens, shouldPrint: false)
        
        let interpreter = Interpreter()
        interpreter.interpret(parseTree: parseTree, shouldPrint: true)
    }
}
