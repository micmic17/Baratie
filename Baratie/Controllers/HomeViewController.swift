//
//  HomeViewController.swift
//  Baratie
//
//  Created by Mickale Saturre on 3/29/21.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var menuTableView: UITableView!
    let cellSpacingHeight: CGFloat = 5
    let backgroundColor = UIColor(named: "background_color")
    let textColor = UIColor(named: "text_color")
    let btn = BadgedButtonItem(with: UIImage(systemName: "cart"))
    var menus: [Menu] = []
    var order: [CartItem] = []
    var cartItems: Dictionary<CartItem, Int> = [:]
    var counter = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        menuTableView.dataSource = self
        menuTableView.delegate = self

        menuTableView.register(UINib(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: "MenuCell")
        navigationItem.hidesBackButton = true
        title = "Baratie"
        logoutButton.title = "Logout"
        
        // Create cart bar button item
        createCart()
        
        loadMenus()
        
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        DispatchQueue.main.async { [self] in
            let cartItem = CartItem.getCustomerCartItems()

            if !cartItem.isEmpty {
                let dictionary = Dictionary(grouping: cartItem, by: { (element: CustomerCart) in
                    return element.menu_id
                })
                
                for item in dictionary.values {
                    let cart = CartItem(id: item[0].menu_id!, price: item[0].original_price)
                    
                    cartBadge(cart, "firstLoad")
                }
                
//                self.counter = dictionary.count
//                self.btn.setBadge(with: self.counter)
            }
        }
        
    }

    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }

    }

    func cartBadge(_ item: CartItem, _ type: String) {
//        counter += 1
//
//        btn.setBadge(with: counter)
//        menus[index].quantity -= 1
        var cart = item
        
        if type == "tableView" {
            let cartData = cart.getMenuFromCart(menu_id: cart.id)

            if (cartData.isEmpty) {
                cart.addToCart()
            } else {
                for item in cartData {
                    item.quantity += 1
                    print(cart.saveCartData())
                }
            }
        }
        
        
        self.order.append(cart)
        cartItems = cart.filterItem(order)
        counter = cartItems.count
        btn.setBadge(with: counter)
        menuTableView.reloadData()
    }
    
    func createCart() {
        btn.badgeAnimation = true
        btn.badgeSize = .large
        self.navigationItem.leftBarButtonItem = btn
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "text_color")
        
        btn.tapAction = {
            self.cartPressed()
        }
    }
    
    func cartPressed() {
        self.performSegue(withIdentifier: "GoToCart", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "GoToCart") {
            let vc = segue.destination as! CartViewController
            vc.cartItems = cartItems
            vc.cartItemDelegate = self
        }
    }
    
    func loadMenus() {
        let db = Firestore.firestore()

        db.collection("menus").addSnapshotListener { documentSnapshot, error in
            if let e = error {
                print("There's some error \(e)")
            } else {
                if let snapshotDocs = documentSnapshot?.documents {
                    for doc in snapshotDocs {
                        let data = doc.data()
                        if let name = data["name"] as? String,
                           let description = data["description"] as? String,
                           let image = data["image"] as? String,
                           let price = data["price"] as? Double,
                           let quantity = data["quantity"] as? Int,
                           let availability = data["availability"] as? Bool {
                            let menu = Menu(id: doc.documentID, name: name, description: description, price: price, image: image, availability: availability, quantity: quantity)
                            self.menus.append(menu)
                            
                            DispatchQueue.main.async {
                                self.menuTableView.reloadData()
                                let indexPath = IndexPath(row: self.menus.count - 1, section: 0)
                                self.menuTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = menuTableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        
        if (menus[indexPath.row].quantity > 0) {
            cell.menuImage.image = UIImage(named: "baratie_logo")
            cell.menuImage.contentMode = .scaleAspectFill
            cell.menuPrice.text = "\(menus[indexPath.row].price) Php"
            cell.menuQuantity.text = "Stocks Available: \(menus[indexPath.row].quantity)"
            cell.addToCartLabel.tintColor = UIColor(named: "white")
            
            // Cell design
            cell.backgroundColor = backgroundColor
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 8
            cell.clipsToBounds = true
            cell.layer.shadowOffset = CGSize(width: -1, height: 1)
            let borderColor: UIColor = textColor!
            cell.layer.borderColor = borderColor.cgColor
            
            // Menu name design
            cell.menuName.text = menus[indexPath.row].name
            designCellLabel(cell.menuName, 30)
            
            // Menu description design
            cell.menuDescription.text = menus[indexPath.row].description
            designCellLabel(cell.menuDescription, 17)
        } else {
            cell.selectionStyle = .none
            cell.menuQuantity.text = "Out of stock"
        }

        return cell
    }

    func designCellLabel(_ label: UILabel, _ textSize: Int) {
        label.textAlignment = .center
        label.textColor = textColor
        label.tintColor = textColor
        label.font = .systemFont(ofSize: CGFloat(textSize))
        label.backgroundColor = backgroundColor
    }
}

// interact with menus
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if menus[indexPath.row].quantity > 0 {
            let cart = CartItem(id: menus[indexPath.row].id, price: menus[indexPath.row].price)
            cartBadge(cart, "tableView")
        }
    }
    
    // Set the spacing between sections
   func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       return cellSpacingHeight
   }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}

extension HomeViewController: CartItemDelegate {
    func updateCartItems(items: [CartItem]) {
//        self.order = []
//        for item in items {
//            let cart = Cart(id: item.id, name: item.name, image: item.image, price: item.price)
//            self.order.append(cart)
//            cartItems = cart.filterItem(order)
//        }
//
//        counter = items.count
//        btn.setBadge(with: counter)
//        menuTableView.reloadData()
    }
}
