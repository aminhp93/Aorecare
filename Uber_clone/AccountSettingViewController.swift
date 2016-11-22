//
//  AccountSettingViewController.swift
//  Aorecare
//
//  Created by Minh Pham on 11/22/16.
//  Copyright © 2016 Minh Pham. All rights reserved.
//

import UIKit

class AccountSettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        nameCell.textLabel?.text = "Name"
        homeCell.textLabel?.text = "Home"
        workCell.textLabel?.text = "Work"
        businessCell.textLabel?.text = "Business"
        personalCell.textLabel?.text = "Personal"
        

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet weak var nameCell: UITableViewCell!
    
    @IBOutlet weak var homeCell: UITableViewCell!

    @IBOutlet weak var workCell: UITableViewCell!
    
    @IBOutlet weak var businessCell: UITableViewCell!
    
    @IBOutlet weak var personalCell: UITableViewCell!
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
