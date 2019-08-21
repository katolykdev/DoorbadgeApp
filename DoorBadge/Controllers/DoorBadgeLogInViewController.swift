//
//  DoorBadgeLogInViewController.swift
//  DoorBadge
//
//  Created by Robert Cadorette on 4/24/19.
//  Copyright © 2019 Robert Cadorette. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase

typealias Completion = (_ errMsg: String?, _ data: AnyObject?) -> Void

class DoorBadgeLogInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var logInPageTitle: UILabel!
    
    
    @IBOutlet weak var dbEmailTextField: UITextField!
    
    @IBOutlet weak var dbPasswordTextField: UITextField!
    
    @IBOutlet weak var dbLogInButton: LoadingButton!
    
    let facilityRef = Firestore.firestore().collection("facilities")
    let familyRef = Firestore.firestore().collection("users")

    
    var logInPageTitleText = ""
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentFacility: Facility!

    override func viewDidLoad() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DoorBadgeLogInViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        
        dbLogInButton.originalButtonText = "Log in"
        
        dbEmailTextField.leftViewMode = .always
        dbEmailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        dbPasswordTextField.leftViewMode = .always
        dbPasswordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        dbEmailTextField.delegate = self
        dbEmailTextField.tag = 0
        dbPasswordTextField.delegate = self
        dbPasswordTextField.tag = 1
        
        dbEmailTextField.setBottomBorder()
        dbPasswordTextField.setBottomBorder()
        
        dbLogInButton.layer.cornerRadius = 5.0
        
        logInPageTitle.text = "\(logInPageTitleText) Login"
        logInPageTitle.addCharacterSpacing(kernValue: 1.10)
        
        
        
    }
    
    
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            logIn(onComplete: { (errMsg, data) in
                guard errMsg == nil else {
                    let alert = UIAlertController(title: "Login Error", message: errMsg, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
            })
            
            return true
        }
        return false
    }
    
    @IBAction func dbForgotPassword(_ sender: UIButton) {
        
        let forgotPasswordAlert = UIAlertController(title: "Forgot password?", message: "Enter email address", preferredStyle: .alert)
        forgotPasswordAlert.addTextField { (textField) in
            textField.placeholder = "Enter email address"
        }
        forgotPasswordAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        forgotPasswordAlert.addAction(UIAlertAction(title: "Reset Password", style: .default, handler: { (action) in
            let resetEmail = forgotPasswordAlert.textFields?.first?.text
            Auth.auth().sendPasswordReset(withEmail: resetEmail!, completion: { (error) in
                //Make sure you execute the following code on the main queue
                DispatchQueue.main.async {
                    //Use "if let" to access the error, if it is non-nil
                    if let error = error {
                        let resetFailedAlert = UIAlertController(title: "Reset Failed", message: error.localizedDescription, preferredStyle: .alert)
                        resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(resetFailedAlert, animated: true, completion: nil)
                    } else {
                        let resetEmailSentAlert = UIAlertController(title: "Reset email sent successfully", message: "Check your email", preferredStyle: .alert)
                        resetEmailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(resetEmailSentAlert, animated: true, completion: nil)
                    }
                }
            })
        }))
        //PRESENT ALERT
        self.present(forgotPasswordAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func dbLoginDidTap(_ sender: UIButton) {
        
        
        dbLogInButton.isEnabled = false
        dbLogInButton.showLoading()
        
        
        
        
            self.logIn(onComplete:  { (errMsg, data) in
                guard errMsg == nil else {

                    let alert = UIAlertController(title: "Login Error", message: errMsg, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
//                    self.dbLogInButton.hideLoading()
                    self.dbLogInButton.isEnabled = true
                    return
                    
                }
            })
    

    }
    
    func stopButtonAnimation() {
        
        dbLogInButton.hideLoading()

    }
    
    
    func logIn(onComplete: Completion?) {


        if dbEmailTextField.text != "" && dbPasswordTextField.text != "" {
            
            let email = dbEmailTextField.text!
            let password = dbPasswordTextField.text!
            if Auth.auth().currentUser == nil {
                Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                    if error != nil {
                        
                        self.handleFirebaseErrors(error: error! as NSError, onComplete: onComplete)
                        self.stopButtonAnimation()
                    } else {
                        
                        self.dbLogInButton.hideLoading()
                        
                        if self.logInPageTitleText == "Family" {
                            
                            UserDefaults.standard.set("family", forKey: "logInType")
                            
                            if let uid = Auth.auth().currentUser?.uid {
                                
                                let familyDocRef = self.familyRef.document(uid)
                                
                                familyDocRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        
                                      
                                        self.performSegue(withIdentifier: "loggedInToOpenEvents", sender: self)
                                    } else {
                                        
                                      
                                        try! Auth.auth().signOut()
                                       
                                        
                                        self.dbLogInButton.isEnabled = true
                                        self.stopButtonAnimation()
                                        
                                        let alert = UIAlertController(title: "Not a known family account", message: "Please re-enter your email and password.", preferredStyle: .alert)
                                        
                                        alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
                                        
                                        alert.addAction(UIAlertAction(title: "Switch to Facility", style: .default, handler: { action in
                                            
                                            self.logInPageTitle.text = "Facility Login"
                                            self.logInPageTitleText = "Facility"
                                            
                                            
                                            
                                        }))
                                        
                                        self.present(alert, animated: true)
                                        
                                    }
                                }
   
                            }
                            
                        } else {
                            
                            UserDefaults.standard.set("facility", forKey: "logInType")
                            
                            if let uid = Auth.auth().currentUser?.uid {
                                
                                let facilityDocRef = self.facilityRef.document(uid)
                                
                                facilityDocRef.getDocument { (document, error) in
                                    if let document = document, document.exists {
                                        
                                  
                                        self.performSegue(withIdentifier: "loggedInToOpenEvents", sender: self)
                                        
                                    } else {
                                        
                                      
                                        try! Auth.auth().signOut()
                                        
                                        
                                        self.dbLogInButton.isEnabled = true
                                        self.stopButtonAnimation()
                                        
                                        let alert = UIAlertController(title: "Not a known facility account", message: "Please re-enter your email and password.", preferredStyle: .alert)
                                        
                                        alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
                                        
                                        alert.addAction(UIAlertAction(title: "Switch To Family", style: .default, handler: { action in
                                            
                                            self.logInPageTitle.text = "Family Login"
                                            self.logInPageTitleText = "Family"
                                            
                                        }))
                                        
                                        self.present(alert, animated: true)
                                        
                                    }
                                }
                            }
                        }
                    }
                })
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loggedInToOpenEvents" {
            if let openEventsVC = segue.destination as? DoorBadgeOpenEventsViewController {
                
                openEventsVC.logInType = logInPageTitleText
 
//                let nextPageBack = "Open Events"
//                let backItem = UIBarButtonItem()
//                backItem.title = nextPageBack
//                navigationItem.backBarButtonItem = backItem
                
            }
        }
    }
    

    
    func handleFirebaseErrors(error: NSError, onComplete: Completion?) {
        
        if let errorCode = AuthErrorCode(rawValue: error.code) {
            switch (errorCode) {
            case .invalidEmail, .userNotFound:
                onComplete?("Invalid email address", nil)
                break
            case .wrongPassword:
                onComplete?("You're password for this email is incorrect", nil)
                break
            default:
                onComplete?("There was a problem. Try again", nil)
            }
        }
    }

}

extension UITextField {
    func setBottomBorder() {
//        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 7
        self.layer.borderColor = UIColor.gray.cgColor
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!,
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        
        self.layer.masksToBounds = false

    }
}
