//
//  RedditHomeVC.swift
//  RingTest
//
//  Created by Tuan Anh Nguyen on 4/11/17.
//  Copyright © 2017 Tuan Anh Nguyen. All rights reserved.
//

import UIKit

class TopTabHomeCell: UITableViewCell {
    
    @IBOutlet var authorsThumbnail: UIImageView!
    @IBOutlet var postTitle: UILabel!
    @IBOutlet var authorsScreenName: UILabel!
    @IBOutlet var entryDate: UILabel!
    @IBOutlet var commentQty: UILabel!
}


class RedditHomeVC: UITableViewController {
    
    // MARK: - Properties
    
    let urlHomeTop = "https://api.reddit.com/top?limit=50"
    var postArr : [Dictionary<String, String>] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "topPostCell", for: indexPath) as? TopTabHomeCell else{
            fatalError("The dequeued cell is not an instance of TopTabHomeCell")
        }
        
        let cellData : Dictionary<String, String> = self.postArr[indexPath.row]
        cell.postTitle.text = cellData["title"]
        cell.authorsScreenName.text = cellData["author"]
        cell.entryDate.text = cellData["entryDate"]
        cell.commentQty.text = cellData["comments"]
        
        do {
            let thumbnailImage =  try UIImage(data: Data(contentsOf: URL(string: cellData["thumbnailImageURL"]!)!))
            DispatchQueue.main.async {
                cell.authorsThumbnail.image = thumbnailImage
            }
        }
        catch{
            print(error)
        }
        
        return cell
    }


    // MARK: - Reddit API Calls
    
    func getRedditData() {
        let url = URL(string: urlHomeTop)
        
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
        }
        
        task.resume()
        
        let date = NSDate(timeIntervalSince1970: 1491838131)
        let elapsed = NSDate().timeIntervalSince(date as Date)
        print("elapsed (hours ago): ", Int(elapsed / 3600))
        
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
            
            let title = data.value(forKey: "title") as! String
            let author = data.value(forKey: "author") as! String
            let comments = data.value(forKey: "num_comments") as! NSNumber
            let utc = data.value(forKey: "created_utc") as! NSNumber
            let date = NSDate(timeIntervalSince1970: TimeInterval(utc))
            let elapsedHours = Int(NSDate().timeIntervalSince(date as Date) / 3600)
            let thumbnailImageURL = data.value(forKey: "thumbnail") as! String
            let fullsizeImageURL = self.fetchFullSizeImageURL(data: data)
            
            postDict["title"] = title
            postDict["author"] = "by " + author
            postDict["comments"] = comments.stringValue + " comments"
            postDict["entryDate"] = "submitted " + String(elapsedHours) + " hours ago"
            postDict["thumbnailImageURL"] = thumbnailImageURL
            postDict["fullsizeImageURL"] = fullsizeImageURL

            self.postArr.append(postDict)
            
            print("")
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        print("")
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
