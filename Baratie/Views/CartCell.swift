//
//  CartCell.swift
//  Baratie
//
//  Created by Mickale Saturre on 3/30/21.
//

import UIKit

class CartCell: UITableViewCell {
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var itemQuantity: UILabel!
    @IBOutlet weak var addQuantity: UIButton!
    @IBOutlet weak var deductQuantity: UIButton!
    var delegate: CartCellDelegate?
    var defaultPrice: Double!
    var quantity: Int16!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func didMoveToSuperview() {
        defaultPrice = Double(itemPrice.text!)
        quantity = Int16(itemQuantity.text!)
        itemPrice.text = "\(Double(quantity!) * defaultPrice!)"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addDeductQuantityPressed(_ sender: UIButton) {
        if (sender.currentTitle == "+") { quantity! += 1 } else { quantity! -= 1 }
        
        if (quantity! > 0) {
            itemQuantity.text = "\(quantity!)"
            itemPrice.text = "\(Double(quantity!) * defaultPrice!)"
        } else {
            self.delegate?.showAlert(title: "Remove \(itemName.text!)", message: "Are you sure you want to remove this item from the cart?", tableCell: self)
        }
        
    }
}

