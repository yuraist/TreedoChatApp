//
//  Extensions.swift
//  Treedo
//
//  Created by Юрий Истомин on 18/06/2018.
//  Copyright © 2018 Yuri Istomin. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()
let placeholder = UIImage(named: "user.png")

extension UIImageView {
  func loadImageUsingCache(withUrlString urlString: String) {

    // Clean the image 
    self.image = placeholder
    
    // Check cache for image first
    if let cachedImage = imageCache.object(forKey: urlString as NSString) {
      self.image = cachedImage
      return
    }
    
    // Otherwise fire off a new download
    let url = URL(string: urlString)
    URLSession.shared.dataTask(with: url!) { (data, response, error) in
      if error != nil {
        print(error!)
        return
      }
      
      DispatchQueue.main.async {
        if let downloadedImage = UIImage(data: data!) {
          imageCache.setObject(downloadedImage, forKey: urlString as NSString)
          self.image = UIImage(data: data!)
        }
      }
    }.resume()
  }
}
