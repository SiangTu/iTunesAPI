//
//  TableViewCell.swift
//  iTunes API
//
//  Created by 杜襄 on 2021/7/15.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    
    weak var controller: ResultViewController?
    
    @IBAction func pausePressed(_ sender: UIButton) {
        if pauseButton.currentImage != nil{
            controller?.playingPlayer?.pause()
        }
    }
    
}
