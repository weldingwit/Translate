//
//  ViewController.swift
//  Translate
//
//  Created by Robert O'Connor on 16/10/2015.
//  Copyright © 2015 WIT. All rights reserved.
//

import UIKit
import Speech
import AVFoundation


class ViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource, UITextViewDelegate, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var voice: UILabel!
    @IBOutlet weak var picklang: UILabel!
    @IBOutlet weak var pickerview: UIPickerView!
    @IBOutlet weak var textToTranslate: UITextView!
    @IBOutlet weak var translatedText: UITextView!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-GB"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    

    
    @IBOutlet var recordButton : UIButton!
    

    
    var language = ["French", "Spanish", "Itilian", "German"]
    
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

        
        //init toolbar for creating the button to dismiss the keyboard
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
    
    
   //Reads the text in the textview and uses speach by picking what lanuage is being used
    @IBAction func textToSpeach(_ sender: Any) {
        var lang = "fr-FR"
        let synth = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: translatedText.text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            
        if (picklang.text == "Spanish"){
            lang = "es-SP"
            utterance.voice = AVSpeechSynthesisVoice(language: lang)
            synth.speak(utterance)
            
        }else{
        
            if (picklang.text == "Itilian"){
            lang = "it-IT"
            utterance.voice = AVSpeechSynthesisVoice(language: lang)
            synth.speak(utterance)

        }else{
            
            if (picklang.text == "French")||picklang.text == "Choose Lanuage!"{
                lang = "fr-FR"
                utterance.voice = AVSpeechSynthesisVoice(language: lang)
                synth.speak(utterance)
        }else{
                
            if (picklang.text == "German"){
                lang = "de-DE"
                utterance.voice = AVSpeechSynthesisVoice(language: lang)
                synth.speak(utterance)
                
                }
             }
           }
        }
     }
    
    override public func viewDidAppear(_ animated: Bool) {
        speechRecognizer.delegate = self
        
        //Request authorization from user to use the speech recognition
        SFSpeechRecognizer.requestAuthorization { authStatus in
            /*
             The callback may not be called on the main thread. Add an
             operation to the main queue to update the record button's state.
             */
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.recordButton.isEnabled = true
                    
                case .denied:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("User denied access to speech recognition", for: .disabled)
                    
                case .restricted:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition restricted on this device", for: .disabled)
                    
                case .notDetermined:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition not yet authorized", for: .disabled)
                }
            }
        }
    }
    //Speech to text
    private func startRecording() throws {
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        try AVAudioSession.sharedInstance().setActive(true)
        try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with:.defaultToSpeaker)
        try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker);
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                self.textToTranslate.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
                self.textToTranslate.textColor = UIColor.black
                self.translatedText.textColor = UIColor.black
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true

            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
        voice.text = "Go ahead, I'm listening"
        
    }
    
    // MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
 
            
        } else {
            recordButton.isEnabled = false
            recordButton.setTitle("Recognition not available", for: .disabled)
            
        }
    }
    


//The button function for the speach to text, changes the icon from siri to cancel when button is pressed
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        Sound.play(file: "siri.mp3")
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
            recordButton.setTitle("", for: .disabled)
            recordButton.setBackgroundImage(UIImage(named: "siri.png"), for: UIControlState.normal)
            voice.text = ""
            
        } else {
            try! startRecording()
            
            recordButton.setBackgroundImage(UIImage(named: "cancel.png"), for: UIControlState.normal)
        }
        
    }
    
    //setting up a prompt text placeholder for the text view that deletes when prssed
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
        
        if(picklang.text == "German"){
            langStr = ("en|de").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        }
        let urlStr:String = ("https://api.mymemory.translated.net/get?q="+escapedStr!+"&langpair="+langStr!)
        
        let url = URL(string: urlStr)
        
        let request = URLRequest(url: url!)// Creating Http Request
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        
        LoadingIndicatorView.show("Translating...")//  Created by Vince Chan on 12/2/15.
        
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


