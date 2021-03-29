//
//  RegisterViewController.swift
//  Baratie
//
//  Created by Mickale Saturre on 3/26/21.
//

import UIKit

class RegisterViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!

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
    }
}
