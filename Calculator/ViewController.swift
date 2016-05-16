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
    var userIsInTheMiddleOfTyping = false
    private var brain = CalculatorBrain()
    
    // allows display's string to be usable as double and vice versa
    var displayValue : Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    @IBAction func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            display.text = display.text! + digit
        } else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
        
        // ensure only one decimal
        if digit == "." {
            decimalButton.enabled = false
        }
        
    }
    
    @IBAction func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
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
        brain.description = "0"
        descriptionDisplay.text = brain.description
        
        // clear display
        display.text = "0"
        
        // reset other variables
        userIsInTheMiddleOfTyping = false
        brain.isPartialResult = false
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

