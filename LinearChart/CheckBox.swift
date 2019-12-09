//
//  CheckBox.swift
//  LinearChart
//
//  Created by Dmytro Mashtaler on 12/8/19.
//  Copyright © 2019 Dmytro Mashtaler. All rights reserved.
//

import UIKit

class CheckBox: UIButton {
    let checkedImage = UIImage(named: "checkbox_on_icon")! as UIImage
    let uncheckedImage = UIImage(named: "checkbox_off_icon")! as UIImage

    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, for: UIControl.State.normal)
            } else {
                self.setImage(uncheckedImage, for: UIControl.State.normal)
            }
        }
    }

    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isChecked = false
    }

    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}
