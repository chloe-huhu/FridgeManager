//
//  CellView.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/11/28.
//

import UIKit

class CellView: UITableViewCell {

    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //類似左滑出來的色塊
        let selectedCellView = UIView()
        
        selectedCellView.backgroundColor = .white
        
        self.backgroundView = selectedCellView
        
        //選中不變色
        self.selectedBackgroundView = UIView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setup(data: Food) {
        
        titleLabel.text = data.name
        amountLabel.text = "數量： \(String(data.amount)) \(data.unit)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateLabel.text = "過期日：\(dateFormatter.string(from: data.expiredDate))"
    }
    
}
