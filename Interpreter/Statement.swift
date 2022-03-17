//
//  Statement.swift
//  Interpreter
//
//  Created by Turner Eison on 3/16/22.
//

import Foundation

/// Ensures all possible grammars have an `inout [Token]` parameter
///
/// Note: Some implemented inits are nonoptional.
/// This is a more specific version of the optional init, so it is accepted by the compiler
protocol StatementProtocol {
    init?(from tokens: inout [Token]) throws
}

enum SyntaxAnalyzerError: Error {
    case unexpectedToken(String = #fileID, Int = #line)
}

/// The overarching program
///
/// Consumes `function`, the function's `id`, and the trailing `end` at the end of the program
struct Program: StatementProtocol {
    init(from tokens: inout [Token]) throws {
        guard tokens.removeFirst() == .functionBegin,
              case let .identifier(id) = tokens.removeFirst(),
              tokens.removeLast() == .endStatement else {
                throw SyntaxAnalyzerError.unexpectedToken()
              }
        
        self.identifier = id
        
        let block = try Block(from: &tokens)
        self.block = block
    }
    
    let identifier: String
    let block: Block
}

/// A block of statements
///
/// Consumes no tokens on its own.
/// `Statement` should handle consuming all of its tokens
struct Block: StatementProtocol {
    init(from tokens: inout [Token]) throws {
        var statements = [Statement]()
        
        while let statement = try Statement(from: &tokens) {
            statements.append(statement)
        }
        
        self.statements = statements
    }
    
    let statements: [Statement]
}

/// All possible statements for a block
///
/// Consumes no tokens on its own.
/// Substatements should handle consuming their tokens
enum Statement: StatementProtocol {
    init?(from tokens: inout [Token]) throws {
        if let ifStatement = try IfStatement(from: &tokens) {
            self = .ifStatement(ifStatement)
        } else if let assignmentStatement = try AssignmentStatement(from: &tokens) {
            self = .assignmentStatement(assignmentStatement)
        } else if let whileStatement = try WhileStatement(from: &tokens) {
            self = .whileStatement(whileStatement)
        } else if let printStatement = try PrintStatement(from: &tokens) {
            self = .printStatement(printStatement)
        } else if let repeatStatement = try RepeatStatement(from: &tokens) {
            self = .repeatStatement(repeatStatement)
        } else {
            return nil
        }
    }
    
    case ifStatement(IfStatement)
    case assignmentStatement(AssignmentStatement)
    case whileStatement(WhileStatement)
    case printStatement(PrintStatement)
    case repeatStatement(RepeatStatement)
}

/// If Statement
///
/// Ensures the first token is an `if` before continuing and consuming anything.
/// Consumes leading `if` token, `then` token, `else` token, and trailing `end` token.
/// Expressions and blocks should consume their own tokens.
struct IfStatement: StatementProtocol {
    init?(from tokens: inout [Token]) throws {
        guard tokens.first == .ifStatement else { return nil }
        
        // drop if
        guard tokens.removeFirst() == .ifStatement else { throw SyntaxAnalyzerError.unexpectedToken() }
        
        let expression = try BooleanExpression(from: &tokens)
        
        // drop then
        guard tokens.removeFirst() == .thenStatement else { throw SyntaxAnalyzerError.unexpectedToken() }
        
        let trueBlock = try Block(from: &tokens)
        
        // drop else
        guard tokens.removeFirst() == .elseStatement else { throw SyntaxAnalyzerError.unexpectedToken() }
        
        let elseBlock = try Block(from: &tokens)
        
        // drop end
        guard tokens.removeFirst() == .endStatement else { throw SyntaxAnalyzerError.unexpectedToken() }
        
        self.expression = expression
        self.trueBlock = trueBlock
        self.elseBlock = elseBlock
    }
    
    let expression: BooleanExpression
    let trueBlock: Block
    let elseBlock: Block
}

/// While Statement
///
/// Ensures the first token is a `while` token before continuing and consuming anything.
/// Consumes `while` token, `do` token, and `end` token.
/// All expressions and blocks should consume their own tokens.
struct WhileStatement: StatementProtocol {
    init?(from tokens: inout [Token]) throws {
        guard tokens.first == .whileStatement else { return nil }
        
        // drop while
        guard tokens.removeFirst() == .whileStatement else { throw SyntaxAnalyzerError.unexpectedToken() }
        
        let expression = try BooleanExpression(from: &tokens)
        
        // drop do
        guard tokens.removeFirst() == .doStatement else { throw SyntaxAnalyzerError.unexpectedToken() }
        
        let block = try Block(from: &tokens)
        
        // drop end
        guard tokens.removeFirst() == .endStatement else { throw SyntaxAnalyzerError.unexpectedToken() }
        
        self.expression = expression
        self.block = block
    }
    
    let expression: BooleanExpression
    let block: Block
}

/// Assignment statement
///
/// Ensures there are at least 3 tokens left, and that the middle token of those 3 is an `assignment` token.
/// Consumes the `id` token and the `assignment` token.
/// `ArithmeticExpression` is expected to consume its tokens.
struct AssignmentStatement: StatementProtocol {
    init?(from tokens: inout [Token]) throws {
        guard tokens.count >= 3 else { return nil }
        guard tokens[1] == .assignmentOperator else { return nil }
        
        guard case let .identifier(id) = tokens.removeFirst() else { throw SyntaxAnalyzerError.unexpectedToken() }
        self.identifier = id
        
        // remove =
        guard tokens.removeFirst() == .assignmentOperator else { throw SyntaxAnalyzerError.unexpectedToken() }
        
        let expression = try ArithmeticExpression(from: &tokens)
        self.expression = expression
    }
    
    let identifier: String
    let expression: ArithmeticExpression
}

/// Repeat statement
///
/// Ensures the first token is `repeat`.
/// Consumes `repeat` token and `until` token.
/// Inner `Block` should consume its own tokens.
struct RepeatStatement: StatementProtocol {
    init?(from tokens: inout [Token]) throws {
        guard tokens.first == .repeatStatement else { return nil }
        
        // drop repeat
        guard tokens.removeFirst() == .repeatStatement else { throw SyntaxAnalyzerError.unexpectedToken() }
        
        let block = try Block(from: &tokens)
        self.block = block
        
        // drop until
        guard tokens.removeFirst() == .untilStatement else { throw SyntaxAnalyzerError.unexpectedToken() }
        
        let expression = try BooleanExpression(from: &tokens)
        self.untilExpression = expression
    }
    
    let block: Block
    let untilExpression: BooleanExpression
}

/// Print statement
///
/// Ensures the first token is `print`.
/// Consumes the `print` token.
/// `Expression` should consume its own tokens.
struct PrintStatement: StatementProtocol {
    init?(from tokens: inout [Token]) throws {
        guard tokens.first == .printCommand else { return nil }
        
        guard tokens.removeFirst() == .printCommand else { throw SyntaxAnalyzerError.unexpectedToken() }
        
        let expression = try ArithmeticExpression(from: &tokens)
        self.arithmeticExpression = expression
    }
    
    let arithmeticExpression: ArithmeticExpression
}

/// Boolean Expression
///
/// Does not consume any tokens.
/// `RelativeOperator` and Expressions should consume their own tokens.
struct BooleanExpression: StatementProtocol {
    init(from tokens: inout [Token]) throws {
        let relativeOperator = try RelativeOperator(from: &tokens)
        let lhs = try ArithmeticExpression(from: &tokens)
        let rhs = try ArithmeticExpression(from: &tokens)
        
        self.relativeOperator = relativeOperator
        self.lhs = lhs
        self.rhs = rhs
    }
    
    let relativeOperator: RelativeOperator
    let lhs: ArithmeticExpression
    let rhs: ArithmeticExpression
}

/// Relative Operator
///
/// Consumes the first token if it matches one of the relative operators
enum RelativeOperator: StatementProtocol {
    init(from tokens: inout [Token]) throws {
        switch tokens.first {
        case .lessThanOrEqualToOperator: self = .lessThanOrEqualTo
        case .lessThanOperator: self = .lessThan
            
        case .greaterThanOrEqualToOperator: self = .greaterThanOrEqualTo
        case .greaterThanOperator: self = .greaterThan
            
        case .equalityOperator: self = .equalTo
        case .notEqualOperator: self = .notEqualTo
        
        default: throw SyntaxAnalyzerError.unexpectedToken()
        }
        
        tokens.removeFirst()
    }
    
    case lessThanOrEqualTo
    case lessThan
    
    case greaterThanOrEqualTo
    case greaterThan
    
    case equalTo
    case notEqualTo
}

/// Arithmetic Expression
///
/// Contains all of the possible arithmetic expressions.
/// If the first token is an `id`, this consumes that token.
/// If the first token is an `integer literal`, this consumes that token.
/// Otherwise, the first token is expected to be an `arithmetic operator` so this does not consume its token.
/// In this case, `AO` is expected to consume its own token, then two new arithmetic expressions are expected.
indirect enum ArithmeticExpression: StatementProtocol {
    init(from tokens: inout [Token]) throws {
        switch tokens.first {
        case .identifier(let id):
            self = .identifier(id)
            tokens.removeFirst() // consume this token
            
        case .integerLiteral(let value):
            self = .integerLiteral(value)
            tokens.removeFirst() // consume this token
            
        default:
            let arithmeticOperator = try ArithmeticOperator(from: &tokens)
            let lhs = try ArithmeticExpression(from: &tokens)
            let rhs = try ArithmeticExpression(from: &tokens)
            
            self = .expression(arithmeticOperator, lhs, rhs)
        }
    }
    
    case identifier(String)
    case integerLiteral(Int)
    case expression(ArithmeticOperator, ArithmeticExpression, ArithmeticExpression)
}

/// Arithmetic Operator
///
/// Consumes its token if it finds an appropriate operator
enum ArithmeticOperator: StatementProtocol {
    init(from tokens: inout [Token]) throws {
        switch tokens.first {
        case .additionOperator: self = .additionOperator
        case .subtractionOperator: self = .subtractionOperator
        case .multiplicationOperator: self = .multiplicationOperator
        case .divisionOperator: self = .divisionOperator
            
        default: throw SyntaxAnalyzerError.unexpectedToken()
        }
        
        tokens.removeFirst()
    }
    
    case additionOperator
    case subtractionOperator
    case multiplicationOperator
    case divisionOperator
}
