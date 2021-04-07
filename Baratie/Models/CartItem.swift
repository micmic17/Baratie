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
let request: NSFetchRequest<CustomerCart> = CustomerCart.fetchRequest()
let email = Auth.auth().currentUser?.email!
var cartData = [CustomerCart]()

struct CartItem: Hashable {
    var id: String
    var price: Double
    var name: String
    var image: String
    var quantity: Int16
    
    mutating func addToCart() {
        let cart = CustomerCart(context: context)
        cart.customer_email = Auth.auth().currentUser?.email
        cart.menu_id = id
        cart.menu_name = name
        cart.menu_image = image
        cart.original_price = price
        cart.quantity = 1
        cartData.append(cart)
        print(self.saveCartData())
    }

    func createFetchRequest() -> NSFetchRequest<CustomerCart> {
        return NSFetchRequest<CustomerCart>(entityName: "CustomerCart")
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
        let predicate = NSPredicate(format: "customer_email = %@ AND menu_id = %@", email!, menu_id)
        request.predicate = predicate

        return contextFetch()
    }

    func deleteCartItems(_ menu_id: String) -> Bool {
        request.predicate = NSPredicate.init(format: "customer_email = %@ AND menu_id = %@", email!, menu_id)
        let objects = contextFetch()

        for object in objects {
            object.quantity = 0
        }
        
        return saveCartData()
    }
    
    func filterItem(_ item: Array<CartItem>) -> Dictionary<CartItem, Int> {
        let mappedItems = item.map { ($0, Int(1)) }
        let counts = Dictionary(mappedItems, uniquingKeysWith: +)
        
        return counts
    }
}

protocol CartItemDelegate {
    func updateCartItems(items: [CartItem], deletedItem: [CartItem]);
}

protocol CartCellDelegate {
    func showAlert(title:String, message:String, tableCell: UITableViewCell);
}

func getCustomerCartItems() -> Array<CustomerCart> {
    let predicate = NSPredicate(format: "customer_email CONTAINS %@ AND  quantity > 0", email!)
    request.predicate = predicate
    
    return contextFetch()
}

func contextFetch() -> Array<CustomerCart> {
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
