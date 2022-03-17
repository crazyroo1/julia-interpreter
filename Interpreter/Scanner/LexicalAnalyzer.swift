//
//  LexicalAnalyzer.swift
//  Interpreter
//
//  Created by Turner Eison on 2/14/22.
//

import Foundation

struct LexicalAnalyzer {
    
    /// Converts contents of a file to a list of tokens
    ///
    /// - parameter fileContents: Contents of a julia file. Get this from `contents(of: )` method of this struct
    /// - returns: Array containing each token in order
    ///
    /// This function will filter out whitespace & comment lines (lines starting with `//`).
    func tokens(for fileContents: String, shouldPrint: Bool = false) -> [Token] {
        let words: [String] = lines(of: fileContents)
            .filter { !$0.hasPrefix("//") } // get rid of comment lines
            .reduce("") { partialString, nextString in
                partialString + "\n" + nextString
            } // reduce back into one long string
            .split { element in
                // split by whitespace or parenthesis
                element.isWhitespace || ["(", ")"].contains(element)
            }
            .map(String.init)
        
        let tokens = words.map(Token.init)
        
        if shouldPrint {
            for (word, token) in zip(words, tokens) {
                print("\(word): \(token)")
            }
        }
        
        return tokens
    }
    
    /// Reads in a file in the current directory
    ///
    /// - parameter filename: Name of a file in the current working directory
    /// - returns: String contents of the file
    /// - throws: `fatalError` if unable to find or read the file
    func contents(of filename: String) -> String {
        let url = URL(string: "file://" + FileManager.default.currentDirectoryPath)!
            .appendingPathComponent(filename)
        
        guard let data = try? Data(contentsOf: url),
              let contents = String(data: data, encoding: .utf8) else {
                  fatalError("unable to read file to string. url: \(url)")
              }
        
        return contents
    }
    
    /// Splits up contents of a file into a list of its lines
    ///
    /// - parameter string: file to be split by newline
    /// - returns: Array containing each line of `string`
    private func lines(of string: String) -> [String] {
        let lines = string
            .split { element in
                element.isNewline
            }
            .map(String.init)
        
        return lines
    }
}
