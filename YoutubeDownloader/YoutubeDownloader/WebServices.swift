//
//  WebServices.swift
//  YoutubeDownloader
//
//  Created by Tony Hung on 2/28/15.
//  Copyright (c) 2015 Dark Bear Interactive. All rights reserved.
//

import UIKit

class WebServices: NSObject {
   
    struct YoutubeVideo {
        var title:String
        var url:String
        var thumbnail:String
        
        func description() -> NSString {
            return "title: \(title) url: \(url) thumbnail: \(thumbnail)"
        }
        
    }
    func performSearch(searchTerm:String, completion:([YoutubeVideo])->Void) {
        
        var videoArray:[YoutubeVideo] = []
        
        var request = NSMutableURLRequest (URL: NSURL (string: "http://gdata.youtube.com/feeds/api/videos?q=bacon&max-results=5&alt=json")!)
    
        var session = NSURLSession.sharedSession()
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            //println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            //println("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    var success = parseJSON["success"] as? Int
                    //println("Succes: \(success)")
                    if let feed:AnyObject = parseJSON["feed"] {
                        let dataArray = feed["entry"] as NSArray;
                        //println(dataArray)
                        for item in dataArray { // loop through data items
                            let obj = item as NSDictionary
                            //println(obj)
                            var title:String = ""
                            var thumbnail:String = ""
                            var url:String = "test"
                            
                            if let titleObj:AnyObject = obj["title"] {
                                title = titleObj["$t"] as String
                            }
                            if let mediaGroup:AnyObject = obj["media$group"] {
                                if let media = mediaGroup["media$thumbnail"] as? NSArray {
                                    //println(media)
                                    if let thumbnailObj = media[0] as? NSDictionary {
                                        thumbnail = thumbnailObj["url"] as String
                                        //println(youtubeVideo.thumbnail)
                                    }
                                }
                            }
                            
                            if let link = obj["link"]  as? NSArray {
                                //println(media)
                                if let urlObj = link[0] as? NSDictionary {
                                    url = urlObj["href"] as String
                                }
                            }
                            var youtubeVideo:YoutubeVideo = YoutubeVideo(title: title, url: url, thumbnail: thumbnail)
                            videoArray .append(youtubeVideo)


                        }

                    }
                    completion(videoArray)
                    
                }
                    
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        
        task.resume()
        
    }
    
    func downloadURL() {
        var request = NSMutableURLRequest (URL: NSURL (string: "http://gdata.youtube.com/feeds/api/videos?q=bacon&max-results=5&alt=json")!)

    }
}

