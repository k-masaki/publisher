//
//  EditKindleViewController.swift
//  publisher
//
//  Created by k-masaki on 2014/08/29.
//  Copyright (c) 2014年 Kohei Masaki. All rights reserved.
//

import UIKit

class EditKindleViewController: UITableViewController {

    var kindle: Kindle!
    var delegate: AnyObject!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameTextField.text = self.kindle.name
        self.emailTextField.text = self.kindle.email
        
        self.nameTextField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func doneAction(sender: AnyObject) {
        let manager = AFHTTPRequestOperationManager()
        let id = String(self.kindle.id as Int!)
        manager.responseSerializer = AFJSONResponseSerializer()
        var kindleParameters = ["name": self.nameTextField.text, "email": self.emailTextField.text]
        manager.PUT("http://localhost:3000/api/kindles/\(id)", parameters: ["kindle": kindleParameters],
            success: { (operation: AFHTTPRequestOperation!, responseObject:AnyObject!) in
                var del = self.delegate as KindlesViewController
                del.getKindles()
                self.navigationController.popViewControllerAnimated(true)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                println("error: \(error)")
                
                let alert = UIAlertView()
                alert.title = "エラー"
                alert.message = "入力されていないフィールドが存在します"
                alert.addButtonWithTitle("OK")
                alert.show()
        })
    }
}
