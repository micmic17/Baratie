//
//  ViewController.swift
//  Baratie
//
//  Created by Mickale Saturre on 3/26/21.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        if !isUserLoggedIn() {
            customView(imageView, "")
            customButton(loginButton)
            customButton(registerButton)
        } else {
            performSegue(withIdentifier: "RootToHome", sender: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        super.viewWillDisappear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
}

extension UIViewController {
    func customButton(_ button: UIButton) {
        button.tintColor = UIColor(named: "text_color")
        button.titleLabel?.font = .systemFont(ofSize: 30)
        button.layer.cornerRadius = button.frame.size.height / 2
        button.layer.borderWidth = 2
        button.layer.borderColor = CGColor(red: 0.80, green: 0.66, blue: 0.54, alpha: 1.00)
    }
    
    func customView(_ imageView: UIImageView, _ title: String) {
        view.backgroundColor = UIColor(named: "background_color")
        imageView.image = UIImage(named: "baratie_logo")
        self.navigationItem.title = title
    }
    
    func customTextField(_ textfield: UITextField, _ placeholder: String) {
        textfield.setPadding()
        textfield.customBottomBorder()
        textfield.customDesign()
        textfield.attributedPlaceholder = NSAttributedString(string: "\(placeholder)",
                                                                  attributes: [
                                                                    NSAttributedString.Key.foregroundColor: UIColor(named: "text_color") ?? .black])
    }
    
    func getCurrentDateTime() -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = Date()
        
        return dateFormatter.string(from: date)
    }
    
    func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
}

extension UITextField {
    func customDesign() {
        self.textColor = UIColor(named: "text_color")
        self.tintColor = UIColor(named: "text_color")
        self.font = .systemFont(ofSize: 30)
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        self.backgroundColor = UIColor(named: "background_color")
    }

    func setPadding() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func customBottomBorder() {
        self.layer.shadowColor = CGColor(red: 0.80, green: 0.66, blue: 0.54, alpha: 1.00)
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}
