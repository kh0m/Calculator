//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Hom, Kenneth on 5/12/16.
//  Copyright © 2016 Hom, Kenneth. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private var accumulator = 0.0
    private var descriptionAccumulator = "0"
    
    
    var description: String {
        get {
            if pending == nil {
                return descriptionAccumulator
            } else {
                return pending!.descriptionFunction(pending!.descriptionOperand, pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
        set {
            descriptionAccumulator = newValue
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    var isPartialResult = false
    
    func setOperand(operand: Double) {
        accumulator = operand
        descriptionAccumulator = String(format: "%g", operand)
    }
    
    var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOperation(sqrt, {"√(" + $0 + ")"}),
        "cos" : Operation.UnaryOperation(cos, {"cos(" + $0 + ")"}),
        "sin" : Operation.UnaryOperation(sin, {"sin(" + $0 + ")"}),
        "±" : Operation.UnaryOperation({-$0}, {"-(" + $0 + ")"}),
        "x²" : Operation.UnaryOperation({pow($0,2)}, {"(" + $0 + ")²"}),
        "x³" : Operation.UnaryOperation({pow($0,3)}, {"(" + $0 + ")³"}),
        "×" : Operation.BinaryOperation({$0 * $1}, {$0 + "×" + $1}),
        "÷" : Operation.BinaryOperation({$0 / $1}, {$0 + "÷" + $1}),
        "+" : Operation.BinaryOperation({$0 + $1}, {$0 + "+" + $1}),
        "−" : Operation.BinaryOperation({$0 - $1}, {$0 + "-" + $1}),
        "=" : Operation.Equals
    ]
    
    enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double, (String) -> String)
        case BinaryOperation((Double, Double) -> Double, (String, String) -> String)
        case Equals
    }
    
    func performOperation(symbol: String) {
        
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
                
                descriptionAccumulator = symbol
            case .UnaryOperation(let function, let descriptionFunction):
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
                
                accumulator = function(accumulator)
                
            case .BinaryOperation(let function, let descriptionFunction):
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator, descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
                isPartialResult = true

                
            case .Equals:
                executePendingBinaryOperation()
                
                isPartialResult = false
            }
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            pending = nil
        }
        isPartialResult = false
    }
    
    
    
    struct PendingBinaryOperationInfo {
        // store pending info
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        
        // store pending description info
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
}