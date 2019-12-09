//
//  UIViewControllerExtensions.swift
//  LinearChart
//
//  Created by Dmytro Mashtaler on 12/7/19.
//  Copyright © 2019 Dmytro Mashtaler. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlertMessage(_ message: String?, withTitle title: String?, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: completion))
        self.present(alert, animated: true, completion: nil)
    }
    
}
