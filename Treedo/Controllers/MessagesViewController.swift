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
  
  var messages = [Message]()
  var messagesDictionary = [String: Message]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Setup a Firebase database reference
    ref = Database.database().reference()
    
    // Setup a logout button
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showNewMessageController))
    
    // Setup table view
    tableView.register(UserCell.self, forCellReuseIdentifier: "cellId")
    tableView.allowsMultipleSelectionDuringEditing = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    fetchUserAndSetupNavigationBar()
    //    observeMessages()
    observeUserMessages()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    fetchUserAndSetupNavigationBar()
  }
  
  // Setup user data
  func fetchUserAndSetupNavigationBar() {
    // Check authentication
    if let uid = Auth.auth().currentUser?.uid {
      // Update username in the navigation bar title
      ref.child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
        if let userDataDict = snapshot.value as? [String: AnyObject] {
          let user = User(withDictionary: userDataDict)
          self.setupNavBar(withUser: user)
        }
      }
    } else {
      // Show the login screen
      perform(#selector(handleLogout))
    }
  }
  
  // Get last messages
  func observeMessages() {
    messages = []
    ref.child("messages").observe(.childAdded) { [weak self] snapshot in
      if let dictionary = snapshot.value as? [String: AnyObject] {
        let message = Message(withDictinary: dictionary)
        if let toId = message.toId {
          self?.messagesDictionary[toId] = message
          
          self?.messages = Array(self!.messagesDictionary.values)
          self?.messages.sort(by: { message1, message2 -> Bool in
            return message1.timestamp!.intValue > message2.timestamp!.intValue
          })
        }
        
        DispatchQueue.main.async {
          self?.tableView.reloadData()
        }
      }
    }
  }
  
  var timer: Timer?
  
  func observeUserMessages() {
    messages.removeAll()
    messagesDictionary.removeAll()
    guard let uid = Auth.auth().currentUser?.uid else {
      return
    }
    
    let userRef = ref.child("user-messages").child(uid)
    userRef.observe(.childAdded) { snapshot in
      
      let userId = snapshot.key
      self.ref.child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
        let messageId = snapshot.key
        self.fetchMessage(withId: messageId)
      })
    }
    
    userRef.observe(.childRemoved) { (snapshot) in
      self.messagesDictionary.removeValue(forKey: snapshot.key)
      self.attemptReloadOfTable()
    }
  }
  
  private func fetchMessage(withId messageId: String) {
    let messageRef = ref.child("messages").child(messageId)
    messageRef.observeSingleEvent(of: .value, with: { snapshot in
      if let dictionary = snapshot.value as? [String: AnyObject] {
        let message = Message(withDictinary: dictionary)
        if let chatPartnerId = message.chatPartnerId() {
          self.messagesDictionary[chatPartnerId] = message
        }
        self.attemptReloadOfTable()
      }
    })
  }
  
  private func attemptReloadOfTable() {
    messages = Array(messagesDictionary.values)
    messages.sort(by: { message1, message2 -> Bool in
      return message1.timestamp!.intValue > message2.timestamp!.intValue
    })
    
    timer?.invalidate()
    timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.reloadTable), userInfo: nil, repeats: false)
  }
  
  @objc func reloadTable() {
    DispatchQueue.main.async {
      self.tableView.reloadData()
    }
  }
  
  func setupNavBar(withUser user: User) {
    let titleView = UIView()
    titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
    
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    titleView.addSubview(containerView)
    
    let profileImageView = UIImageView()
    profileImageView.translatesAutoresizingMaskIntoConstraints = false
    profileImageView.contentMode = .scaleAspectFill
    profileImageView.layer.cornerRadius = 18
    profileImageView.clipsToBounds = true
    
    if let profileImageUrl = user.profileImageURL {
      profileImageView.loadImageUsingCache(withUrlString: profileImageUrl)
    }
    
    containerView.addSubview(profileImageView)
    
    // Add profile image view constraints
    profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
    profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    profileImageView.widthAnchor.constraint(equalToConstant: 36).isActive = true
    profileImageView.heightAnchor.constraint(equalToConstant: 36).isActive = true
    
    let usernameLabel = UILabel()
    usernameLabel.text = user.username
    usernameLabel.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(usernameLabel)
    
    usernameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
    usernameLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
    usernameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
    usernameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
    
    containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
    containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
    containerView.widthAnchor.constraint(lessThanOrEqualTo: titleView.widthAnchor).isActive = true
    
    navigationItem.titleView = titleView
    if #available(iOS 11.0, *) {
      self.navigationController?.navigationBar.prefersLargeTitles = false
      self.navigationItem.largeTitleDisplayMode = .automatic
      var width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width - 15.0
      let height = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).height
      
      let screenSize: CGRect = UIScreen.main.bounds
      let windowWidth = screenSize.width
      width = windowWidth * 0.55
      
      let widthConstraint = titleView.widthAnchor.constraint(equalToConstant: width)
      let heightConstraint = titleView.heightAnchor.constraint(equalToConstant: height)
      
      heightConstraint.isActive = true
      widthConstraint.isActive = true
    }
  }
  
  func showChatController(forUser user: User) {
    let chatController = ChatController(collectionViewLayout: UICollectionViewFlowLayout())
    chatController.user = user
    navigationController?.pushViewController(chatController, animated: true)
  }
  
  @objc private func showNewMessageController() {
    let newMessageController = NewMessageController()
    newMessageController.messagesController = self
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
  
  // MARK: - Table view methods
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count > 0 ? messages.count : 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! UserCell
    if messages.count > 0 {
      cell.message = messages[indexPath.row]
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 72
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if messages.count > 0 {
      let message = messages[indexPath.row]
      
      guard let chatPartnerId = message.chatPartnerId() else {
        return
      }
      
      let userRef = ref.child("users").child(chatPartnerId)
      userRef.observeSingleEvent(of: .value) { [unowned self] snapshot in
        guard let dictionary = snapshot.value as? [String: AnyObject] else {
          return
        }
        
        let user = User(withDictionary: dictionary, andUID: chatPartnerId)
        self.showChatController(forUser: user)
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    guard let uid = Auth.auth().currentUser?.uid else {
      return
    }
    
    let message = messages[indexPath.row]
    
    if let chatPartnerId = message.chatPartnerId() {
      Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue { (err, ref) in
        if err != nil {
          print("Failed to delete message:", err!)
          return
        }
        
        self.messagesDictionary.removeValue(forKey: chatPartnerId)
        self.attemptReloadOfTable()
      }
    }
    
  }
}

