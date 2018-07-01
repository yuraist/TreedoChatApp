//
//  ChatController.swift
//  Treedo
//
//  Created by Юрий Истомин on 20/06/2018.
//  Copyright © 2018 Yuri Istomin. All rights reserved.
//

import UIKit
import Firebase

class ChatController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
  
  private var ref: DatabaseReference!
  
  static let greenColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
  static let grayColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
  
  var user: User? {
    didSet {
      navigationItem.title = user?.username
      observeMessages()
    }
  }
  
  var messages = [Message]()
  
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
    
    collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    collectionView?.showsVerticalScrollIndicator = false
    collectionView?.backgroundColor = UIColor.white
    collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
    collectionView?.keyboardDismissMode = .interactive
    
    let hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(handleHideKeyboard))
    collectionView?.addGestureRecognizer(hideKeyboardGesture)
    
    ref = Database.database().reference()
    
//    setupInputComponents()
    setupKeyboardObservers()
  }
  
  lazy var inputContainerView: UIView = {
    let containerView = UIView()
    containerView.backgroundColor = .white
    containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
    
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
    
    return containerView
  }()
  
  override var canBecomeFirstResponder: Bool {
    return true
  }
  
  override var inputAccessoryView: UIView? {
    return inputContainerView
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    NotificationCenter.default.removeObserver(self)
  }
  
  func setupKeyboardObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  @objc func handleKeyboardWillShow(notification: Notification) {
    let keyboardFrameHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
    let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
    
    inputContainerViewBottomAnchor?.constant -= keyboardFrameHeight
    UIView.animate(withDuration: keyboardAnimationDuration) {
      self.view.layoutIfNeeded()
    }
  }
  
  @objc func handleKeyboardWillHide(notification: NSNotification) {
    let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
    
    inputContainerViewBottomAnchor?.constant = 0
    UIView.animate(withDuration: keyboardAnimationDuration) {
      self.view.layoutIfNeeded()
    }
  }
  
  @objc func handleHideKeyboard() {
    inputTextField.resignFirstResponder()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    collectionView?.collectionViewLayout.invalidateLayout()
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    perform(#selector(handleSend))
    textField.resignFirstResponder()
    return true
  }
  
  private var inputContainerViewBottomAnchor: NSLayoutConstraint?
  
  private func setupInputComponents() {
    let containerView = UIView()
    containerView.backgroundColor = .white
    containerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(containerView)
    
    containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    inputContainerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    inputContainerViewBottomAnchor?.isActive = true
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
  
  func observeMessages() {
    guard let uid = Auth.auth().currentUser?.uid else {
      return
    }
    
    let userMessagesRef = Database.database().reference().child("user-messages").child(uid)
    userMessagesRef.observe(.childAdded, with: { [weak self] snapshot in
      let messageId = snapshot.key
      let messagesRef = self?.ref.child("messages").child(messageId)
      messagesRef?.observeSingleEvent(of: .value, with: { snapshot in
        guard let dictionary = snapshot.value as? [String: AnyObject] else {
          return
        }
        
        let message = Message(withDictinary: dictionary)
        if message.chatPartnerId() == self?.user?.id {
          self?.messages.append(message)
          DispatchQueue.main.async {
            self?.collectionView?.reloadData()
          }
        }
      })
    })
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return messages.count > 0 ? messages.count : 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
    
    if messages.count > 0 {
      let message = messages[indexPath.item]
      setupCell(cell, withMessage: message)
    }
    
    return cell
  }
  
  private func setupCell(_ cell: ChatMessageCell, withMessage message: Message) {
    
    if let messageText = message.text {
      cell.textView.text = messageText
      cell.bubbleWidthAnchor?.constant = estimateFrame(forText: messageText).width + 32
    }
    
    if message.fromId == Auth.auth().currentUser?.uid {
      cell.bubbleView.backgroundColor = ChatController.greenColor
      cell.textView.textColor = .white
      cell.bubbleViewLeftAnchor?.isActive = false
      cell.bubbleViewRightAnchor?.isActive = true
      cell.profileImageView.isHidden = true
    } else {
      
      if let profileImageUrl = user?.profileImageURL {
        cell.profileImageView.loadImageUsingCache(withUrlString: profileImageUrl)
      }
      
      cell.bubbleView.backgroundColor = ChatController.grayColor
      cell.textView.textColor = .black
      cell.bubbleViewLeftAnchor?.isActive = true
      cell.bubbleViewRightAnchor?.isActive = false
      cell.profileImageView.isHidden = false
    }
  }
  
  private func estimateFrame(forText text: String) -> CGRect {
    let size = CGSize(width: 200, height: 1000)
    let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
    return NSString(string: text).boundingRect(with: size, options: options, attributes: [kCTFontAttributeName as NSAttributedString.Key: UIFont.systemFont(ofSize: 16)], context: nil)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    var height: CGFloat = 80
    if messages.count > 0 {
      if let text = messages[indexPath.item].text {
        height = estimateFrame(forText: text).height
      }
    }
    return CGSize(width: view.frame.width, height: height + 20)
  }
}
