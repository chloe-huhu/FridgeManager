//
//  AddPurchaseListTableViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/3.
//

import UIKit

class AddPurchaseListTableViewController: UITableViewController {

    let dataUnit = ["公克", "公斤", "包", "串", "根"]
    
    @IBOutlet weak var changePicLabel: UILabel! {
        didSet {
            changePicLabel.layer.cornerRadius = 25
            changePicLabel.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var itemNameTextField: RoundedTextField! {
        didSet {
            itemNameTextField.tag = 1
            itemNameTextField.becomeFirstResponder()
            itemNameTextField.delegate = self
        }
    }
    
    @IBOutlet weak var amountTextField: RoundedTextField! {
        didSet {
            amountTextField.tag = 2
            amountTextField.delegate = self
        }
    }
    @IBOutlet weak var unitTextField: RoundedTextField! {
        didSet {
            unitTextField.tag = 3
            unitTextField.delegate = self
            unitTextField.inputView = unitPickerView
        }
    }
    @IBOutlet weak var brandTextField: RoundedTextField! {
        didSet {
            brandTextField.tag = 4
            brandTextField.delegate = self
        }
    }
    @IBOutlet weak var placeTextField: RoundedTextField! {
        didSet {
            placeTextField.tag = 5
            placeTextField.delegate = self
        }
    }
   
    @IBOutlet weak var noteTextView: UITextView! {
        didSet {
            noteTextView.tag = 6
            noteTextView.layer.cornerRadius = 5.0
            noteTextView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var unitPickerView: UIPickerView! {
        didSet {
            unitPickerView.delegate = self
            unitPickerView.dataSource = self
        }
    }
    
    @IBAction func saveBtnTapped(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 6
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
//設定return 跳到下一個文字框
extension AddPurchaseListTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
}

extension AddPurchaseListTableViewController: UIPickerViewDelegate,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataUnit.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataUnit[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        unitTextField.text = dataUnit[row]
    }
}
