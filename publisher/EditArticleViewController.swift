//
//  EditArticleViewController.swift
//  publisher
//
//  Created by k-masaki on 2014/08/28.
//  Copyright (c) 2014年 Kohei Masaki. All rights reserved.
//

import UIKit

class EditArticleViewController: UITableViewController {

    var article: Article!
    var delegate: AnyObject!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleTextField.text = self.article.title
        self.contentTextView.text = self.article.content
        
        self.titleTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func doneAction(sender: AnyObject) {
        let manager = AFHTTPRequestOperationManager()
        let id = String(self.article.id as Int!)
        manager.responseSerializer = AFJSONResponseSerializer()
        var articleParameters = ["title": self.titleTextField.text, "content": self.contentTextView.text]
        manager.PUT("http://localhost:3000/api/articles/\(id)", parameters: ["article": articleParameters],
            success: { (operation: AFHTTPRequestOperation!, responseObject:AnyObject!) in
                var del = self.delegate as ArticlesViewController
                del.getArticles()
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
