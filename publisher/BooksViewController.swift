//
//  BooksViewController.swift
//  publisher
//
//  Created by k-masaki on 2014/08/29.
//  Copyright (c) 2014年 Kohei Masaki. All rights reserved.
//

import UIKit

class BooksViewController: UITableViewController {

    var books = [Book]()
    @IBOutlet weak var newBookButton: UIBarButtonItem!
    @IBOutlet weak var manageKindleButton: UIBarButtonItem!
    
    func parseJson(jsonObject: AnyObject) {
        if let booksArray = jsonObject as? NSArray {
            var _books = [Book]()
            for (_book) in booksArray {
                let id = _book.objectForKey("id") as Int
                let title = _book.objectForKey("title") as String
                var book = Book(id: id, title: title)
                _books += [book]
            }
            self.books = _books
        }
    }
    
    func getBooks() {
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.GET("http://localhost:3000/api/books", parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, responseObject:AnyObject!) in
                println("\(responseObject)")
                self.refreshControl.endRefreshing()
                
                self.parseJson(responseObject)
                self.tableView.reloadData()
                
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                println("error: \(error)")
                self.refreshControl.endRefreshing()
                
                let alert = UIAlertView()
                alert.title = "エラー"
                alert.message = "原因不明のエラーが発生しました。諦めてください"
                alert.addButtonWithTitle("OK")
                alert.show()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getBooks()
        
        var refreshControl: UIRefreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "getBooks", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.books.count
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("BookCell", forIndexPath: indexPath) as UITableViewCell
        var book = self.books[indexPath.row]
        cell.textLabel.text = book.title
        return cell
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let book = self.books[indexPath.row]
        var navController = self.storyboard.instantiateViewControllerWithIdentifier("ArticlesNavController") as UINavigationController
        var controller = navController.topViewController as ArticlesViewController
        controller.book = book
        self.navigationController.pushViewController(controller, animated: true)
//        self.presentViewController(navController, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let book = self.books[indexPath.row]
            let id = String(book.id as Int!)
            let manager = AFHTTPRequestOperationManager()
            manager.responseSerializer = AFJSONResponseSerializer()
            manager.DELETE("http://localhost:3000/api/books/\(id)", parameters: nil,
                success: { (operation: AFHTTPRequestOperation!, responseObject:AnyObject!) in
                    println("\(responseObject)")
                    self.getBooks()
                }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                    println("error: \(error)")
                    
                    let alert = UIAlertView()
                    alert.title = "エラー"
                    alert.message = "削除に失敗しました"
                    alert.addButtonWithTitle("OK")
                    alert.show()
            })
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.newBookButton.enabled = !editing
        self.manageKindleButton.enabled = !editing
    }
    
    @IBAction func newBook(sender: AnyObject) {
        var navController = self.storyboard.instantiateViewControllerWithIdentifier("NewBookNavController") as UINavigationController
        var controller = navController.topViewController as NewBookViewController
        controller.delegate = self
        self.presentViewController(navController, animated: true, completion: nil)
    }
    
    
    @IBAction func manageKindle(sender: AnyObject) {
        var navController = self.storyboard.instantiateViewControllerWithIdentifier("KindlesNavController") as UINavigationController
        var controller = navController.topViewController as KindlesViewController
        controller.delegate = self
        self.presentViewController(navController, animated: true, completion: nil)
    }
}
