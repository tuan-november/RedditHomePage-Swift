//
//  TopTabHomeCell.swift
//  RingTest
//
//  Created by Tuan Anh Nguyen on 4/11/17.
//  Copyright © 2017 Tuan Anh Nguyen. All rights reserved.
//

import UIKit

class TopTabHomeCell: UITableViewCell {
    
    @IBOutlet var authorsThumbnail: UIButton!
    @IBOutlet var postTitle: UILabel!
    @IBOutlet var authorsScreenName: UILabel!
    @IBOutlet var entryDate: UILabel!
    @IBOutlet var commentQty: UILabel!
    
    var redditHomeDelegate : RedditHomeVC = RedditHomeVC()
    var fullSizeImageURL : String = ""
    var isImageLoaded : Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @IBAction func thumbnailClicked(_ sender: UIButton) {
        self.redditHomeDelegate.segueToFullSizeImageScreen(imgURL: self.fullSizeImageURL)
    }
    
}
