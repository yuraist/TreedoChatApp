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
  
  private var ref: DatabaseReference!
  private(set) var users = [User]()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Add a cancel button
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
  
    // Register a custom table view cell
    tableView.register(UserCell.self, forCellReuseIdentifier: reuseIdentifier)
    
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
        let username = userDictionary["username"] as? String
        let email = userDictionary["email"] as? String
        let user = User(username: username, email: email)
        
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
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
    
    if users.count > 0 {
      let user = users[indexPath.row]
      cell.textLabel?.text = user.username
      cell.detailTextLabel?.text = user.email
    } else {
      cell.textLabel?.text = "No users found"
    }
    
    return cell
  }
}


class UserCell: UITableViewCell {
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}