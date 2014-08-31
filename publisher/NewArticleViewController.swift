//
//  NewArticleViewController.swift
//  publisher
//
//  Created by k-masaki on 2014/08/28.
//  Copyright (c) 2014年 Kohei Masaki. All rights reserved.
//

import UIKit

class NewArticleViewController: UITableViewController {
    var book: Book!
    var delegate: AnyObject!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleTextField.text = ""
        self.contentTextView.text = ""
        
        self.titleTextField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func doneAction(sender: AnyObject) {
        let id = String(self.book.id as Int!)
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        var articleParameters = ["title": self.titleTextField.text, "content": self.contentTextView.text]
        manager.POST("http://localhost:3000/api/books/\(id)/articles/", parameters: ["article": articleParameters],
            success: { (operation: AFHTTPRequestOperation!, responseObject:AnyObject!) in
                var del = self.delegate as ArticlesViewController
                del.getArticles()
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
