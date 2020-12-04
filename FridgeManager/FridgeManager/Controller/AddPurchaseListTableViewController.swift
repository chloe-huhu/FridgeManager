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
    
    @IBOutlet weak var titleTextField: RoundedTextField! {
        didSet {
            titleTextField.tag = 1
            titleTextField.becomeFirstResponder()
            titleTextField.delegate = self
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
        if titleTextField.text == "" || amountTextField.text == "" ||
            unitTextField.text == "" || brandTextField.text == "" ||
            placeTextField.text == "" {
            
            let alterController = UIAlertController(title: "Oops!", message: "請填好填滿", preferredStyle:  .alert)
            
            let alertAction = UIAlertAction(title: "好", style: .default, handler: nil)
            
            alterController.addAction(alertAction)
            
            present(alterController, animated: true, completion: nil)
            
            return
        }
        print("name:\(titleTextField.text ?? "")")
        print("name:\(amountTextField.text ?? "")")
        print("name:\(unitTextField.text ?? "")")
        print("name:\(brandTextField.text ?? "")")
        print("name:\(placeTextField.text ?? "")")
        print("name:\(noteTextView.text ?? "")")
        
//        guard let name =
        
        //翻回去前一頁
        navigationController?.popViewController(animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 6
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let photoSourceRequestController = UIAlertController(title: "請選擇", message: "拍照或是圖片庫", preferredStyle: .actionSheet)
            
            let cameraAction = UIAlertAction(title: "拍照", style: .default, handler: { (_) in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .camera
                    imagePicker.delegate = self
                    
                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
            
            let photoLibraryAction = UIAlertAction(title: "照片庫", style: .default, handler: { (_) in
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .photoLibrary
                    imagePicker.delegate = self
                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
            photoSourceRequestController.addAction(cameraAction)
            
            photoSourceRequestController.addAction(photoLibraryAction)
            
            photoSourceRequestController.addAction(cancelAction)
            
            present(photoSourceRequestController, animated: true, completion: nil)
        }
    }
}

extension AddPurchaseListTableViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = selectedImage
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
        }
        
        //約束條件
        let leadingConstraint = NSLayoutConstraint(item: imageView as Any, attribute: .leading, relatedBy: .equal, toItem: imageView.superview, attribute: .leading, multiplier: 1, constant: 0)
        leadingConstraint.isActive = true
        
        let trailingConstraint = NSLayoutConstraint(item: imageView as Any, attribute: .trailing, relatedBy: .equal, toItem: imageView.superview, attribute: .trailing, multiplier: 1, constant: 0)
        trailingConstraint.isActive = true
        
        let topConstraint = NSLayoutConstraint(item: imageView as Any, attribute: .top, relatedBy: .equal, toItem: imageView.superview, attribute: .top, multiplier: 1, constant: 0)
        topConstraint.isActive = true
        
        let bottomConstraint = NSLayoutConstraint(item: imageView as Any, attribute: .bottom, relatedBy: .equal, toItem: imageView.superview, attribute: .bottom, multiplier: 1, constant: 0)
        bottomConstraint.isActive = true
        
        dismiss(animated: true, completion: nil)
    }
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

