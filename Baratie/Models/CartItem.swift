//
//  Cart.swift
//  Baratie
//
//  Created by Mickale Saturre on 4/6/21.
//

import UIKit
import CoreData
import Firebase

let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
let loginEamil = Auth.auth().currentUser?.email!

struct CartItem: Hashable {
    var id: String
    var price: Double
    var name: String
    var image: String
    var quantity: Int16
    static var request: NSFetchRequest<CustomerCart> = CustomerCart.fetchRequest()
    var cartData = [CustomerCart]()
    
    mutating func addToCart() {
        let cart = CustomerCart(context: context)
        cart.customer_email = Auth.auth().currentUser?.email
        cart.menu_id = id
        cart.menu_name = name
        cart.menu_image = image
        cart.original_price = price
        cart.quantity = 1
        cartData.append(cart)
        _ = CartItem.saveCartData()
    }
    
    func getMenuFromCart(menu_id: String) -> Array<CustomerCart> {
        CartItem.request.predicate = NSPredicate.init(format: "customer_email = %@ AND menu_id = %@", loginEamil!, menu_id)

        return CartItem.fetchCustomerCart()
    }

    func deleteCartItems(_ menu_id: String) -> Bool {
        return CartItem.changeItemQuantity(menu_id, 0)
    }
    
    func filterItem(_ item: Array<CartItem>) -> Dictionary<CartItem, Int> {
        let mappedItems = item.map { ($0, Int(1)) }
        let counts = Dictionary(mappedItems, uniquingKeysWith: +)
        
        return counts
    }

    static func changeItemQuantity(_ menu_id: String, _ quantity: Int16) -> Bool {
        CartItem.request.predicate = NSPredicate.init(format: "customer_email = %@ AND menu_id = %@", loginEamil!, menu_id)
        let objects = CartItem.fetchCustomerCart()

        for object in objects {
            object.quantity = quantity
        }
        
        return CartItem.saveCartData()
    }

    static func saveCartData() -> Bool {
        do {
            try context.save()
            
            return true
        } catch {
            print("Error saving cart data with \(error)")
            
            return false
        }
    }
    
    static func getCustomerCartItems() -> Array<CustomerCart> {
        let predicate = NSPredicate(format: "customer_email CONTAINS %@ AND  quantity > 0", loginEamil!)
        request.predicate = predicate
        
        return CartItem.fetchCustomerCart()
    }

    static func fetchCustomerCart() -> Array<CustomerCart> {
        do {
            return try context.fetch(CartItem.request)
        } catch {
            print("Error fetching cart data with \(error)")
            
            return []
        }
    }

    static func deleteAllData() {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerCart")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
           try context.execute(deleteRequest)
           try context.save()
       } catch {
           print ("There was an error")
       }
    }
}

protocol CartItemDelegate {
    func updateCartItems(items: [CartItem], deletedItem: [CartItem]);
}

protocol CartCellDelegate {
    func showAlert(title:String, message:String, tableCell: UITableViewCell);
}
