//
//  GooglePlacesTableViewCell.swift
//  HackaBike
//
//  Created by Paulo Henrique Leite on 16/04/16.
//  Copyright © 2016 Paulo Henrique Leite. All rights reserved.
//

import UIKit

class GooglePlacesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var enderecoLabel: UILabel!
    @IBOutlet weak var favorite: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func favorites(sender: AnyObject) {
        if self.favorite.tag == 0 {
            self.favorite.setBackgroundImage(UIImage(named: "icone_estrelapreenchida"), forState: .Normal)
            self.favorite.tag = 1
        }
        else {
            self.favorite.setBackgroundImage(UIImage(named: "icone_estrelanaopreenchido"), forState: .Normal)
            self.favorite.tag = 0
        }
    }
}
