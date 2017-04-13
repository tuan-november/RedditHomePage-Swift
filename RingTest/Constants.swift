//
//  Constants.swift
//  RingTest
//
//  Created by Tuan Anh Nguyen on 4/13/17.
//  Copyright © 2017 Tuan Anh Nguyen. All rights reserved.
//

import Foundation

struct Constant{
    
}

struct AppState{
    static let IMAGE_URL = "imageURL"
    static let PREVIOUS_TOP_VISIBLE_ROW = "previousTopVisibleRow"
}

struct RedditURL{
    static let HOME_TOP_50 = "https://api.reddit.com/top?limit=50"
}

struct Cell{
    static let HOME_TOP = "topPostCell"
}

struct Segue{
    static let TO_FULLSIZE_IMAGE_VC = "segueToFullSizeImage"
}

struct PostDictKey{
    static let TITLE = "title"
    static let AUTHOR = "author"
    static let ENTRY_DATE = "entryDate"
    static let COMMENT_QTY = "comments"
    static let THUMBNAIL = "thumbnailImageURL"
    static let FULLSIZE_IMG_URL = "fullsizeImageURL"
}
