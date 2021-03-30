//
//  MenuCell.swift
//  Baratie
//
//  Created by Mickale Saturre on 3/30/21.
//

import UIKit

class MenuCell: UITableViewCell {
    @IBOutlet weak var menuBubble: UIView!
    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var menuDescription: UILabel!
    @IBOutlet weak var menuPrice: UILabel!
    @IBOutlet weak var menuQuantity: UILabel!
    @IBOutlet weak var menuName: UILabel!
    @IBOutlet weak var addToCartLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
