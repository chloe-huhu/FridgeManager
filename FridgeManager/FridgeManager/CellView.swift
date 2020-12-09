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
        
        //類似左滑出來的色塊
        let selectedCellView = UIView()
        
        selectedCellView.backgroundColor = #colorLiteral(red: 0.8783852458, green: 0.8784634471, blue: 0.8783199191, alpha: 1)
        
        self.backgroundView = selectedCellView
        
        //選中不變色
        self.selectedBackgroundView = UIView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setup(data: Food) {
        
        rowTitleLabel.text = data.name
        rowAmountLabel.text = "數量： \(String(data.amount)) \(data.unit)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        rowDateLabel.text = "過期日：\(dateFormatter.string(from: data.expiredDate))"
    }
    
}
