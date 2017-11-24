//
//  EditIdeaButton.swift
//  CMX
//
//  Created by Nikolay Derkach on 11/7/17.
//  Copyright © 2017 Nikolay Derkach. All rights reserved.
//

import UIKit
import SnapKit

class EditIdeaButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        for offset in [4.0, 12.0, 20.0] {
            let view = UIView()
            view.backgroundColor = Color.defaultGrayWithOpacity.value
            view.layer.cornerRadius = 2.0
            view.clipsToBounds = true
            self.addSubview(view)
            view.snp.makeConstraints { (make) -> Void in
                make.centerX.equalTo(self)
                make.width.equalTo(4.0)
                make.height.equalTo(4.0)
                make.top.equalTo(offset)
            }
        }
    }
}
