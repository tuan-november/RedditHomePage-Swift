//
//  RedditHomeVC.swift
//  RingTest
//
//  Created by Tuan Anh Nguyen on 4/11/17.
//  Copyright © 2017 Tuan Anh Nguyen. All rights reserved.
//

import UIKit


class RedditHomeVC: UITableViewController {
    
    // MARK: - Properties
    
    var postArr : [Dictionary<String, String>] = []
    var fullSizeImgForSelectedCell : String = ""
    var shouldRestoreToPrevousState : Bool = false
    var isViewFirstLoaded : Bool = false
    var preloadedCellIndices : [IndexPath] = [IndexPath()]
    var lastTopVisibleIndexpath : IndexPath = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.setupNavigationBar()
        self.getRedditData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cell.HOME_TOP, for: indexPath) as? TopTabHomeCell else{
            fatalError("Unable to instantiate TopTabHomeCell")
        }
        
        cell.redditHomeDelegate = self
        
        let cellData : Dictionary<String, String> = self.postArr[indexPath.row]
        cell.postTitle.text = cellData[PostDictKey.TITLE]
        cell.authorsScreenName.text = cellData[PostDictKey.AUTHOR]
        cell.entryDate.text = cellData[PostDictKey.ENTRY_DATE]
        cell.commentQty.text = cellData[PostDictKey.COMMENT_QTY]
        cell.fullSizeImageURL = cellData[PostDictKey.FULLSIZE_IMG_URL]!
        
        if(self.isViewFirstLoaded){
            self.isViewFirstLoaded = false
            self.preloadedCellIndices = self.tableView.indexPathsForVisibleRows!
        }
        
        if indexPath.row < self.preloadedCellIndices.count {
            self.isViewFirstLoaded = false
            do {
                let thumbnailImage =  try UIImage(data: Data(contentsOf: URL(string: cellData[PostDictKey.THUMBNAIL]!)!))
                DispatchQueue.main.async {
                    cell.authorsThumbnail.setImage(thumbnailImage, for: UIControlState.normal)
                }
            }
            catch {
                print(error)
            }
        }
        
        return cell
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        guard let visibleIndexArray = self.tableView.indexPathsForVisibleRows else {
            fatalError("Unable to detect visible cells")
        }
        
        for idx in visibleIndexArray {
            let cellData : Dictionary<String, String> = self.postArr[idx.row]
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Cell.HOME_TOP, for: idx) as? TopTabHomeCell else{
                fatalError("Unable to instantiate TopTabHomeCell")
            }
            
            do {
                let thumbnailImage =  try UIImage(data: Data(contentsOf: URL(string: cellData[PostDictKey.THUMBNAIL]!)!))
                cell.authorsThumbnail.setImage(thumbnailImage, for: UIControlState.normal)
            }
            catch{
                print(error)
            }
            
        }
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: self.tableView.indexPathsForVisibleRows!, with: UITableViewRowAnimation.none)
        }
    }
    
    // MARK: - App State Restoration
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(self.tableView.indexPathsForVisibleRows?[0], forKey: AppState.PREVIOUS_TOP_VISIBLE_ROW)
        print(type(of: self), terminator: ""); print(#function)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        guard let lastIdxPath = coder.decodeObject(forKey: AppState.PREVIOUS_TOP_VISIBLE_ROW) as? IndexPath else {
            return
        }
        self.lastTopVisibleIndexpath = lastIdxPath
        self.shouldRestoreToPrevousState = true
        print(type(of: self), terminator: ""); print(#function)
    }
    
    override func applicationFinishedRestoringState() {
        print("... previous state successfully restored")
    }
    
    // MARK: - Navigation Bar
    
    func setupNavigationBar(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Refresh", style: UIBarButtonItemStyle.plain, target: self, action: #selector(refreshTable(sender:)))
    }
    
    func refreshTable(sender: UIBarButtonItem){
        print("Refreshing table...")
        
        self.getRedditData()
    }

    // MARK: - Navigation
    
    func segueToFullSizeImageScreen(imgURL : String) {
        self.fullSizeImgForSelectedCell = imgURL
        self.performSegue(withIdentifier: Segue.TO_FULLSIZE_IMAGE_VC, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? FullSizeImageVC else {
            fatalError("Unable to instantiate FullSizeImageVC")
        }
    
        destinationVC.fullSizeImageURL = self.fullSizeImgForSelectedCell
    }

    
    // MARK: - Reddit API Calls
    
    func getRedditData() {
        let url = URL(string: RedditURL.HOME_TOP_50)
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
            self.parsejsonData(jsonDict: json!)
            
            DispatchQueue.main.async {
                self.isViewFirstLoaded = true
                self.tableView.reloadData()
                
                if(self.shouldRestoreToPrevousState){
                    self.tableView.scrollToRow(at: self.lastTopVisibleIndexpath, at: UITableViewScrollPosition.middle, animated: true)
                    self.shouldRestoreToPrevousState = false
                }
                else {
                    self.tableView.setContentOffset(CGPoint.init(x: 0, y: -100), animated: true)
                }
            }
        }
        
        task.resume()
    }
    
    func fetchFullSizeImageURL(data : NSDictionary) -> String{
        
        guard let preview = data.value(forKey: "preview") as? NSDictionary else{
            return ""
        }
        
        guard let images = preview.value(forKey: "images") as? [NSDictionary] else{
            return ""
        }
        
        guard let source = images[0].value(forKey: "source") as? NSDictionary else{
            return ""
        }
        
        guard let fullsizeImageURL = source.value(forKey: "url") as? String else{
            return ""
        }
        
        return fullsizeImageURL
    }
    
    func parsejsonData(jsonDict : NSDictionary ){
        let jsonData = jsonDict.value(forKey: "data") as? NSDictionary
        let childrenData = jsonData?.value(forKey: "children") as? NSArray
        
        for childData in childrenData! {
            let data = (childData as! NSDictionary).value(forKey: "data") as! NSDictionary
            
            var postDict : Dictionary<String, String> = [String : String]()
            
            guard let title = data.value(forKey: "title") as? String else {
                fatalError("ERROR: Unable to retrieve data[title]")
            }
            
            guard let author = data.value(forKey: "author") as? String else {
                fatalError("ERROR: Unable to retrieve data[author]")
            }
            
            guard let comments = data.value(forKey: "num_comments") as? NSNumber else {
                fatalError("ERROR: Unable to retrieve data[num_comments]")
            }
            
            guard let utc = data.value(forKey: "created_utc") as? NSNumber else {
                fatalError("ERROR: Unable to retrieve data[create_utc]")
            }
            
            let date = NSDate(timeIntervalSince1970: TimeInterval(utc))
            let elapsedHours = Int(NSDate().timeIntervalSince(date as Date) / 3600)
            guard let thumbnailImageURL = data.value(forKey: "thumbnail") as? String else {
                fatalError("ERROR: Unable to retrieve data[thumbnail]")
            }
            
            let fullsizeImageURL = self.fetchFullSizeImageURL(data: data)
            
            postDict[PostDictKey.TITLE] = title
            postDict[PostDictKey.AUTHOR] = "by " + author
            postDict[PostDictKey.COMMENT_QTY] = comments.stringValue + " comments"
            postDict[PostDictKey.ENTRY_DATE] = String(elapsedHours) + " hours ago"
            postDict[PostDictKey.THUMBNAIL] = thumbnailImageURL
            postDict[PostDictKey.FULLSIZE_IMG_URL] = fullsizeImageURL

            self.postArr.append(postDict)
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

}
