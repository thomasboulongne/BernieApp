//
//  Helpers.swift
//  BernieApp
//
//  Created by Eleve on 19/05/2017.
//  Copyright © 2017 Bernie. All rights reserved.
//

import Foundation
import UIKit

extension String
{
    func  toDate( dateFormat format  : String) -> Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: self)
        {
            return date
        }
        print("Invalid arguments ! Returning Current Date . ")
        return Date()
    }
}

extension UITableView {
    func reloadData(completion: @escaping ()->()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData() })
        { _ in completion() }
    }
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
        }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

func Delay(delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}
