//
//  ImageTableViewCell.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/23.
//

import UIKit
import Kingfisher

class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var recipeImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setup(data: Recipe) {
        
        titleLabel.text = data.id
        
        let photo = URL(string: data.photo)
        recipeImageView.kf.setImage(with: photo, options: [.transition(.fade(0.5))])
        recipeImageView.contentMode = .scaleAspectFill
        recipeImageView.clipsToBounds = true
        
    }
    
    func setupTitle(data: String) {
        titleLabel.text = data
    }
    
}
