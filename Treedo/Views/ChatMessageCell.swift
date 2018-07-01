//
//  ChatMessageCell.swift
//  Treedo
//
//  Created by Юрий Истомин on 28/06/2018.
//  Copyright © 2018 Yuri Istomin. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
  
  let textView: UITextView = {
    let textView = UITextView()
    textView.text = "Sample text for now"
    textView.font = UIFont.systemFont(ofSize: 16)
    textView.isEditable = false
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.backgroundColor = .clear
    textView.textColor = .white
    return textView
  }()
  
  let bubbleView: UIView = {
    let view = UIView()
    view.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
    view.layer.cornerRadius = 18
    view.layer.masksToBounds = true
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  let profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "user")
    imageView.layer.cornerRadius = 16
    imageView.layer.masksToBounds = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  var bubbleWidthAnchor: NSLayoutConstraint?
  var bubbleViewRightAnchor: NSLayoutConstraint?
  var bubbleViewLeftAnchor: NSLayoutConstraint?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    addSubview(bubbleView)
    addSubview(textView)
    addSubview(profileImageView)
    
    profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
    profileImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
    profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
    
    bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8)
    bubbleViewRightAnchor?.isActive = true
    
    bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
    
    bubbleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
    bubbleWidthAnchor?.isActive = true
    bubbleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    
    textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
    textView.topAnchor.constraint(equalTo: topAnchor, constant: 1.5).isActive = true
    textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
    textView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
