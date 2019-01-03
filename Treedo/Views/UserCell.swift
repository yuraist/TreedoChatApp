//
//  UserCell.swift
//  Treedo
//
//  Created by Юрий Истомин on 28/06/2018.
//  Copyright © 2018 Yuri Istomin. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
  
  var message: Message? {
    didSet {
      textLabel?.text = nil
      profileImageView.image = nil
      self.detailTextLabel?.text = message?.text
      if let seconds = message?.timestamp?.doubleValue {
        let timestampDate = Date(timeIntervalSince1970: seconds)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss a"
        timeLabel.text = dateFormatter.string(from: timestampDate)
        timeLabel.isHidden = false
      }
      setupNameAndProfileImage()
    }
  }
  
  let profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "user.png")
    imageView.contentMode = .scaleAspectFill
    imageView.layer.cornerRadius = 24
    imageView.layer.masksToBounds = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  let timeLabel: UILabel = {
    let label = UILabel()
    label.isHidden = true
    label.font = UIFont.systemFont(ofSize: 12)
    label.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
    detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
  }
  
  private func setupNameAndProfileImage() {
    
    if let id = message?.chatPartnerId() {
      let ref = Database.database().reference().child("users").child(id)
      ref.observeSingleEvent(of: .value) { [weak self] snapshot in
        if let dictionary = snapshot.value as? [String: AnyObject] {
          let username = dictionary["username"] as? String
          if let imageUrl = dictionary["profileImageUrl"] as? String {
            self?.profileImageView.loadImageUsingCache(withUrlString: imageUrl)
          }
          self?.textLabel?.text = username
        }
      }
    }
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    
    backgroundColor = UIColor.color(r: 32, g: 34, b: 49)
    textLabel?.textColor = UIColor.white
    detailTextLabel?.textColor = UIColor.white
    
    addSubview(profileImageView)
    addSubview(timeLabel)
    
    // Create constants for profile image view width and height
    profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
    profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
    profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
    
    timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
    timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
    timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
