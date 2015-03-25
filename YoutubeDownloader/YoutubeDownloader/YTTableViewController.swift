//
//  YTTableViewController.swift
//  YoutubeDownloader
//
//  Created by Tony Hung on 2/28/15.
//  Copyright (c) 2015 Dark Bear Interactive. All rights reserved.
//

import UIKit

class YTTableViewController: UITableViewController, UISearchBarDelegate {

    var youtubeResults:[WebServices.YoutubeVideo] = []
    
    var activityIndicatior = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatior.center = self.tableView.center
        let keyWindow = UIApplication.sharedApplication().keyWindow
        keyWindow?.addSubview(activityIndicatior)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.youtubeResults.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        var youtube:WebServices.YoutubeVideo = self.youtubeResults[indexPath.row]
        cell.textLabel?.text = youtube.title
        // Configure the cell...

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var youtube:WebServices.YoutubeVideo = self.youtubeResults[indexPath.row]
        self .performSegueWithIdentifier("showDetail", sender: self)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showDetail") {
            let viewController:DetailViewController = segue.destinationViewController as DetailViewController
            let indexPath:NSIndexPath = self.tableView.indexPathForSelectedRow()!
            viewController.youtubeVideo = self.youtubeResults[indexPath.row]
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let webSerivce = WebServices()
        activityIndicatior.startAnimating()

        webSerivce .performSearch(searchBar.text, completion: { (items, error:NSError?) -> Void in
            println(items)
            
            dispatch_async(dispatch_get_main_queue(), {
                if (error != nil) {
                    let alertView = UIAlertView(title: "error", message: error!.description, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK")
                    alertView.show()
                }
                
                self.activityIndicatior.stopAnimating()
                
                self.youtubeResults = items
                self.tableView.reloadData()
            })
        })
    }
    func searchBarTextDidEndEditing(searchBar: UISearchBar)
    {
        
    }

}
