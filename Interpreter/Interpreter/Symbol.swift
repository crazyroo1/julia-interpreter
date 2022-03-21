//
//  Symbol.swift
//  Interpreter
//
//  Created by Turner Eison on 3/21/22.
//

import Foundation

/// The types of symbols allowed in the interpreter
///
/// A symbol can either be for a function or for a variable.
///
/// A function symbol looks like this in Julia, where `a` is the symbol
/// ``` julia
/// function a() // <----- `a` is the symbol
///     // do stuff
/// end
/// ```
///
/// A variable symbol is any other symbol located in the program.
/// For example, a symbol first seen in an assignment statement looks like this,
/// where `x` is the symbol
/// ``` julia
/// x = 5 // <----- `x` is the symbol
/// ```
///
enum Symbol {
    case function
    case variable(Int)
}
