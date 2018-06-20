//
//  LoginViewController.swift
//  Treedo
//
//  Created by Юрий Истомин on 12/06/2018.
//  Copyright © 2018 Yuri Istomin. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
  
  // Firebase database reference
  private var ref: DatabaseReference!
  var messagesViewController: MessagesViewController?
  
  // MARK: - Views initialization
  
  // Username, email and password text fields container
  private let inputsContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.white
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = 5
    view.layer.masksToBounds = true
    return view
  }()
  
  private let loginRegisterButton: UIButton = {
    let button = UIButton()
    button.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
    button.setTitle("Register", for: .normal)
    button.tintColor = UIColor.white
    button.setTitleColor(UIColor(white: 1, alpha: 0.6), for: .highlighted)
    
    // Setup font changing for larger text
    let font = UIFont.boldSystemFont(ofSize: Settings.fontSize)
    if #available(iOS 11.0, *) {
      button.titleLabel?.font = UIFontMetrics(forTextStyle: UIFontTextStyle.body).scaledFont(for: font)
    } else {
      button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Settings.fontSize)
    }
    
    button.translatesAutoresizingMaskIntoConstraints = false
    button.layer.cornerRadius = 5
    button.layer.masksToBounds = true
    button.addTarget(self, action: #selector(handleRegisterLogin), for: .touchUpInside)
    return button
  }()
  
  private let loginRegisterSegmentedControl: UISegmentedControl = {
    let sc = UISegmentedControl(items: ["Login", "Register"])
    sc.tintColor = UIColor.white
    sc.selectedSegmentIndex = 1
    sc.translatesAutoresizingMaskIntoConstraints = false
    sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
    return sc
  }()
  
  private let usernameTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "Username"
    tf.autocapitalizationType = .none
    tf.keyboardType = .default
    tf.autocorrectionType = .no
    tf.translatesAutoresizingMaskIntoConstraints = false
    return tf
  }()
  
  private let usernameSeparatorView: UIView = {
    let view = UIView()
    view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private let emailTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "Email"
    tf.autocapitalizationType = .none
    tf.keyboardType = .emailAddress
    tf.autocorrectionType = .no
    tf.translatesAutoresizingMaskIntoConstraints = false
    return tf
  }()
  
  private let emailSeparatorView: UIView = {
    let view = UIView()
    view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private let passwordTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "Password"
    tf.autocapitalizationType = .none
    tf.translatesAutoresizingMaskIntoConstraints = false
    tf.isSecureTextEntry = true
    return tf
  }()
  
  // The image view cannot set self as target of UITapGestureRecognizer while the controller is not initialized
  lazy private var profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "zizi.jpg")
    imageView.layer.cornerRadius = Settings.loginScreenImageViewHeight / 2
    imageView.layer.masksToBounds = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    
    // Activate a tap gesture recognizer
    imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
    imageView.isUserInteractionEnabled = true
    
    return imageView
  }()
  
  private var inputsContainerViewHeightAnchor: NSLayoutConstraint?
  private var usernameTextFieldHeightAnchor: NSLayoutConstraint?
  
  // MARK: - View Controller lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Create firebase database reference
    ref = Database.database().reference()
    
    // Setup background color
    view.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
    
    usernameTextField.delegate = self
    emailTextField.delegate = self
    passwordTextField.delegate = self
    
    view.addSubview(inputsContainerView)
    view.addSubview(loginRegisterButton)
    view.addSubview(profileImageView)
    view.addSubview(loginRegisterSegmentedControl)
    
    // Setup constraints
    setupInputsContainerView()
    setupLoginRegisterButton()
    setupProfileImageView()
    setupLoginRegisterSegmentedControl()
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: - Setup views
  
  private func setupInputsContainerView() {
    // Setup x, y, width and hight constraints
    inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -Settings.standardDoubleOffset).isActive = true
    inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: Settings.registerInputsContainerViewHeight)
    inputsContainerViewHeightAnchor?.isActive = true
    
    // Add text fields and separator lines into the container
    inputsContainerView.addSubview(usernameTextField)
    inputsContainerView.addSubview(usernameSeparatorView)
    inputsContainerView.addSubview(emailTextField)
    inputsContainerView.addSubview(emailSeparatorView)
    inputsContainerView.addSubview(passwordTextField)
    
    // Setup text field and separator line constraints
    usernameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor,
                                            constant: Settings.standardOffset).isActive = true
    usernameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
    usernameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor,
                                             constant: -Settings.standardDoubleOffset).isActive = true
    usernameTextFieldHeightAnchor = usernameTextField.heightAnchor.constraint(equalToConstant: Settings.loginScreenTextFieldHeight)
    usernameTextFieldHeightAnchor?.isActive = true
    
    usernameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
    usernameSeparatorView.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor).isActive = true
    usernameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
    usernameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    
    emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
    emailTextField.topAnchor.constraint(equalTo: usernameSeparatorView.bottomAnchor).isActive = true
    emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, constant: -24).isActive = true
    emailTextField.heightAnchor.constraint(equalToConstant: Settings.loginScreenTextFieldHeight).isActive = true
    
    emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
    emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
    emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
    emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    
    
    passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor,
                                            constant: Settings.standardOffset).isActive = true
    passwordTextField.topAnchor.constraint(equalTo: emailSeparatorView.topAnchor).isActive = true
    passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor,
                                             constant: -Settings.standardDoubleOffset).isActive = true
    passwordTextField.heightAnchor.constraint(equalToConstant: Settings.loginScreenTextFieldHeight).isActive = true
  }
  
  private func setupLoginRegisterButton() {
    loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor,
                                             constant: Settings.middleOffset).isActive = true
    loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
    loginRegisterButton.heightAnchor.constraint(equalToConstant: Settings.loginButtonHeight).isActive = true
  }
  
  private func setupProfileImageView() {
    profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor,
                                             constant: -Settings.standardOffset).isActive = true
    profileImageView.widthAnchor.constraint(equalToConstant: Settings.loginScreenImageViewWidth).isActive = true
    profileImageView.heightAnchor.constraint(equalToConstant: Settings.loginScreenImageViewHeight).isActive = true
  }
  
  private func setupLoginRegisterSegmentedControl() {
    loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor,
                                                          constant: -Settings.standardOffset).isActive = true
    loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                         constant: -Settings.standardDoubleOffset).isActive = true
    loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: Settings.segmentedControlHeight).isActive = true
  }
  
  // MARK: - Selectors
  
  @objc private func handleRegisterLogin() {
    if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
      handleLogin()
    } else {
      handleRegister()
    }
  }
  
  @objc private func handleSelectProfileImageView() {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.allowsEditing = true
    present(picker, animated: true, completion: nil)
  }
  
  @objc private func handleLoginRegisterChange() {
    let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
    loginRegisterButton.setTitle(title, for: .normal)
    
    // Change the inputs container view size
    inputsContainerViewHeightAnchor?.constant = (loginRegisterSegmentedControl.selectedSegmentIndex == 0) ? Settings.loginInputsContainerViewHeight : Settings.registerInputsContainerViewHeight
    
    // Hide the username text field
    usernameTextFieldHeightAnchor?.isActive = false
    usernameTextFieldHeightAnchor = usernameTextField.heightAnchor.constraint(equalToConstant: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : Settings.loginScreenTextFieldHeight)
    usernameTextFieldHeightAnchor?.isActive = true
  }
  
  // MARK: - UIImagePickerControllerDelegate
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    var selectedImageFromPicker: UIImage?
    
    if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
      selectedImageFromPicker = editedImage
    } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
      selectedImageFromPicker = originalImage
    }
    
    if let selectedImage = selectedImageFromPicker {
      profileImageView.image = selectedImage
    }
    
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
  
  // MARK: - UITextFieldDelegate
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    switch textField.placeholder {
    case "Username":
      emailTextField.becomeFirstResponder()
    case "Email":
      passwordTextField.becomeFirstResponder()
    case "Password":
      perform(#selector(handleRegisterLogin))
    default:
      textField.resignFirstResponder()
    }
    return true
  }
  
  // MARK: - Firebase handlers
  
  private func handleLogin() {
    guard let email = emailTextField.text, let password = passwordTextField.text else {
      print("Form isn't valid")
      return
    }
    Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
      if error != nil {
        print(error!)
        return
      }
      
      // Successfully authenticated user
      self.messagesViewController?.fetchUserAndSetupNavigationBar()
      
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  private func handleRegister() {
    guard let email = emailTextField.text, let password = passwordTextField.text, let username = usernameTextField.text else {
      print("Form isn't valid.")
      return
    }
    Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
      if let error = error {
        print(error)
        return
      }
      
      guard let uid = authResult?.user.uid else {
        return
      }
      
      // Successfully authenticated user
      // Save an image into the firebase storage
      let imageName = UUID().uuidString
      let storageRef = Storage.storage().reference().child("images/\(imageName).jpg")
      
      // Get the image data
      if let profileImage = self.profileImageView.image {
        if let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
          // Put the data into the datastorage
          storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
            if error != nil {
              print(error!)
              return
            }
            
            // Get access to download URL
            storageRef.downloadURL(completion: { (url, err) in
              if err != nil {
                print(err!)
                return
              }
              
              if let downloadUrlString = url?.absoluteString {
                let values = ["username": username, "email": email, "profileImageUrl": downloadUrlString]
                self.registerUserIntoDatabase(withUID: uid, values: values)
              }
            })
          })
        }
      }
    }
  }
  
  private func registerUserIntoDatabase(withUID uid: String, values: [String: String]) {
    let userReference = self.ref.child("users").child(uid)
    userReference.updateChildValues(values, withCompletionBlock: { (err, reference) in
      if err != nil {
        print(err!)
        return
      }
      
      let username = values["username"]
      let email = values["email"]
      let profileImageUrl = values["profileImageUrl"]
      let user = User(username: username, email: email, profileImageURL: profileImageUrl)
      self.messagesViewController?.setupNavBar(withUser: user)
      self.dismiss(animated: true, completion: nil)
    })
  }
}


struct Settings {
  static var fontSize: CGFloat = 17
  static var loginScreenImageViewWidth: CGFloat = 150
  static var loginScreenImageViewHeight: CGFloat = 150
  static var loginInputsContainerViewHeight: CGFloat = 100
  static var registerInputsContainerViewHeight: CGFloat = 150
  static var loginScreenTextFieldHeight: CGFloat = 50
  static var loginButtonHeight: CGFloat = 50
  static var segmentedControlHeight: CGFloat = 30
  
  static var standardOffset: CGFloat = 12
  static var standardDoubleOffset: CGFloat = 24
  static var middleOffset: CGFloat = 16
}
