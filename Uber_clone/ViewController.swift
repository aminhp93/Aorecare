//
//  ViewController.swift
//  Aorecare
//
//  Created by Minh Pham on 11/20/16.
//  Copyright © 2016 Minh Pham. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
    
    func displayAlert(title:String, message:String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    var signUpMode = true

    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var isDriverSwitch: UISwitch!
    
    @IBOutlet weak var signUpOrLogIn: UIButton!
    
    @IBOutlet weak var switchButton: UIButton!
    
    @IBOutlet weak var riderLabel: UILabel!
    
    @IBOutlet weak var driverLabel: UILabel!
    
    
    @IBAction func signUpOrLogIn(_ sender: Any) {
        if usernameTextField.text == "" || passwordTextField.text == ""{
            displayAlert(title: "Error in Form", message: "Username and password are required")
        } else {
            if signUpMode {
                let user = PFUser()
                user.username = usernameTextField.text
                user.password = passwordTextField.text
                
                user["isDriver"] = isDriverSwitch.isOn
                user.signUpInBackground(block: { (success, error) in
                    if let error = error {
                        var displayErrorMessage = "Please try again later"
                        
                        self.displayAlert(title: "Sign Up failed", message: displayErrorMessage)
                        
                    } else {
                        print("Sign Up Successfull")
                        if let isDriver = user["isDriver"] as? Bool{
                            if isDriver {
                                self.performSegue(withIdentifier: "showDriverViewController", sender: self)
                            } else {
                                self.performSegue(withIdentifier: "showRiderViewController", sender: self)
                            }
                        }
                    }
                })
            } else {
                PFUser.logInWithUsername(inBackground: usernameTextField.text!, password: passwordTextField.text!, block: { (user, error) in
                    if let error = error {
                        var displayErrorMessage = "Please try again later"
                        
                        self.displayAlert(title: "Login failed", message: displayErrorMessage)
                        
                    } else {
                        print("Login Successfull")
                        if let isDriver = PFUser.current()?["isDriver"] as? Bool{
                            if isDriver {
                                self.performSegue(withIdentifier: "showDriverViewController", sender: self)
                            } else {
                                self.performSegue(withIdentifier: "showRiderViewController", sender: self)
                            }
                        }

                    }

                })
            }
            
        }
    }
    
    @IBAction func switchButton(_ sender: Any) {
        if signUpMode {
            signUpOrLogIn.setTitle("Log In", for: [])
            
            switchButton.setTitle("Switch To Sign Up", for: [])
            
            signUpMode = false
            
            isDriverSwitch.isHidden = true
            
            riderLabel.isHidden = true
            
            driverLabel.isHidden = true
            
        } else {
            signUpOrLogIn.setTitle("Sign Up", for: [])
            
            switchButton.setTitle("Switch To Log In", for: [])
            
            signUpMode = true
            
            isDriverSwitch.isHidden = false
            
            riderLabel.isHidden = false
            
            driverLabel.isHidden = false
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let isDriver = PFUser.current()?["isDriver"] as? Bool{
            if isDriver {
                self.performSegue(withIdentifier: "showDriverViewController", sender: self)
            } else {
                self.performSegue(withIdentifier: "showRiderViewController", sender: self)
            }
        }    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

