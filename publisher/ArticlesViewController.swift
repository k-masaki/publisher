//
//  ArticlesViewController.swift
//  publisher
//
//  Created by k-masaki on 2014/08/27.
//  Copyright (c) 2014年 Kohei Masaki. All rights reserved.
//

import UIKit

class ArticlesViewController: UITableViewController {
    var book: Book!
    var articles = [Article]()
    @IBOutlet weak var newArticleButton: UIBarButtonItem!
    @IBOutlet weak var publishButton: UIBarButtonItem!
    
    func parseJson(jsonObject: AnyObject) {
        if let articlesArray = jsonObject as? NSArray {
            var _articles = [Article]()
            for (_article) in articlesArray {
                let id = _article.objectForKey("id") as Int
                let title = _article.objectForKey("title") as String
                let content = _article.objectForKey("content") as String
                var article = Article(id: id, title: title, content: content)
                _articles += [article]
            }
            self.articles = _articles
        }
    }
    
    func getArticles() {
        let manager = AFHTTPRequestOperationManager()
        let id = String(self.book.id as Int!)
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.GET("http://localhost:3000/api/books/\(id)/articles", parameters: nil,
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
        self.title = self.book.title
        self.getArticles()
        
        var refreshControl: UIRefreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "getArticles", forControlEvents: UIControlEvents.ValueChanged)
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
        return self.articles.count
    }

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("ArticleCell", forIndexPath: indexPath) as UITableViewCell
        var article = self.articles[indexPath.row]
        cell.textLabel.text = article.title
        return cell
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let article = self.articles[indexPath.row]
        var navController = self.storyboard.instantiateViewControllerWithIdentifier("EditArticleNavController") as UINavigationController
        var controller = navController.topViewController as EditArticleViewController
        controller.delegate = self
        controller.article = article
        self.navigationController.pushViewController(controller, animated: true)
    }
    
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let article = self.articles[indexPath.row]
            let id = String(article.id as Int!)
            let manager = AFHTTPRequestOperationManager()
            manager.responseSerializer = AFJSONResponseSerializer()
            manager.DELETE("http://localhost:3000/api/articles/\(id)", parameters: nil,
                success: { (operation: AFHTTPRequestOperation!, responseObject:AnyObject!) in
                    println("\(responseObject)")
                    self.getArticles()
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
        self.newArticleButton.enabled = !editing
        self.publishButton.enabled = !editing
    }

    @IBAction func newArticle(sender: AnyObject) {
        var navController = self.storyboard.instantiateViewControllerWithIdentifier("NewArticleNavController") as UINavigationController
        var controller = navController.topViewController as NewArticleViewController
        controller.delegate = self
        controller.book = self.book
        self.presentViewController(navController, animated: true, completion: nil)
    }
    
    @IBAction func PublishAction(sender: AnyObject) {
        let id = String(self.book.id as Int!)
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.GET("http://localhost:3000/api/books/\(id)/publish", parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, responseObject:AnyObject!) in
                println("\(responseObject)")
                
                let alert = UIAlertView()
                alert.title = "成功"
                alert.message = "正常にドキュメントが作成されました。数分後、お手持ちの kindle に作成されたドキュメントが配信されます"
                alert.addButtonWithTitle("OK")
                alert.show()
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                println("error: \(error)")
                
                let alert = UIAlertView()
                alert.title = "エラー"
                alert.message = "原因不明のエラーが発生しました。諦めてください"
                alert.addButtonWithTitle("OK")
                alert.show()
        })
    }
}
