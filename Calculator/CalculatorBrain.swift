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
    private var internalProgram = [AnyObject]()
    
    var description: String {
        get {
            var localString = ""
            for item in descriptionArray {
                localString.appendContentsOf(item)
            }
            return localString
        }
        set {
            descriptionArray.removeAll()
            descriptionArray.append(newValue)
        }
    }
    
    private var descriptionArray = [""]
    
    private var pending: PendingBinaryOperationInfo?
    var isPartialResult = false
    private var binarySymbolEntered = false
    
    
    func setOperand(operand: Double) {
        binarySymbolEntered = false
        accumulator = operand
        internalProgram.append(operand)
        
        if isPartialResult == false {
            descriptionArray.removeAll()
        }
        descriptionArray.append(String(operand))
    }
    
    var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOperation(sqrt),
        "cos" : Operation.UnaryOperation(cos),
        "sin" : Operation.UnaryOperation(sin),
        "±" : Operation.UnaryOperation({-$0}),
        "x²" : Operation.UnaryOperation({pow($0,2)}),
        "x³" : Operation.UnaryOperation({pow($0,3)}),
        "×" : Operation.BinaryOperation({$0 * $1}),
        "÷" : Operation.BinaryOperation({$0 / $1}),
        "+" : Operation.BinaryOperation({$0 + $1}),
        "−" : Operation.BinaryOperation({$0 - $1}),
        "=" : Operation.Equals
    ]
    
    enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol)
        
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
                
                if isPartialResult == false {
                    descriptionArray.removeAll()
                }
                descriptionArray.append(symbol)
                binarySymbolEntered = false
                
            case .UnaryOperation(let function):
                if isPartialResult {
                    let lastElement = descriptionArray.popLast()
                    descriptionArray.append("\(symbol)(")
                    descriptionArray.append(lastElement!)
                    descriptionArray.append(")")
                } else {
                    let current = descriptionArray
                    descriptionArray.removeAll()
                    descriptionArray.append("\(symbol)(")
                    descriptionArray.appendContentsOf(current)
                    descriptionArray.append(")")
                }
                
                accumulator = function(accumulator)

                
            case .BinaryOperation(let function):
                descriptionArray.append(symbol)
                

                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                isPartialResult = true
                
                binarySymbolEntered = true
                
            case .Equals:
                
                executePendingBinaryOperation()
                
                isPartialResult = false

            }
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            if binarySymbolEntered {
                descriptionArray.append(String(accumulator))
                binarySymbolEntered = false
            }

            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
        
        isPartialResult = false
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operation = op as? String {
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
    func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
        description = " "
        isPartialResult = false
    }
    
    struct PendingBinaryOperationInfo {
        // store pending info
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
}