//
//  AddFoodTableViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/1.
//

import UIKit

class AddFoodTableViewController: UITableViewController {

    let dataCategory = ["肉類", "蛋類", "水果類"]
    
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var foodTitleLabel: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var purchaseTextField: UITextField!
    @IBOutlet weak var expiredTextField: UITextField!
    
    @IBOutlet var categoryPickerView: UIPickerView! {
        didSet {
            categoryPickerView.delegate = self
            categoryPickerView.dataSource = self
        }
    }
    
    @IBOutlet var purchaseDatePicker: UIDatePicker!
    
    @IBOutlet var expiredDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        categoryTextField.inputView = categoryPickerView
//        purchaseTextField.inputView = purchaseDatePicker
//        expiredTextField.inputView = expiredDatePicker
    }
    
    @IBAction func categoryDidSelected(_ sender: Any) {
        categoryTextField.text = dataCategory[0]
    }
    
}

extension AddFoodTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataCategory.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataCategory[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTextField.text = dataCategory[row]
    }
}
