//
//  LeaderboardEntryCell.swift
//  Leaderboardly
//
//  Created by Simon Bromberg on 2020-01-31.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import UIKit

class LeaderboardEntryCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        profileImageView.layer.cornerRadius = 5
        profileImageView.layer.borderColor = UIColor.label.cgColor
        profileImageView.layer.borderWidth = 1
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()

        profileImageView.layer.borderColor = UIColor.label.cgColor
    }
}
