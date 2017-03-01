//
//  ViewController.swift
//  Translate
//
//  Created by Robert O'Connor on 16/10/2015.
//  Copyright © 2015 WIT. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textToTranslate: UITextView!
    @IBOutlet weak var translatedText: UITextView!
    
    //var data = NSMutableData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func translate(_ sender: AnyObject) {
        
        let str = textToTranslate.text
        let escapedStr = str?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        let langStr = ("en|fr").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        let urlStr:String = ("https://api.mymemory.translated.net/get?q="+escapedStr!+"&langpair="+langStr!)
        
        let url = URL(string: urlStr)
        
        let request = URLRequest(url: url!)// Creating Http Request
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        //var data = NSMutableData()var data = NSMutableData()
        
       //let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
      //indicator.center = view.center
      //view.addSubview(indicator)
     // indicator.startAnimating()
        
        LoadingIndicatorView.show("Translating...")
        
        var result = "<Translation Error>"
        
            let task = session.dataTask(with: request){
            (data, response, error) in
          

            
            if let httpResponse = response as? HTTPURLResponse {
                if(httpResponse.statusCode == 200){
                    
                    let jsonDict: NSDictionary!=(try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
                    
                    if(jsonDict.value(forKey: "responseStatus") as! NSNumber == 200){
                        let responseData: NSDictionary = jsonDict.object(forKey: "responseData") as! NSDictionary
                        
                        result = responseData.object(forKey: "translatedText") as! String
                    }
                }
                
                let block = DispatchWorkItem{

                self.translatedText.text = result
                    LoadingIndicatorView.hide()
               }
               DispatchQueue.main.async(execute: block)
            }
               
        }
        task.resume()
    }
    
}


