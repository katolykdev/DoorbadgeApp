//
//  MemoryBookLoginViewController.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 7/7/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//


import Foundation
import UIKit
import Firebase

class MemoryBookLoginViewController: UIViewController {
    
    var event: Event!
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var memoryBookTitleText: UILabel!
    @IBOutlet weak var enterCodeField: UITextField!
    @IBOutlet weak var findMemoryBookButton: LoadingButton!
    
    @IBAction func findMemoryBookButtonDidTap(_ sender: Any) {
//        performSegue(withIdentifier: "logInToMemoryBook", sender: UIButton.self)
        
        findMemoryBookButton.isEnabled = false
        findMemoryBookButton.showLoading()
        
        if let eventCode = enterCodeField.text?.uppercased() {
            
            let eventRef = db.collection("events").whereField("eventCode", isEqualTo: eventCode)
            
            eventRef.getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                       
                    } else {
                        
                        if querySnapshot!.documents.count == 0 {
                     
                            self.findMemoryBookButton.hideLoading()
                            self.findMemoryBookButton.isEnabled = true
                            let alert = UIAlertController(title: "Not a known event", message: "Please re-enter your event code.", preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
                            
                            self.present(alert, animated: true)
                        } else {
                        
                            checkForMemoryCode: for document in querySnapshot!.documents {
                                
                                let event = Event(dictionary: document.data())
                                MemoryBookEvent.activeMemoryBook = event
                              
                                self.findMemoryBookButton.hideLoading()
                                self.findMemoryBookButton.isEnabled = true
                                self.succesfulLogIn()
                                break checkForMemoryCode
                            }
                        }
                    }
                }
            }
        }
    
    func succesfulLogIn() {
        performSegue(withIdentifier: "logInToMemoryBook", sender: AnyObject.self)
    }
    
    override func viewDidLoad() {
        
        enterCodeField.leftViewMode = .always
        enterCodeField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))

        enterCodeField.tag = 0
        
        enterCodeField.setBottomBorder()
        
        findMemoryBookButton.layer.cornerRadius = 5.0
        
        memoryBookTitleText.addCharacterSpacing(kernValue: 1.10)
        
        MemoryBookEvent.comments = []
        self.navigationController?.navigationBar.tintColor = UIColor.black
    }
}
