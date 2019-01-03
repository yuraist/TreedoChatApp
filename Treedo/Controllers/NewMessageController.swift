//
//  NewMessageController.swift
//  Treedo
//
//  Created by Юрий Истомин on 17/06/2018.
//  Copyright © 2018 Yuri Istomin. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
  
  let reuseIdentifier = "cellId"
  
  var messagesController: MessagesViewController?
  
  private var ref: DatabaseReference!
  private(set) var users = [User]()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.barTintColor = UIColor.color(r: 15, g: 15, b: 30)
    navigationController?.navigationBar.tintColor = UIColor.white
    navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    
    // Add a cancel button
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
    navigationItem.title = "New Message"
    // Register a custom table view cell
    tableView.register(UserCell.self, forCellReuseIdentifier: reuseIdentifier)
    
    tableView.backgroundColor = UIColor.color(r: 32, g: 34, b: 49)
    
    // Initiate the firebase database reference and fetch users
    ref = Database.database().reference()
    fetchUsers()
  }
  
  @objc private func handleCancel() {
    dismiss(animated: true, completion: nil)
  }
  
  private func fetchUsers() {
    ref.child("users").observe(.childAdded) { (snapshot) in
      if let userDictionary = snapshot.value as? [String: AnyObject] {
        
        // Get user data from the firebase database
        var user = User(withDictionary: userDictionary)
        user.id = snapshot.key
        // Append a user into the users array
        self.users.append(user)
        
        // Update the table view
        DispatchQueue.main.async {
          self.tableView.reloadData()
        }
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count > 0 ? users.count : 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! UserCell
    
    if users.count > 0 {
      let user = users[indexPath.row]
      cell.textLabel?.text = user.username
      cell.detailTextLabel?.text = user.email
      
      if let profileImageUrl = user.profileImageURL {
        cell.profileImageView.loadImageUsingCache(withUrlString: profileImageUrl)
      }
      
    } else {
      cell.textLabel?.text = "No users found"
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 72
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    dismiss(animated: true) { [unowned self] in
      let user = self.users[indexPath.row]
      self.messagesController?.showChatController(forUser: user)
    }
  }
}

