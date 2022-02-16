//
//  Scanner.swift
//  Interpreter
//
//  Created by Turner Eison on 2/14/22.
//

import Foundation

struct Scanner {
    /// Gets lines for a file in the current directory
    ///
    /// - parameter filename: Filename, including extension, of a file in the current working directory
    /// - returns: Array containing each line of the file, separated by newline
    func lines(of filename: String) -> [String] {
        let url = URL(string: "file://" + FileManager.default.currentDirectoryPath)!
            .appendingPathComponent(filename)
        
        guard let data = try? Data(contentsOf: url),
              let contents = String(data: data, encoding: .utf8) else {
                  fatalError("unable to read file to string")
              }
        
        let lines = contents
            .split(omittingEmptySubsequences: true) { element in
                element.isNewline
            }
            .map(String.init)
        
        return lines
    }
}
