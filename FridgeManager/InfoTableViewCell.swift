//
//  InfoTableViewCell.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/6.
//

import UIKit

class InfoTableViewCell: UITableViewCell {

    @IBOutlet weak var fridgeIDLabel: UILabel!
    
    @IBOutlet weak var numberOfuserLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    func setup(info) {
//        fridgeIDLabel.text =
//        numberOfuserLabel.text =
//
//    }
    
}
