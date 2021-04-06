//
//  Cart.swift
//  Baratie
//
//  Created by Mickale Saturre on 4/6/21.
//

import UIKit
import CoreData
import Firebase

struct CartItem: Hashable {
    var id: String
    var price: Double
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    var cartData = [CustomerCart]()
    
    mutating func addToCart() {
        let cart = CustomerCart(context: self.context)
        cart.customer_email = Auth.auth().currentUser?.email
        cart.menu_id = id
        cart.original_price = price
        cart.quantity = 1
        self.cartData.append(cart)
        print(self.saveCartData())
    }
    
    func saveCartData() -> Bool {
        do {
            try context.save()
            
            return true
        } catch {
            print("Error saving cart data with \(error)")
            
            return false
        }
    }
    
    func getMenuFromCart(menu_id: String) -> Array<CustomerCart> {
        let email = Auth.auth().currentUser?.email!
        let request: NSFetchRequest<CustomerCart> = CustomerCart.fetchRequest()
        let predicate = NSPredicate(format: "customer_email = %@ AND menu_id = %@", email!, menu_id)
        request.predicate = predicate

        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching cart data with \(error)")
            
            return []
        }
    }
    
    static func getCustomerCartItems() -> Array<CustomerCart> {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let email = Auth.auth().currentUser?.email!
        let request: NSFetchRequest<CustomerCart> = CustomerCart.fetchRequest()
        let predicate = NSPredicate(format: "customer_email CONTAINS %@", email!)
        request.predicate = predicate

        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching cart data with \(error)")
            
            return []
        }
    }
    
    func deleteAllData() {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerCart")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
           try context.execute(deleteRequest)
           try context.save()
       } catch {
           print ("There was an error")
       }
    }
    
    func filterItem(_ item: Array<CartItem>) -> Dictionary<CartItem, Int> {
        let mappedItems = item.map { ($0, Int(1)) }
        let counts = Dictionary(mappedItems, uniquingKeysWith: +)
        
        return counts
    }
}

protocol CartItemDelegate {
    func updateCartItems(items: [CartItem]);
}

protocol CartCellDelegate {
    func showAlert(title:String, message:String, tableCell: UITableViewCell);
}
