//
//  NoIdeasView.swift
//  CMX
//
//  Created by Nikolay Derkach on 11/7/17.
//  Copyright © 2017 Nikolay Derkach. All rights reserved.
//

import UIKit

class NoIdeasView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        configureSubviews()
    }

    private func configureSubviews() {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "lighbulb_big"))
        addSubview(imageView)
        imageView.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(self)
            make.width.equalTo(70.0)
            make.height.equalTo(100.0)
        }

        let label = UILabel()
        label.text = "Got Ideas?"
        label.font = UIFont.systemFont(ofSize: 20.0)
        label.textColor = Color.defaultGray.value
        addSubview(label)

        label.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(imageView.snp.bottom).offset(21.0)
            make.centerX.equalTo(self)
        }
    }
}
