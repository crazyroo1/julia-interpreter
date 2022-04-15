//
//  SyntaxAnalyzer.swift
//  Interpreter
//
//  Created by Turner Eison on 3/16/22.
//

import Foundation

struct SyntaxAnalyzer {
    func buildProgram(from tokens: [Token], shouldPrint: Bool = false) throws -> Program {
        var tokens = tokens
        let program: Program
        do {
            program = try Program(from: &tokens)
        } catch SyntaxAnalyzerError.unexpectedToken(let file, let line) {
            fatalError("Unexpected token found at \(file):\(line)")
        }
        
        if shouldPrint {
            dump(program)
        }
        
        return program
    }
}
