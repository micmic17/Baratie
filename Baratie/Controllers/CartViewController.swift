//
//  CartViewController.swift
//  Baratie
//
//  Created by Mickale Saturre on 3/30/21.
//

import UIKit

class CartViewController: UIViewController {
    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var checkButton: UIButton!

    var cartItemDelegate: CartItemDelegate?
    var cartItems: Dictionary<CartItem, Int> = [:]
    var items: [CartItem] = []
    var counter = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for item in cartItems.values {
            self.counter.append(item)
        }
        
        for item in cartItems.keys {
            let x = CartItem(id: item.id, name: item.name, image: item.image, price: item.price)
            self.items.append(x)
        }
        
        cartTableView.register(UINib(nibName: "CartCell", bundle: nil), forCellReuseIdentifier: "CartCell")
        cartTableView.separatorStyle = .none
    }
    
    @IBAction func checkOutButtonPressed(_ sender: UIBarButtonItem) {
    }
}

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cartTableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath) as! CartCell
        cell.itemName.text = items[indexPath.row].name
        cell.itemImage.image = UIImage(named: "baratie_logo")
        cell.itemPrice.text = "\(items[indexPath.row].price)"
        cell.itemQuantity.text = "\(counter[indexPath.row])"
        cell.delegate = self

        return cell
    }
}

// interact with menus
extension CartViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
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
                items.remove(at: indexPath[1])
                self.cartTableView.deleteRows(at: [indexPath], with: .fade)
                self.cartItemDelegate?.updateCartItems(items: items)
            }
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
}

struct CartItem: Hashable {
    var id: String
    var name: String
    var image: String
    var price: Double
    
    func filterItem(_ item: Array<CartItem>) -> Dictionary<CartItem, Int> {
        let mappedItems = item.map { ($0, Int(1)) }
        let counts = Dictionary(mappedItems, uniquingKeysWith: +)
        
        return counts
    }
}

protocol CartItemDelegate {
    func updateCartItems(items: [CartItem]);
}
