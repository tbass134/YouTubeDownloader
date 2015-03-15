//
//  LocalFilesTableViewController.swift
//  YoutubeDownloader
//
//  Created by Tony Hung on 3/14/15.
//  Copyright (c) 2015 Dark Bear Interactive. All rights reserved.
//

import UIKit

class LocalFilesTableViewController: UITableViewController {

    var youtubeResults:[WebServices.YoutubeVideo] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var path = paths.stringByAppendingPathComponent("data.plist")
        var array: AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithFile(path)
        youtubeResults = array as [WebServices.YoutubeVideo]!
        
        self.tableView .reloadData()
        println(array)
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

}
