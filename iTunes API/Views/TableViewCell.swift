//
//  TableViewCell.swift
//  iTunes API
//
//  Created by 杜襄 on 2021/7/15.
//

import UIKit
import AVFoundation

protocol TableViewCellDelegate {
    func pauseMusic()
}
class TableViewCell: UITableViewCell {

    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    
    var delegate: TableViewCellDelegate?
    
    @IBAction func pausePressed(_ sender: UIButton) {
        if pauseButton.currentImage != nil{
            pauseButton.setImage(nil, for: .normal)
            delegate?.pauseMusic()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
