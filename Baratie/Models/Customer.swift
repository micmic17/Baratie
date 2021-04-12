//
//  Customer.swift
//  Baratie
//
//  Created by Mickale Saturre on 4/8/21.
//
import UIKit
import CoreData
import Firebase

struct Customer {
    let firstname: String
    let lastname: String
    let email: String
    let address: String
    let password: String
    let currentDate: String
    var customerData = [Customers]()
    static var request: NSFetchRequest<Customers> = Customers.fetchRequest()
    static var email = Auth.auth().currentUser?.email!
    
    mutating func register() -> Bool {
        let customer = Customers(context: context)
        customer.firstname = firstname
        customer.lastname = lastname
        customer.password = password
        customer.email = email
        customer.address = address
        customer.created_at = currentDate
        customer.updated_at = currentDate
        self.customerData.append(customer)
        return self.saveCustomerData()
    }
    
    func saveCustomerData() -> Bool {
        do {
            try context.save()
            
            return true
        } catch {
            print("Error saving customer data with \(error)")
            
            return false
        }
    }
    
    static func getCustoomerData() -> Array<Customers> {
        request.predicate = NSPredicate.init(format: "email CONTAINS %@", loginEamil!)

        do {
            return try context.fetch(Customer.request)
        } catch {
            print("Error fetching cart data with \(error)")
    
            return []
        }
    }
}
