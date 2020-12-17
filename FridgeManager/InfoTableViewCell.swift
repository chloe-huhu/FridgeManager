//
//  InfoTableViewCell.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/6.
//

import UIKit

class InfoTableViewCell: UITableViewCell {

    @IBOutlet weak var fridgeIDLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectedBackgroundView = UIView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
