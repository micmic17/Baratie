//
//  RegisterViewController.swift
//  Baratie
//
//  Created by Mickale Saturre on 3/26/21.
//

import UIKit
import Firebase
import CoreData


class RegisterViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var customerData = [Customers]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

    override func viewDidLoad() {
        super.viewDidLoad()
        customView(imageView, "Register")
        customTextField(firstNameTextField, "Firstname")
        customTextField(lastNameTextField, "Lastname")
        customTextField(emailTextField, "Email")
        customTextField(addressTextField, "Address")
        customTextField(passwordTextField, "Password")
        customTextField(confirmPasswordTextField, "Confirm Password")
        customButton(registerButton)
    }

    @IBAction func formTextFieldChanged(_ sender: Any) {
    }

    @IBAction func registerButtonPressed(_ sender: Any) {
        if let email = emailTextField.text,
           let password = passwordTextField.text,
           let firstname = firstNameTextField.text,
           let lastname = lastNameTextField.text,
           let cpassword = confirmPasswordTextField.text {
            
            let customer = Customers(context: self.context)
            customer.firstname = firstname
            customer.lastname = lastname
            customer.password = password
            customer.email = email
            customer.address = addressTextField.text
            customer.created_at = getCurrentDateTime()
            customer.updated_at = getCurrentDateTime()
            
            self.customerData.append(customer)
            self.saveCustomerData()
            
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e)
                } else {
                    self.performSegue(withIdentifier: "RegisterToHome", sender: self)
                }
            }
        }
    }
    
    func saveCustomerData() {
        do {
            try context.save()
        } catch {
            print("Error saving customer data with \(error)")
        }
    }
}
