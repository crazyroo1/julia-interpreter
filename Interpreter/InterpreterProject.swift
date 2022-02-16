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
        let scanner = Scanner()
        
        for line in scanner.lines(of: "textfile.txt") {
            print(line)
        }
    }
}
