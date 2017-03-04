//
//  ViewController.swift
//  Translate
//
//  Created by Robert O'Connor on 16/10/2015.
//  Copyright © 2015 WIT. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource, UITextViewDelegate {
    
    @IBOutlet weak var picklang: UILabel!
    @IBOutlet weak var pickerview: UIPickerView!
    @IBOutlet weak var textToTranslate: UITextView!
    @IBOutlet weak var translatedText: UITextView!
    
    var language = ["French", "Spanish", "Itilian","Irish"]
    
    //var data = NSMutableData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerview.delegate = self
        pickerview.dataSource = self
        textToTranslate.text = "Text To Translate"
        textToTranslate.textColor = UIColor.lightGray
        translatedText.text = "Translated Text"
        translatedText.textColor = UIColor.lightGray
        textToTranslate.delegate = self
        translatedText.delegate = self
        
        //init toolbar
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(ViewController.doneButtonAction))
        
        //array of BarButtonItems
        var arr = [UIBarButtonItem]()
        arr.append(flexSpace)
        arr.append(doneBtn)
        
        toolbar.setItems(arr, animated: false)
        toolbar.sizeToFit()
        
        //setting toolbar as inputAccessoryView
        self.textToTranslate.inputAccessoryView = toolbar
        
    }
    
    func doneButtonAction(){
        self.view.endEditing(true)
    
    }
    
    func textViewDidBeginEditing(_ textToTranslate: UITextView) {
        if textToTranslate.textColor == UIColor.lightGray {
            textToTranslate.text = nil
            textToTranslate.textColor = UIColor.black
            translatedText.textColor = UIColor.black
        }
    }
    
    
     func textViewDidEndEditing(_ textToTranslate: UITextView) {
        if textToTranslate.text.isEmpty {
           textToTranslate.text = "Text To Translate"
            textToTranslate.textColor = UIColor.lightGray
            translatedText.text = "Translated Text"
            translatedText.textColor = UIColor.lightGray
        }
    }

    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return language.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return language [row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        picklang.text = language[row]
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func translate(_ sender: AnyObject) {
        
        let str = textToTranslate.text
        let escapedStr = str?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        var langStr = ("en|fr").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        if(picklang.text == "Spanish"){
            langStr = ("en|es").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        }
        
        if(picklang.text == "Itilian"){
            langStr = ("en|it").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        }
        
        if(picklang.text == "Irish"){
            langStr = ("en|ga").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        }
        
        let urlStr:String = ("https://api.mymemory.translated.net/get?q="+escapedStr!+"&langpair="+langStr!)
        
        let url = URL(string: urlStr)
        
        let request = URLRequest(url: url!)// Creating Http Request
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        
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


