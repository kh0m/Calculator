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
            // make a string from descriptionArray
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
    
    private var descriptionArray = ["0"]
    
    private var pending: PendingBinaryOperationInfo?
    var isPartialResult = false
    var binarySymbolEntered = false
    
    func setOperand(operand: Double) {
        binarySymbolEntered = false
        accumulator = operand
        internalProgram.append(operand)
        
        if isPartialResult == false {
            descriptionArray.removeAll()
        }
        
        let string = formatDouble(operand)

        descriptionArray.append(string)
    }
    
    var variableValues: Dictionary<String, Double> = [:]
    
    func setOperand(variableName: String) {
        binarySymbolEntered = false
        
        if let operand = variableValues[variableName] {
            accumulator = operand
        } else {
            accumulator = 0
        }
        internalProgram.append(variableName)
        
        if isPartialResult == false {
            descriptionArray.removeAll()
        }
        
        descriptionArray.append(variableName)
    }
    
    // format a Double then make it into a String
    func formatDouble(double: Double) -> String {
        
        let formatter = NSNumberFormatter()
        formatter.roundingMode = .RoundDown
        if trunc(double) == double {
            formatter.maximumFractionDigits = 0
        } else {
            formatter.maximumFractionDigits = 6
        }
        let num = NSNumber(double: double)
        return formatter.stringFromNumber(num)!
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
        "=" : Operation.Equals,
        "rand" : Operation.Random
    ]
    
    enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
        case Random
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
                
                
            case .Random:
                let rand = drand48()
                accumulator = Double(rand)
                if isPartialResult == false {
                    descriptionArray.removeAll()
                }
                descriptionArray.append(symbol)
                binarySymbolEntered = false
            }
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            if binarySymbolEntered {
                let string = formatDouble(accumulator)
                descriptionArray.append(string)
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
                        // op is a Double
                        setOperand(operand)
                    } else if let stringOp = op as? String {
                        if operations[stringOp] != nil {
                            // op is an operation
                            performOperation(stringOp)
                        } else {
                            // op is a variable
                            setOperand(stringOp)
                        }
                    }
                }
            }
            isPartialResult = true
        }
    }
    
    func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
        description = " "
        isPartialResult = false
    }
    
    func clearVariables() {
        variableValues = [:]
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