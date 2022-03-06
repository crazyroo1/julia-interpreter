//
//  InterpreterProject.swift
//  Interpreter
//
//  Created by Turner Eison on 2/14/22.
//
//  CS 4308 / 03
//  Spring 2022
//  Sharon Perry
//

import Foundation

@main
struct Main {
    static func main() async throws {
        let scanner = LexicalAnalyzer()
        
        let tokens = scanner.tokens(for: scanner.contents(of: "Test1.jl"))
    }
}
