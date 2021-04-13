//
//  CustomerOrder.swift
//  Baratie
//
//  Created by Mickale Saturre on 4/12/21.
//

import Foundation
import CoreData
import Firebase

class CustomerOrder {
    var orderData = [Order]()
    func createOrder(_ items: [CartItem] ,_ totalAmount: Double, _ isDone: Bool) {
        let order = Order(context: context)
        order.customer_email = loginEamil
        order.is_done = isDone
        order.total_amount = totalAmount
        order.order_id = randomString(length: 10)
        orderData.append(order)
        storeOrderRecord(order)
        
        DispatchQueue.main.async {
            _ = saveCartData()
            
            for item in items {
                CartItem.request.predicate = NSPredicate.init(format: "customer_email = %@ AND menu_id = %@ AND order_id == nil", loginEamil!, item.id)
                
                let cartItems = CartItem.fetchCustomerCart()
                
                for cart in cartItems {
                    cart.order_id = order.order_id
                }
                
                _ = saveCartData()
            }
        }
    }
    
    
    func storeOrderRecord(_ order: Order) {
        db.collection("orders").document(order.order_id!).setData([
            "customer_email": order.customer_email!,
            "is_done": order.is_done,
            "total_amount": order.total_amount
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    // Generating Random String
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
