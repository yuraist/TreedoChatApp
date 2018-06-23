//
//  ChatController.swift
//  Treedo
//
//  Created by Юрий Истомин on 20/06/2018.
//  Copyright © 2018 Yuri Istomin. All rights reserved.
//

import UIKit

class ChatController: UICollectionViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "Chat"
    
    setupInputComponents()
  }
  
  private func setupInputComponents() {
    let containerView = UIView()
    containerView.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
    containerView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(containerView)
    
    
  }
}
