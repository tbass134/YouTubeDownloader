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
    
    
    required init(coder aDecoder: NSCoder) {
        youtubeVideo = WebServices.YoutubeVideo(title: "", url: "", thumbnail: "", localURL: "")
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
            
            var title =  youtubeVideo.title.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            var filename = documentsURL .URLByAppendingPathComponent(title).URLByAppendingPathExtension("mp4")
            var url = documentsURL.URLByAppendingPathComponent(title).URLByAppendingPathExtension("mp4")
            
            videoURL = url.absoluteString!
            println("videoURL \(videoURL)")
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
        
        HCYoutubeParser.h264videosWithYoutubeURL(NSURL(string: youtubeVideo.url), completeBlock: { (
            Dictionary, error) -> Void in
            println("dict = \(Dictionary)")
            
            var urlString:String
            let dict:NSDictionary = Dictionary as NSDictionary
            
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
            
        })
    }
    
}
