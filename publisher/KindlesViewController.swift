//
//  KindlesViewController.swift
//  publisher
//
//  Created by k-masaki on 2014/08/29.
//  Copyright (c) 2014年 Kohei Masaki. All rights reserved.
//

import UIKit

class KindlesViewController: UITableViewController {

    var kindles = [Kindle]()
    var delegate: AnyObject!
    @IBOutlet weak var newKindleButton: UIBarButtonItem!
    
    func parseJson(jsonObject: AnyObject) {
        if let kindlesArray = jsonObject as? NSArray {
            var _kindles = [Kindle]()
            for (_kindle) in kindlesArray {
                let id = _kindle.objectForKey("id") as Int
                let name = _kindle.objectForKey("name") as String
                let email = _kindle.objectForKey("email") as String
                var kindle = Kindle(id: id, name: name, email: email)
                _kindles += [kindle]
            }
            self.kindles = _kindles
        }
    }
    
    func getKindles() {
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.GET("http://localhost:3000/api/kindles", parameters: nil,
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
        self.getKindles()
        
        var refreshControl: UIRefreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "getKindles", forControlEvents: UIControlEvents.ValueChanged)
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
        return self.kindles.count
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("KindleCell", forIndexPath: indexPath) as UITableViewCell
        var kindle = self.kindles[indexPath.row]
        cell.textLabel.text = kindle.name
        cell.detailTextLabel.text = kindle.email
        return cell
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let kindle = self.kindles[indexPath.row]
        var navController = self.storyboard.instantiateViewControllerWithIdentifier("EditKindleNavController") as UINavigationController
        var controller = navController.topViewController as EditKindleViewController
        controller.delegate = self
        controller.kindle = kindle
        self.navigationController.pushViewController(controller, animated: true)
    }
    
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let kindle = self.kindles[indexPath.row]
            let id = String(kindle.id as Int!)
            let manager = AFHTTPRequestOperationManager()
            manager.responseSerializer = AFJSONResponseSerializer()
            manager.DELETE("http://localhost:3000/api/kindles/\(id)", parameters: nil,
                success: { (operation: AFHTTPRequestOperation!, responseObject:AnyObject!) in
                    println("\(responseObject)")
                    self.getKindles()
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
        self.newKindleButton.enabled = !editing
    }
    
    @IBAction func newKindle(sender: AnyObject) {
        var navController = self.storyboard.instantiateViewControllerWithIdentifier("NewKindleNavController") as UINavigationController
        var controller = navController.topViewController as NewKindleViewController
        controller.delegate = self
        self.presentViewController(navController, animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
