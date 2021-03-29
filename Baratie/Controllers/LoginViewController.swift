//
//  LoginViewController.swift
//  Baratie
//
//  Created by Mickale Saturre on 3/26/21.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self

        customView(imageView, "Login")
        customTextField(emailTextField, "Email")
        customTextField(passwordTextField, "Password")
        customButton(loginButton)
    }
    
    @IBAction func loginTextFieldChanges(_ sender: UITextField) {
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { authUser, error in
                if let e = error {
                    print(e)
                } else {
                    self.performSegue(withIdentifier: "LoginToHome", sender: self)
                }
            }
        }
    }
}
