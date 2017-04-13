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

        self.setupNavigationBar()
        self.loadImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupNavigationBar(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save Image", style: UIBarButtonItemStyle.plain, target: self, action: #selector(saveImage(sender:)))
    }
    
    func saveImage(sender: UIBarButtonItem){
        print("Saving image...")
        
        do {
            guard let url = URL(string: self.fullSizeImageURL) else {
                fatalError("ERROR: Unable to instantiate url from self.fullSizeImageURL")
            }
            
            let image =  try UIImage(data: Data(contentsOf: url))
            UIImageWriteToSavedPhotosAlbum(image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        catch{
            print(error)
            self.displayAlertMessage(title: "ERROR!", message: error.localizedDescription)
        }
        
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        if (error == nil) {
            self.displayAlertMessage(title: "Success!", message: "Image successfully saved to your photo album")
            print("... image successfully saved")
        } else {
            self.displayAlertMessage(title: "ERROR!", message: (error?.localizedDescription)!)
            print("... image failed to save: ", (error?.localizedDescription)!)
        }
    }
    
    func loadImage(){
        do {
            if let url = URL(string: self.fullSizeImageURL){
                let image =  try UIImage(data: Data(contentsOf: url))
                DispatchQueue.main.async {
                    self.fullSizeImage.image = image
                }
            }
            else{
                self.errorMessage.text = "ERROR: url == nil"
            }
        }
        catch{
            print(error)
            self.errorMessage.text = "ERROR: " + error.localizedDescription
        }
    }
    
    func displayAlertMessage(title: String, message: String){
        let popupDialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
        popupDialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(popupDialog, animated: true, completion: nil)
    }

    // MARK: - App State Restoration
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(self.fullSizeImageURL, forKey: AppState.IMAGE_URL)
        print(type(of: self), terminator: ""); print(#function)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        guard let imgURL = coder.decodeObject(forKey: AppState.IMAGE_URL) as? String else {
            return
        }
        self.fullSizeImageURL = imgURL
        self.loadImage()
        print(type(of: self), terminator: ""); print(#function)
    }
    
    override func applicationFinishedRestoringState() {
        print("... previous state successfully restored")
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
