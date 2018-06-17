//
//  ViewController.swift
//  Treedo
//
//  Created by Юрий Истомин on 12/06/2018.
//  Copyright © 2018 Yuri Istomin. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Setup a logout button
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    
    // User is not logged in
    if Auth.auth().currentUser?.uid == nil {
      perform(#selector(handleLogout))
    }
  }
  
  @objc func handleLogout() {
    // Sign out from Firebase
    do {
      try Auth.auth().signOut()
    } catch let logoutError {
      print(logoutError)
    }
    
    // Show the login view controller
    let loginViewController = LoginViewController()
    present(loginViewController, animated: true, completion: nil)
  }
  
}

