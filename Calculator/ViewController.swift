//
//  ViewController.swift
//  Calculator
//
//  Created by Hom, Kenneth on 5/12/16.
//  Copyright © 2016 Hom, Kenneth. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var decimalButton: UIButton!
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var descriptionDisplay: UILabel!
    var userIsInTheMiddleOfTyping = true
    private var brain = CalculatorBrain()
    
    // allows display's string to be usable as double and vice versa
    var displayValue : Double? {
        get {
            if let text = Double(display.text!) {
                return text
            } else {
                return nil
            }
        }
        set {
            if newValue == nil {
                display.text = "0"
            } else {
                let formatter = NSNumberFormatter()
                formatter.roundingMode = .RoundDown
                if trunc(newValue!) == newValue! {
                    formatter.maximumFractionDigits = 0
                } else {
                    formatter.maximumFractionDigits = 6
                }
                let num = NSNumber(double: newValue!)
                let string = formatter.stringFromNumber(num)
                display.text = string!
            }
        }
    }
    
    @IBAction func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            if display.text! == "0" {
                display.text = digit
            } else {
                display.text = display.text! + digit
            }
        } else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
        
        // ensure only one decimal
        if digit == "." {
            decimalButton.enabled = false
        }
        
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
    @IBAction func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping && displayValue != nil {
            brain.setOperand(displayValue!)
        }
        userIsInTheMiddleOfTyping = false
        
        decimalButton.enabled = true
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        
        displayValue = brain.result
        
        updateDescriptionDisplay()
    }
    
    private func updateDescriptionDisplay() {
        if brain.isPartialResult == true {
            descriptionDisplay.text = brain.description + "..."
        } else {
            descriptionDisplay.text = brain.description + "="
        }
    }
    
    
    @IBAction func clear(sender: UIButton) {
        // clear brain and description display
        brain.clear()
        descriptionDisplay.text = brain.description
        brain.description = "0"
        
        // clear display
        display.text = "0"
        
        // reset other variables
        userIsInTheMiddleOfTyping = false
    }
    
    
    @IBAction func backSpace() {
        if let displayString = display.text {
            var characters = displayString.characters
            let lastCharacter = characters.popLast()
            if lastCharacter == "." {
                decimalButton.enabled = true
            }
            if characters.count > 0 {
                display.text = String(characters)
            } else {
                display.text = "0"
            }
            userIsInTheMiddleOfTyping = true
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

