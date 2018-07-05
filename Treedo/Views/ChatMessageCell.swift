//
//  ChatMessageCell.swift
//  Treedo
//
//  Created by Юрий Истомин on 28/06/2018.
//  Copyright © 2018 Yuri Istomin. All rights reserved.
//

import UIKit
import AVFoundation

class ChatMessageCell: UICollectionViewCell {
  
  var chatController: ChatController?
  var message: Message?
  
  let activityIndicatorView: UIActivityIndicatorView = {
    let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    aiv.translatesAutoresizingMaskIntoConstraints = false
    aiv.hidesWhenStopped = true
    return aiv
  }()
  
  lazy var playButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    let image = UIImage(named: "play-button")
    button.setImage(image, for: .normal)
    button.tintColor = .white
    button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
    return button
  }()
  
  let textView: UITextView = {
    let textView = UITextView()
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
  
  lazy var messageImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 16
    imageView.layer.masksToBounds = true
    imageView.contentMode = .scaleAspectFill
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoom(tapGesture:))))
    imageView.isUserInteractionEnabled = true
    return imageView
  }()
  
  let profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "user")
    imageView.layer.cornerRadius = 16
    imageView.layer.masksToBounds = true
    imageView.contentMode = .scaleAspectFill
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  var bubbleWidthAnchor: NSLayoutConstraint?
  var bubbleViewRightAnchor: NSLayoutConstraint?
  var bubbleViewLeftAnchor: NSLayoutConstraint?
  
  
  @objc func handleZoom(tapGesture tap: UITapGestureRecognizer) {
    if message?.videoUrl != nil {
      return
    }
    
    if let imageView = tap.view as? UIImageView {
      chatController?.performZoomIn(forStartingImageView: imageView)
    }
  }
  
  var player: AVPlayer?
  var playerLayer: AVPlayerLayer?
  
  @objc func handlePlay() {
    if let videoUrlString = message?.videoUrl, let url = URL(string: videoUrlString) {
      player = AVPlayer(url: url)
      
      playerLayer = AVPlayerLayer(player: player)
      playerLayer?.frame = bubbleView.bounds
      playerLayer?.masksToBounds = true
      bubbleView.layer.addSublayer(playerLayer!)
      
      player?.play()
      activityIndicatorView.startAnimating()
      playButton.isHidden = true
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    playerLayer?.removeFromSuperlayer()
    player?.pause()
    activityIndicatorView.stopAnimating()
  }
  
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
    
    bubbleView.addSubview(messageImageView)
    messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
    messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
    messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
    messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
    
    bubbleView.addSubview(playButton)
    
    playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
    playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
    playButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
    playButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
    
    bubbleView.addSubview(activityIndicatorView)
    
    activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
    activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
    activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
    activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
    textView.topAnchor.constraint(equalTo: topAnchor, constant: 1.5).isActive = true
    textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
    textView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
