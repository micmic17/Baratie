//
//  RegisterCustomer.swift
//  Baratie
//
//  Created by Mickale Saturre on 3/29/21.
//
import UIKit
import CoreData

struct RegisterCustomer {
    let firstname: String
    let lastname: String
    let email: String
    let address: String
    let password: String
    let currentDate: String
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    var customerData = [Customers]()
    
    mutating func register() -> Bool {
        let customer = Customers(context: self.context)
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
}
