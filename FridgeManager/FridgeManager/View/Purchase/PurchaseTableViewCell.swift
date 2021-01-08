//
//  PurchaseTableViewCell.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/11/30.
//

import UIKit
import Firebase

class PurchaseTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var whoLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectedBackgroundView = UIView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setup(data: List, whoBuy: String) {
       
        titleLabel.text = data.name
       
        amountLabel.text = "數量：\(String(data.amount)) \(String(data.unit))"
        
        if data.whoBuy == "" {
            whoLabel.text = "待認領"
        } else {
            
            
            Firestore.firestore().collection("users").document(data.whoBuy).getDocument { (documentSnapshot, error) in
                
                let userData = try? documentSnapshot?.data(as: User.self)
                
                guard let user = userData else { return }
                
                self.whoLabel.text = user.displayName
            }
        }
        
     

    }
}
