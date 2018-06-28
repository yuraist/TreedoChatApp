//
//  User.swift
//  Treedo
//
//  Created by Юрий Истомин on 17/06/2018.
//  Copyright © 2018 Yuri Istomin. All rights reserved.
//

import Foundation

struct User {
  var id: String?
  var username: String?
  var email: String?
  var profileImageURL: String?
  
  init(withDictionary dict: [String: AnyObject]) {
    username = dict["username"] as? String
    email = dict["email"] as? String
    profileImageURL = dict["profileImageUrl"] as? String
  }
  
  init(withDictionary dict: [String: AnyObject], andUID uid: String?) {
    id = uid
    username = dict["username"] as? String
    email = dict["email"] as? String
    profileImageURL = dict["profileImageUrl"] as? String
  }
}
