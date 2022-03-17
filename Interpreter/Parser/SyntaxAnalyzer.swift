//
//  SyntaxAnalyzer.swift
//  Interpreter
//
//  Created by Turner Eison on 3/16/22.
//

import Foundation

struct SyntaxAnalyzer {
    func buildProgram(from tokens: [Token]) throws -> Program {
        var tokens = tokens
        let program = try Program(from: &tokens)
        return program
    }
}
