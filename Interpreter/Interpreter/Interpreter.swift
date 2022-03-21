//
//  Interpreter.swift
//  Interpreter
//
//  Created by Turner Eison on 3/21/22.
//

import Foundation

class Interpreter {
    private var symbols: [String: Symbol] = [:]
    
    func interpret(parseTree: Program, shouldPrint: Bool = false) {
        // reset the symbol table on each interpret call
        symbols = [:]
        symbols[parseTree.identifier] = .function
        handle(parseTree.block)
        
        if shouldPrint {
            print()
            print("Interpretation finished.")
            print("Dumping symbol table")
            dump(symbols)
        }
    }
    
    private func handle(_ block: Block) {
        block.statements.forEach(handle)
    }
    
    private func handle(_ statement: Statement) {
        switch statement {
        case .ifStatement(let ifStatement):
            handle(ifStatement)
        case .assignmentStatement(let assignmentStatement):
            handle(assignmentStatement)
        case .whileStatement(let whileStatement):
            handle(whileStatement)
        case .printStatement(let printStatement):
            handle(printStatement)
        case .repeatStatement(let repeatStatement):
            handle(repeatStatement)
        }
    }
    
    private func handle(_ ifStatement: IfStatement) {
        if handle(ifStatement.expression) {
            handle(ifStatement.trueBlock)
        } else {
            handle(ifStatement.elseBlock)
        }
    }
    
    private func handle(_ assignmentStatement: AssignmentStatement) {
        symbols[assignmentStatement.identifier] = .variable(handle(assignmentStatement.expression))
    }
    
    private func handle(_ whileStatement: WhileStatement) {
        while handle(whileStatement.expression) {
            handle(whileStatement.block)
        }
    }
    
    private func handle(_ printStatement: PrintStatement) {
        print(handle(printStatement.arithmeticExpression))
    }
    
    private func handle(_ repeatStatement: RepeatStatement) {
        repeat {
            handle(repeatStatement.block)
        } while handle(repeatStatement.untilExpression)
    }
    
    private func handle(_ expression: BooleanExpression) -> Bool {
        let lhs = handle(expression.lhs)
        let rhs = handle(expression.rhs)
        
        switch expression.relativeOperator {
        case .lessThanOrEqualTo:
            return lhs <= rhs
        case .lessThan:
            return lhs < rhs
        case .greaterThanOrEqualTo:
            return lhs >= rhs
        case .greaterThan:
            return lhs > rhs
        case .equalTo:
            return lhs == rhs
        case .notEqualTo:
            return lhs != rhs
        }
    }
    
    private func handle(_ expression: ArithmeticExpression) -> Int {
        switch expression {
        case .identifier(let id):
            let value = symbols[id] ?? .variable(0)
            guard case .variable(let intValue) = value else { fatalError() }
            return intValue
            
        case .integerLiteral(let int):
            return int
            
        case .expression(let arithmeticOperator, let lhs, let rhs):
            switch arithmeticOperator {
            case .additionOperator:
                return handle(lhs) + handle(rhs)
            case .subtractionOperator:
                return handle(lhs) - handle(rhs)
            case .multiplicationOperator:
                return handle(lhs) * handle(rhs)
            case .divisionOperator:
                return handle(lhs) / handle(rhs)
            }
        }
    }
}
