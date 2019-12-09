//
//  ViewController.swift
//  LinearChart
//
//  Created by Dmytro Mashtaler on 12/7/19.
//  Copyright © 2019 Dmytro Mashtaler. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lineChart: LineChart!
        
    @IBOutlet weak var numberOfRandomValuesTextField: UITextField!
    @IBOutlet weak var generateFromTextField: UITextField!
    @IBOutlet weak var generateToTextField: UITextField!
    @IBOutlet weak var goRandomButton: UIButton!
    
    @IBOutlet weak var appendNewValueTextField: UITextField!
    @IBOutlet weak var enteredValuesLabel: UILabel!
    @IBOutlet weak var clearEnteredDataButton: UIButton!
    @IBOutlet weak var goManuallyButton: UIButton!
    
    @IBOutlet weak var isCurvedButton: CheckBox!
    
    private var numberOfRandomValues = 0
    private var generateRandomFrom = 0
    private var generateRandomTo = 0
    private var manuallyEnteredValues : [Int] = []
    private var drawRandomChart = false
    
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
            self.view.backgroundColor = #colorLiteral(red: 0, green: 0.3529411765, blue: 0.6156862745, alpha: 1)
            
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

            setupUI()
        }
    
    private func setupUI() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        setupButton(button: goRandomButton)
        setupButton(button: clearEnteredDataButton)
        setupButton(button: goManuallyButton)
        
        addDoneButtonOnKeyboard(textField: numberOfRandomValuesTextField)
        addDoneButtonOnKeyboard(textField: generateFromTextField)
        addDoneButtonOnKeyboard(textField: generateToTextField)
        addDoneButtonOnKeyboard(textField: appendNewValueTextField)
    }
    
    private func setupButton(button: UIButton) {
        button.layer.cornerRadius = 12.0
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.black.cgColor
    }
        
    private func generateEntries() -> [PointEntry] {
        var result: [PointEntry] = []
        if drawRandomChart {
            for i in 0..<numberOfRandomValues {
                
                let value = Int.random(in: generateRandomFrom ..< generateRandomTo)
                
                let formatter = DateFormatter()
                formatter.dateFormat = "d MMM"
                var date = Date()
                date.addTimeInterval(TimeInterval(24*60*60*i))
                
                result.append(PointEntry(value: value, label: formatter.string(from: date)))
            }
        } else {
            for i in 0..<manuallyEnteredValues.count {
                
                let value = manuallyEnteredValues[i]
                
                let formatter = DateFormatter()
                formatter.dateFormat = "d MMM"
                var date = Date()
                date.addTimeInterval(TimeInterval(24*60*60*i))
                
                result.append(PointEntry(value: value, label: formatter.string(from: date)))
            }
        }
        return result
    }
    
    func addDoneButtonOnKeyboard(textField: UITextField) {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        var done: UIBarButtonItem?
        
        if textField == appendNewValueTextField {
            done = UIBarButtonItem(title: "Append", style: UIBarButtonItem.Style.done, target: self, action: #selector(ViewController.appendNewValue))
        } else {
            done = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(ViewController.doneButtonAction))
        }

        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done!)

        doneToolbar.items = items
        doneToolbar.sizeToFit()

        textField.inputAccessoryView = doneToolbar
    }

    @objc func appendNewValue() {
        guard appendNewValueTextField.text != "" else {
            showAlertMessage("Please, fill missing data", withTitle: "")
            return
        }
        
        manuallyEnteredValues.append(Int(appendNewValueTextField.text!) ?? 0)
        
        var enteredValuesString = "Entered values: "
        for value in 0..<manuallyEnteredValues.count {
            enteredValuesString += String(manuallyEnteredValues[value]) + ", "
        }
        enteredValuesString.removeLast()
        enteredValuesString.removeLast()
        
        enteredValuesLabel.text = enteredValuesString
        appendNewValueTextField.text = ""
    }
    
    @objc func doneButtonAction() {
        if numberOfRandomValuesTextField.isFirstResponder {
            generateFromTextField.becomeFirstResponder()
        } else if generateFromTextField.isFirstResponder {
            generateToTextField.becomeFirstResponder()
        } else if generateToTextField.isFirstResponder {
            self.view.endEditing(true)
        }
    }

    @IBAction func goRandomButtonAction(_ sender: Any) {
        guard numberOfRandomValuesTextField.text != "", generateFromTextField.text != "", generateToTextField.text != "" else {
            showAlertMessage("Please, fill missing data", withTitle: "")
            return
        }
        
        let from = Int(generateFromTextField.text!) ?? 0
        let to = Int(generateToTextField.text!) ?? 0
        
        guard to > from else {
            showAlertMessage("Value 'from' must be less than value 'to'", withTitle: "Error")
            return
        }
        
        drawRandomChart = true
        
        numberOfRandomValues = Int(numberOfRandomValuesTextField.text!) ?? 0
        generateRandomFrom = Int(generateFromTextField.text!) ?? 0
        generateRandomTo = Int(generateToTextField.text!) ?? 0
        
        let dataEntries = generateEntries()
        
        lineChart.dataEntries = dataEntries
        lineChart.isCurved = isCurvedButton.isChecked
        view.endEditing(true)
    }
    
    @IBAction func clearEnteredDataButtonAction(_ sender: Any) {
        manuallyEnteredValues.removeAll()
        enteredValuesLabel.text = ""
        view.endEditing(true)
        
        appendNewValueTextField.text = ""
        numberOfRandomValuesTextField.text = ""
        generateToTextField.text = ""
        generateFromTextField.text = ""
        
        lineChart.cleanChart()
    }
    
    @IBAction func goManuallyButtonAction(_ sender: Any) {
        guard !manuallyEnteredValues.isEmpty else {
            showAlertMessage("Entered data is empty", withTitle: "")
            return
        }
        drawRandomChart = false
        
        let dataEntries = generateEntries()
        
        lineChart.dataEntries = dataEntries
        lineChart.isCurved = isCurvedButton.isChecked
        
        view.endEditing(true)
    }
    
    var isKeyboardAppear = false

    @objc func keyboardWillShow(notification: NSNotification) {
        if !isKeyboardAppear {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y == 0{
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
            isKeyboardAppear = true
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if isKeyboardAppear {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y != 0{
                    self.view.frame.origin.y = 0//keyboardSize.height
                }
            }
             isKeyboardAppear = false
        }
    }
}

