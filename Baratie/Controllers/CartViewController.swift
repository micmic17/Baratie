//
//  CartViewController.swift
//  Baratie
//
//  Created by Mickale Saturre on 3/30/21.
//

import UIKit
import CoreData
import Firebase

class CartViewController: UIViewController {
    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var checkButton: UIButton!

    var cartItemDelegate: CartItemDelegate?
    var items: [CartItem] = []
    var counter = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let cartItem = CartItem.getCustomerCartItems()
  
        if !cartItem.isEmpty {
            let dictionary = Dictionary(grouping: cartItem, by: { (element: CustomerCart) in
                return element.menu_id
            })

            for item in dictionary.values {
                let cart = CartItem(id: item[0].menu_id!, price: item[0].original_price, name: item[0].menu_name!, image: item[0].menu_image!, quantity: item[0].quantity)

                items.append(cart)
            }
        }

        cartTableView.register(UINib(nibName: "CartCell", bundle: nil), forCellReuseIdentifier: "CartCell")
        cartTableView.separatorStyle = .none
    }
    
    @IBAction func checkOutButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "CartToCheckout", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "CartToCheckout") {
            let vc = segue.destination as! CheckoutViewController
            vc.cartItems = items
        }
    }
}

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cartTableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath) as! CartCell
        cell.itemImage.accessibilityLabel = items[indexPath.row].id
        cell.itemName.text = items[indexPath.row].name
        cell.itemImage.image = UIImage(named: "baratie_logo")
        cell.itemPrice.text = "\(items[indexPath.row].price)"
        cell.itemQuantity.text = "\(items[indexPath.row].quantity)"
        cell.delegate = self

        return cell
    }
}

// interact with menus
extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.cartItemDelegate?.updateCartItems(items: items, deletedItem: [items[indexPath.row]])
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension CartViewController: CartCellDelegate {
    func showAlert(title: String, message: String, tableCell: UITableViewCell) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler:  { [self]_ in
            if let indexPath = self.cartTableView.indexPath(for: tableCell) {
                self.cartItemDelegate?.updateCartItems(items: items, deletedItem: [items[indexPath[1]]])
                items.remove(at: indexPath[1])
                self.cartTableView.deleteRows(at: [indexPath], with: .fade)
            }
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
}
