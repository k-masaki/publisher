//
//  NewBookController.swift
//  publisher
//
//  Created by k-masaki on 2014/08/29.
//  Copyright (c) 2014年 Kohei Masaki. All rights reserved.
//

import UIKit

class NewBookViewController: UITableViewController {

    var delegate: AnyObject!
    @IBOutlet weak var titleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleTextField.text = ""
        self.titleTextField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func doneAction(sender: AnyObject) {
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        var bookParameters = ["title": self.titleTextField.text]
        manager.POST("http://localhost:3000/api/books/", parameters: ["book": bookParameters],
            success: { (operation: AFHTTPRequestOperation!, responseObject:AnyObject!) in
                var del = self.delegate as BooksViewController
                del.getBooks()
                self.dismissViewControllerAnimated(true, completion: nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                println("error: \(error)")
                
                let alert = UIAlertView()
                alert.title = "エラー"
                alert.message = "入力されていないフィールドが存在します"
                alert.addButtonWithTitle("OK")
                alert.show()
        })
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
