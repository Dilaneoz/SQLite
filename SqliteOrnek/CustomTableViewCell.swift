//
//  CustomTableViewCell.swift
//  SqliteOrnek
//
//  Created by Dilan Öztürk on 12.03.2023.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var lblAdi: UILabel!
    @IBOutlet weak var lblSoyadi: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
