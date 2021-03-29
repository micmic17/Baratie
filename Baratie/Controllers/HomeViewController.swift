//
//  HomeViewController.swift
//  Baratie
//
//  Created by Mickale Saturre on 3/29/21.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    let btn = BadgedButtonItem(with: UIImage(systemName: "cart"))
    var counter = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "background_color")
        navigationItem.hidesBackButton = true
        title = "Baratie"
        logoutButton.title = "Logout"
        
        // Create cart bar button item
        createCart()
    }

    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }

    }

    func cartPressed() {
        counter += 1

        btn.setBadge(with: counter)
    }
    
    func createCart() {
        btn.badgeAnimation = true
        btn.badgeSize = .large
        self.navigationItem.leftBarButtonItem = btn
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "text_color")
        
        btn.tapAction = {
            self.cartPressed()
        }
    }
}
