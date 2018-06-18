//
//  ViewController.swift
//  Treedo
//
//  Created by Юрий Истомин on 12/06/2018.
//  Copyright © 2018 Yuri Istomin. All rights reserved.
//

import UIKit
import Firebase

class MessagesViewController: UITableViewController {
  
  private var ref: DatabaseReference!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Setup a Firebase database reference
    ref = Database.database().reference()
    
    // Setup a logout button
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newMessage))
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    setupUser()
  }
  
  // Setup user data
  private func setupUser() {
    // Check authentication
    if let uid = Auth.auth().currentUser?.uid {
      // Update username in the navigation bar title
      ref.child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
        if let userDataDict = snapshot.value as? [String: AnyObject] {
          self.navigationItem.title = userDataDict["username"] as? String
        }
      }
    } else {
      // Show the login screen
      perform(#selector(handleLogout))
    }
  }
  
  @objc private func newMessage() {
    let newMessageController = NewMessageController()
    present(UINavigationController(rootViewController: newMessageController), animated: true, completion: nil)
  }
  
  @objc private func handleLogout() {
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

