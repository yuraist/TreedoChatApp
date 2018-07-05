//
//  ChatController.swift
//  Treedo
//
//  Created by Юрий Истомин on 20/06/2018.
//  Copyright © 2018 Yuri Istomin. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
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
  
  lazy var inputContainerView: ChatInputContainerView = {
    let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
    chatInputContainerView.chatController = self
    return chatInputContainerView
  }()
  
  @objc func handleShowImagePicker() {
    let imagePickerController = UIImagePickerController()
    imagePickerController.allowsEditing = true
    imagePickerController.delegate = self
    imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
    present(imagePickerController, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
      handleVideoSelected(forUrl: videoUrl)
    } else {
      handleImageSelected(forInfo: info)
    }
    
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
  
  private func handleVideoSelected(forUrl fileUrl: URL) {
    let filename = UUID().uuidString + ".mov"
    let ref = Storage.storage().reference().child("message_movies").child(filename)
    let uploadTask = ref.putFile(from: fileUrl, metadata: nil) { metadata, error in
      if error != nil {
        print(error!)
        return
      }
      
      ref.downloadURL(completion: { (url, err) in
        if err != nil {
          print(err!)
          return
        }
        
        if let videoUrl = url?.absoluteString {
          
          if let thumbnailImage = self.thumbnailImage(forFileUrl: fileUrl) {
            self.uploadToFirebaseStorage(usingImage: thumbnailImage, withCompletion: { (imageUrl) in
              let properties: [String: Any] = ["imageUrl": imageUrl,
                                               "videoUrl": videoUrl,
                                               "imageWidth": thumbnailImage.size.width,
                                               "imageHeight": thumbnailImage.size.height]
              self.sendMessages(withProperties: properties)
            })
          }
        }
      })
    }
    
    uploadTask.observe(.progress) { snapshot in
      if let completedUnitCount = snapshot.progress?.completedUnitCount {
        self.navigationItem.title = String(completedUnitCount)
      }
    }
    
    uploadTask.observe(.success) { snapshot in
      self.navigationItem.title = self.user?.username
    }
  }
  
  private func handleImageSelected(forInfo info: [String: Any]) {
    var selectedImageFromPicker: UIImage?
    
    if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
      selectedImageFromPicker = editedImage
    } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
      selectedImageFromPicker = originalImage
    }
    
    if let selectedImage = selectedImageFromPicker {
      uploadToFirebaseStorage(usingImage: selectedImage) { imageUrl in
        self.sendMessage(withImageUrlString: imageUrl, image: selectedImage)
      }
    }
  }
  
  private func uploadToFirebaseStorage(usingImage image: UIImage, withCompletion completion: @escaping (_ imageUrl: String)->()) {
    let imageName = UUID().uuidString
    let ref = Storage.storage().reference().child("message_images").child(imageName)
    
    if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
      ref.putData(uploadData, metadata: nil) { metadata, error in
        if error != nil {
          print(error!)
          return
        }
        ref.downloadURL(completion: { (url, err) in
          if err != nil {
            print(err!)
            return
          }
          
          if let imageUrl = url?.absoluteString {
            completion(imageUrl)
          }
        })
      }
    }
  }
  
  private func thumbnailImage(forFileUrl fileUrl: URL) -> UIImage? {
    let asset = AVAsset(url: fileUrl)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    
    do {
      let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
      return UIImage(cgImage: thumbnailCGImage)
    } catch let err {
      print(err)
    }
    
    return nil
  }
  
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
    NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
  }
  
  @objc func handleKeyboardDidShow(notification: Notification) {
    if messages.count > 0 {
      let indexPath = IndexPath(item: messages.count - 1, section: 0)
      collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
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
    inputContainerView.inputTextField.resignFirstResponder()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    collectionView?.collectionViewLayout.invalidateLayout()
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    perform(#selector(handleSend))
//    textField.resignFirstResponder()
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
//    containerView.addSubview(inputTextField)
//
//    inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
//    inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//    inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 8).isActive = true
//    inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
    
    let separatorView = UIView()
    separatorView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    separatorView.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(separatorView)
    
    separatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
    separatorView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
    separatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
    separatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
  }
  
  @objc func handleSend() {
    guard let text = inputContainerView.inputTextField.text, text != "" else {
      return
    }
    
    let properties: [String: Any] = ["text": text]
    sendMessages(withProperties: properties)
  }
  
  private func sendMessage(withImageUrlString imageUrl: String, image: UIImage) {
    
    let properties: [String: Any] = ["imageUrl": imageUrl,
                                     "imageWidth": image.size.width,
                                     "imageHeight": image.size.height]
    
    sendMessages(withProperties: properties)
  }
  
  private func sendMessages(withProperties properties: [String: Any]) {
    let messagesRef = ref.child("messages")
    let childMessageRef = messagesRef.childByAutoId()
    
    if let toId = user?.id, let fromId = Auth.auth().currentUser?.uid {
      let timestamp: NSNumber = NSNumber(value: Int(Date().timeIntervalSince1970))
      
      var values: [String: Any] = ["fromId": fromId,
                                   "toId": toId,
                                   "timestamp": timestamp]
      
      for (key, value) in properties {
        values[key] = value
      }
      
      childMessageRef.updateChildValues(values) { [unowned self] (error, ref) in
        if error != nil {
          print(error!)
          return
        }
        
        let userMessagesRef = self.ref.child("user-messages").child(fromId).child(toId)
        let messageId = childMessageRef.key
        userMessagesRef.updateChildValues([messageId: 1])
        
        let receipientUserMessagesRef = self.ref.child("user-messages").child(toId).child(fromId)
        receipientUserMessagesRef.updateChildValues([messageId: 1])
      }
      inputContainerView.inputTextField.text = ""
    }
  }
  
  func observeMessages() {
    guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else {
      return
    }
    
    let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
    userMessagesRef.observe(.childAdded, with: { snapshot in
      let messageId = snapshot.key
      let messagesRef = self.ref.child("messages").child(messageId)
      messagesRef.observeSingleEvent(of: .value, with: { snapshot in
        guard let dictionary = snapshot.value as? [String: AnyObject] else {
          return
        }
        
        let message = Message(withDictinary: dictionary)
        if message.chatPartnerId() == self.user?.id {
          self.messages.append(message)
          DispatchQueue.main.async {
            self.collectionView?.reloadData()
            
            // Scroll to the last index
            if self.messages.count > 0 {
              let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
              self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
            }
          }
        }
      })
    })
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return messages.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
    
    cell.chatController = self
    
    if messages.count > 0 {
      let message = messages[indexPath.item]
      setupCell(cell, withMessage: message)
    }
    
    return cell
  }
  
  private func setupCell(_ cell: ChatMessageCell, withMessage message: Message) {
    
    cell.message = message
    
    if let messageText = message.text {
      cell.textView.text = messageText
      cell.bubbleWidthAnchor?.constant = estimateFrame(forText: messageText).width + 32
      cell.textView.isHidden = false
    } else if let messageImageUrl = message.imageUrl {
      cell.bubbleWidthAnchor?.constant = 200
      cell.messageImageView.loadImageUsingCache(withUrlString: messageImageUrl)
      cell.messageImageView.isHidden = false
      cell.bubbleView.backgroundColor = .clear
      cell.textView.isHidden = true
    } else {
      cell.messageImageView.isHidden = true
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
    
    // Show the play button if there is a video
    cell.playButton.isHidden = message.videoUrl == nil
  }
  
  private func estimateFrame(forText text: String) -> CGRect {
    let size = CGSize(width: 200, height: 1000)
    let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
    return NSString(string: text).boundingRect(with: size, options: options, attributes: [kCTFontAttributeName as NSAttributedString.Key: UIFont.systemFont(ofSize: 16)], context: nil)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    var height: CGFloat = 80
    if messages.count > 0 {
      let message = messages[indexPath.item]
      if let text = message.text {
        height = estimateFrame(forText: text).height
      } else if let imageWidth = message.imageWidth, let imageHeight = message.imageHeight {
        
        let width: CGFloat = 200
        height = imageHeight * width / imageWidth
      }
    }
    return CGSize(width: view.frame.width, height: height + 20)
  }
  
  private var startingFrame: CGRect?
  private var blackBackgroundView: UIView?
  private var startingImageView: UIImageView?
  
  func performZoomIn(forStartingImageView imageView: UIImageView) {
    startingImageView = imageView
    startingImageView?.isHidden = true
    startingFrame = imageView.superview?.convert(imageView.frame, to: nil)
    let zoomingImageView = UIImageView(frame: startingFrame!)
    zoomingImageView.image = imageView.image
    zoomingImageView.isUserInteractionEnabled = true
    zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut(tapGesture:))))
    
    if let keyWindow = UIApplication.shared.keyWindow {
      
      blackBackgroundView = UIView(frame: keyWindow.frame)
      blackBackgroundView?.backgroundColor = .black
      blackBackgroundView?.alpha = 0
      
      keyWindow.addSubview(blackBackgroundView!)
      keyWindow.addSubview(zoomingImageView)
      
      UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        
        self.blackBackgroundView?.alpha = 1
        self.inputContainerView.alpha = 0
        
        let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
        
        zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
        zoomingImageView.center = keyWindow.center
      }, completion: nil)
    }
  }
  
  @objc func handleZoomOut(tapGesture: UITapGestureRecognizer) {
    if let zoomOutImageView = tapGesture.view {
      
      zoomOutImageView.layer.cornerRadius = 16
      zoomOutImageView.layer.masksToBounds = true
      
      UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        zoomOutImageView.frame = self.startingFrame!
        self.blackBackgroundView?.alpha = 0
        self.inputContainerView.alpha = 1
      }, completion: { completed in
        zoomOutImageView.removeFromSuperview()
        self.startingImageView?.isHidden = false
      })
    }
  }
}
