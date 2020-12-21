//
//  PurchaseTableViewCell.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/11/30.
//

import UIKit

class PurchaseTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var whoLabel: UILabel!
    
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectedBackgroundView = UIView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setup(data: List) {
        
        titleLabel.text = data.name
        amountLabel.text = "數量：\(String(data.amount)) \(String(data.unit))"
        whoLabel.text = data.whoBuy == "" ? "等你認領" : data.whoBuy

        if data.whoBuy == "" {
            whoLabel.text = "等你認領"
            photoImageView.image = UIImage(systemName: "person")
        } else {
            whoLabel.text = data.whoBuy
            
        }
    }
}
