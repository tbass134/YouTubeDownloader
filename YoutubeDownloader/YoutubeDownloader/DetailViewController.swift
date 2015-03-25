//
//  DetailViewController.swift
//  YoutubeDownloader
//
//  Created by Tony Hung on 2/28/15.
//  Copyright (c) 2015 Dark Bear Interactive. All rights reserved.
//

import UIKit
import MediaPlayer

class DetailViewController: UIViewController {

     var youtubeVideo:WebServices.YoutubeVideo
     var videoURL:String
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var videoText: UITextView!
    @IBOutlet weak var downloadButton: UIButton!

    
    required init(coder aDecoder: NSCoder) {
        youtubeVideo = WebServices.YoutubeVideo()
        videoURL = ""
        super.init(coder: aDecoder)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        println(youtubeVideo.description());
        if youtubeVideo.localURL == "" {
            loadYoutubeVideo()
        } else {
            let fileManger = NSFileManager.defaultManager()
            let paths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            let documentsURL = paths[0] as NSURL
            
            if var title = youtubeVideo.title {
                var theTitle = title.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                var filename = documentsURL .URLByAppendingPathComponent(theTitle).URLByAppendingPathExtension("mp4")
                var url = documentsURL.URLByAppendingPathComponent(theTitle).URLByAppendingPathExtension("mp4")
                
                videoURL = url.absoluteString!
                downloadButton.enabled = false
                
                println("videoURL \(videoURL)")
            }
        }
        
        if youtubeVideo.thumbnail != "" {
            
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func playVideo(sender: UIButton) {
        
        
        if videoURL != "" {
            
            if let mp = MPMoviePlayerViewController(contentURL: NSURL(string:videoURL)) {
                presentMoviePlayerViewControllerAnimated(mp)
            }
            
        }

    }
    @IBAction func doDownload(sender: AnyObject) {
        let webSerivce = WebServices()
        videoURL = videoURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        webSerivce.downloadVideo(NSURL(string: videoURL)!, object: youtubeVideo)

    }
    
    func loadYoutubeVideo()
    {
        
        HCYoutubeParser.h264videosWithYoutubeURL(NSURL(string: youtubeVideo.url!), completeBlock: { (
            dictionary, error) -> Void in
            println("dict = \(dictionary)")
            
            var urlString:String
            if (dictionary != nil) {
                let dict:NSDictionary = dictionary as NSDictionary
                
                if let smallURL: String = dict["small"] as? String {
                    println(smallURL)
                    self.videoURL = smallURL
                }
                else if let liveURL: String = dict["live"] as? String {
                    self.videoURL = liveURL
                } else
                {
                    println("could not find url")
                }
            }
            
        })
    }
    
}
