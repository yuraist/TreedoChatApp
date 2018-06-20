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
    
    fetchUserAndSetupNavigationBar()
  }
  
  // Setup user data
  func fetchUserAndSetupNavigationBar() {
    // Check authentication
    if let uid = Auth.auth().currentUser?.uid {
      // Update username in the navigation bar title
      ref.child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
        if let userDataDict = snapshot.value as? [String: AnyObject] {
          let username = userDataDict["username"] as? String
          let email = userDataDict["email"] as? String
          let profileImageUrl = userDataDict["profileImageUrl"] as? String
          
          let user = User(username: username, email: email, profileImageURL: profileImageUrl)
          self.setupNavBar(withUser: user)
        }
      }
    } else {
      // Show the login screen
      perform(#selector(handleLogout))
    }
  }
  
  func setupNavBar(withUser user: User) {
    let titleView = UIView()
    titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
    
    let profileImageView = UIImageView()
    profileImageView.translatesAutoresizingMaskIntoConstraints = false
    profileImageView.contentMode = .scaleAspectFill
    profileImageView.layer.cornerRadius = 18
    profileImageView.clipsToBounds = true
    
    if let profileImageUrl = user.profileImageURL {
      profileImageView.loadImageUsingCache(withUrlString: profileImageUrl)
    }
    
    titleView.addSubview(profileImageView)
    
    // Add profile image view constraints
    profileImageView.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
    profileImageView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
    profileImageView.widthAnchor.constraint(equalToConstant: 36).isActive = true
    profileImageView.heightAnchor.constraint(equalToConstant: 36).isActive = true
    
    let usernameLabel = UILabel()
    usernameLabel.text = user.username
    usernameLabel.translatesAutoresizingMaskIntoConstraints = false
    
    titleView.addSubview(usernameLabel)
    
    usernameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
    usernameLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
    usernameLabel.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true
    usernameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
    
    navigationItem.titleView = titleView
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
    loginViewController.messagesViewController = self
    present(loginViewController, animated: true, completion: nil)
  }
  
}

