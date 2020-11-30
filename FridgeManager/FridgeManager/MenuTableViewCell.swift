//
//  MenuTableViewCell.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/11/30.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var menuImageView: UIImageView!
    
    @IBOutlet weak var menuTitle: UILabel!
    
    @IBOutlet weak var ingredientLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
