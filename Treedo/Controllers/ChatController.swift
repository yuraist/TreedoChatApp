//
//  ChatController.swift
//  Treedo
//
//  Created by Юрий Истомин on 20/06/2018.
//  Copyright © 2018 Yuri Istomin. All rights reserved.
//

import UIKit
import Firebase

class ChatController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
  
  private var ref: DatabaseReference!
  
  var user: User? {
    didSet {
      navigationItem.title = user?.username
    }
  }
  
  private lazy var inputTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "Enter message..."
    tf.translatesAutoresizingMaskIntoConstraints = false
    tf.delegate = self
    return tf
  }()
  
  private let cellId = "cellId"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView?.backgroundColor = UIColor.white
    collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
    
    ref = Database.database().reference()
    setupInputComponents()
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    perform(#selector(handleSend))
    textField.resignFirstResponder()
    return true
  }
  
  private func setupInputComponents() {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(containerView)
    
    containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    let sendButton = UIButton(type: .system)
    sendButton.setTitle("Send", for: .normal)
    sendButton.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(sendButton)
    
    sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
    sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
    sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
    sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
    containerView.addSubview(inputTextField)
    
    inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
    inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 8).isActive = true
    inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
    
    let separatorView = UIView()
    separatorView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    separatorView.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(separatorView)
    
    separatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
    separatorView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
    separatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
    separatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
  }
  
  @objc private func handleSend() {
    let messagesRef = ref.child("messages")
    let childMessageRef = messagesRef.childByAutoId()
    
    guard let text = inputTextField.text, text != ""  else {
      return
    }
    if let toId = user?.id, let fromId = Auth.auth().currentUser?.uid {
      let timestamp: NSNumber = NSNumber(value: Int(Date().timeIntervalSince1970))
      let values = ["text": text,
                    "fromId": fromId,
                    "toId": toId,
                    "timestamp": timestamp] as [String : Any]
      childMessageRef.updateChildValues(values) { [unowned self] (error, ref) in
        if error != nil {
          print(error!)
          return
        }
        
        let userMessagesRef = self.ref.child("user-messages").child(fromId)
        let messageId = childMessageRef.key
        userMessagesRef.updateChildValues([messageId: 1])
        
        let receipientUserMessagesRef = self.ref.child("user-messages").child(toId)
        receipientUserMessagesRef.updateChildValues([messageId: 1])
      }
      inputTextField.text = ""
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 5
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
    cell.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width, height: 80)
  }
}
