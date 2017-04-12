//
//  FullSizeImageVC.swift
//  RingTest
//
//  Created by Tuan Anh Nguyen on 4/11/17.
//  Copyright © 2017 Tuan Anh Nguyen. All rights reserved.
//

import UIKit

class FullSizeImageVC: UIViewController {

    var fullSizeImageURL : String = ""
    
    @IBOutlet var fullSizeImage: UIImageView!
    @IBOutlet var errorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadImage(){
        do {
            let image =  try UIImage(data: Data(contentsOf: URL(string: self.fullSizeImageURL)!))
            DispatchQueue.main.async {
                self.fullSizeImage.image = image
            }
        }
        catch{
            print(error)
            self.errorMessage.text = "ERROR: " + error.localizedDescription
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
