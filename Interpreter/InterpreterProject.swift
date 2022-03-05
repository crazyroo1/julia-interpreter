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
        
        let _ = scanner.tokens(for: scanner.contents(of: "Test1.jl"))
        
    }
}
