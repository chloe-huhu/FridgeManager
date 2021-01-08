//
//  ContentTableViewCell.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/23.
//

import UIKit

class ContentTableViewCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setup(data: String) {
        contentLabel.text = data
    }
}
