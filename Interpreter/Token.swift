//
//  Token.swift
//  Interpreter
//
//  Created by Turner Eison on 2/16/22.
//

import Foundation

enum Token: Equatable {
    case identifier(String)

    case integerLiteral(Int)

    case assignmentOperator

    case lessThanOrEqualToOperator
    case lessThanOperator
    case greaterThanOrEqualToOperator
    case greaterThanOperator

    case equalityOperator
    case notEqualOperator
    
    case additionOperator
    case subtractionOperator
    case multiplicationOperator
    case divisionOperator
    
    case functionBegin
    case endStatement
    
    case ifStatement
    case thenStatement
    case elseStatement
    
    case whileStatement
    case doStatement
    
    case repeatStatement
    case untilStatement
    
    case printCommand
    
    case unrecognizedToken(String)
    
    init(rawValue: String) {
        switch rawValue {
        case "=": self = .assignmentOperator
            
        case "<=": self = .lessThanOrEqualToOperator
        case "<": self = .lessThanOperator
        case ">=": self = .greaterThanOrEqualToOperator
        case ">": self = .greaterThanOperator
            
        case "==": self = .equalityOperator
        case "~=": self = .notEqualOperator
            
        case "+": self = .additionOperator
        case "-": self = .subtractionOperator
        case "*": self = .multiplicationOperator
        case "/": self = .divisionOperator
            
        case "function": self = .functionBegin
        case "end": self = .endStatement
            
        case "if": self = .ifStatement
        case "then": self = .thenStatement
        case "else": self = .elseStatement
        
        case "while": self = .whileStatement
        case "do": self = .doStatement
            
        case "repeat": self = .repeatStatement
        case "until": self = .untilStatement
            
        case "print": self = .printCommand
            
        default:
            if let intValue = Int(rawValue) {
                self = .integerLiteral(intValue)
                return
            }
            
            if rawValue.count == 1 {
                self = .identifier(rawValue)
                return
            }
            
            self = .unrecognizedToken(rawValue)
        }
    }
}
