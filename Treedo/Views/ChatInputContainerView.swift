//
//  ChatInputContainerView.swift
//  Treedo
//
//  Created by Юрий Истомин on 05/07/2018.
//  Copyright © 2018 Yuri Istomin. All rights reserved.
//

import UIKit

class ChatInputContainerView: UIView, UITextFieldDelegate {
  
  var chatController: ChatController? {
    didSet {
      sendButton.addTarget(chatController, action: #selector(ChatController.handleSend), for: .touchUpInside)
      
      let tapGesture = UITapGestureRecognizer(target: chatController, action: #selector(ChatController.handleShowImagePicker))
      uploadImageView.addGestureRecognizer(tapGesture)
    }
  }
  
  lazy var inputTextField: UITextField = {
    let tf = UITextField()
    tf.tintColor = .white
    tf.textColor = .white
    tf.keyboardAppearance = UIKeyboardAppearance.dark
    tf.translatesAutoresizingMaskIntoConstraints = false
    tf.attributedPlaceholder = NSAttributedString(string: "Enter message...", attributes: [NSAttributedString.Key.foregroundColor : UIColor.color(r: 240, g: 240, b: 240)])
    tf.delegate = self
    return tf
  }()
  
  let sendButton: UIButton = {
    let sendButton = UIButton(type: .system)
    sendButton.setTitle("Send", for: .normal)
    sendButton.setTitleColor(UIColor.color(r: 255, g: 72, b: 100), for: .normal)
    sendButton.translatesAutoresizingMaskIntoConstraints = false
    return sendButton
  }()
  
  let uploadImageView: UIImageView = {
    let uploadImageView = UIImageView()
    uploadImageView.image = #imageLiteral(resourceName: "picture").withRenderingMode(.alwaysTemplate)
    uploadImageView.tintColor = .white
    uploadImageView.isUserInteractionEnabled = true
    uploadImageView.translatesAutoresizingMaskIntoConstraints = false
    return uploadImageView
  }()
  
  let separatorView: UIView = {
    let separatorView = UIView()
    separatorView.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
    separatorView.translatesAutoresizingMaskIntoConstraints = false
    return separatorView
  }()
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = UIColor.color(r: 15, g: 15, b: 30)
    
    addSubview(sendButton)
    sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
    sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    
    addSubview(uploadImageView)
    uploadImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
    uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    uploadImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
    uploadImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
    
    addSubview(inputTextField)
    inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
    inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 8).isActive = true
    inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    
    addSubview(separatorView)
    separatorView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    separatorView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    separatorView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    separatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    chatController?.perform(#selector(ChatController.handleSend))
//    textField.resignFirstResponder()
    return true
  }
}
