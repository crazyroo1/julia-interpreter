//
//  Interpreter.swift
//  Interpreter
//
//  Created by Turner Eison on 3/21/22.
//

import Foundation

class Interpreter {
    /// The symbol table for the interpreter.
    private var symbols: [String: Symbol] = [:]
    
    
    /// Interprets a parse tree
    ///
    /// - parameter parseTree: The head of the parse tree that should be interpreted
    /// - parameter shouldPrint: Controls if the symbol table will be dumped to the
    ///   console after successful interpretation
    ///
    /// This empties the symbol table first, then begins interpretation. This is to
    /// ensure a fresh table for each interpretation.
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
    
    /// Handles a block by handling each statement individually.
    private func handle(_ block: Block) {
        block.statements.forEach(handle)
    }
    
    /// Handles a single statement by switching over all possible
    /// statement types and handling that type in its own function.
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
    
    /// Handles an if statement by executing the expression, then
    /// conditionally handling the `true` or `else` block appropriately.
    private func handle(_ ifStatement: IfStatement) {
        if handle(ifStatement.expression) {
            handle(ifStatement.trueBlock)
        } else {
            handle(ifStatement.elseBlock)
        }
    }
    
    /// Assigns the result of the expression to the appropriate key in the symbol table.
    private func handle(_ assignmentStatement: AssignmentStatement) {
        symbols[assignmentStatement.identifier] = .variable(handle(assignmentStatement.expression))
    }
    
    /// Handles a while statement as expected
    ///
    /// No surprises here. Evaluates the expression before each loop, then
    /// handles the block of code in a standard Swift `while` loop.
    private func handle(_ whileStatement: WhileStatement) {
        while handle(whileStatement.expression) {
            handle(whileStatement.block)
        }
    }
    
    /// Prints the result of evaluating the given expression.
    private func handle(_ printStatement: PrintStatement) {
        print(handle(printStatement.arithmeticExpression))
    }
    
    /// Handles a repeat statement as expected
    ///
    /// No surprises here. Evaluates the expression after each loop, then
    /// handles the block of code in a standard Swift `repeat` loop.
    private func handle(_ repeatStatement: RepeatStatement) {
        repeat {
            handle(repeatStatement.block)
        } while handle(repeatStatement.untilExpression)
    }
    
    /// Evaluates a boolean expression
    ///
    /// First, the value of `lhs` and `rhs` is evaluated. Then,
    /// the `relativeOperator` is switched on, and the result of the
    /// comparison is returned to the caller.
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
    
    /// Handles an arithmetic expression
    ///
    /// Breaks down the expression first.
    ///
    /// - If the value is an identifier, try to return the value from the symbol table.
    ///   If said value doesn't exist, `0` is returned as the default.
    /// - If the value is an `integerLiteral`, the value is returned directly.
    /// - If the value is an expression, the operator is switched on. Both sides of the expression
    ///   are evaluated individually, and their results are combined with the switched operator.
    private func handle(_ expression: ArithmeticExpression) -> Int {
        switch expression {
        case .identifier(let id):
            let value = symbols[id] ?? .variable(0)
            guard case .variable(let intValue) = value else {
                fatalError("Tried to get the value of a function symbol, which is illegal")
            }
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
