//
//  CellView.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/11/28.
//

import UIKit

class CellView: UITableViewCell {

    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var rowTitleLabel: UILabel!
    @IBOutlet weak var rowAmountLabel: UILabel!
    @IBOutlet weak var rowDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setup(data: Foods) {
        
        rowTitleLabel.text = data.name
        rowAmountLabel.text = String(data.amount)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        rowDateLabel.text = dateFormatter.string(from: data.expiredDate)
    }
    
}
