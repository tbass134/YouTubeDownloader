//
//  WebServices.swift
//  YoutubeDownloader
//
//  Created by Tony Hung on 2/28/15.
//  Copyright (c) 2015 Dark Bear Interactive. All rights reserved.
//

import UIKit

class WebServices: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate {
   
    class YoutubeVideo : NSObject,NSCoding {
        var title:String?
        var url:String?
        var thumbnail:String?
        var localURL:String?
        
        func description() -> NSString {
            return "title: \(title) url: \(url) thumbnail: \(thumbnail) localURL: \(localURL)"
        }
        init (title: String? = nil, url: String? = nil, thumbnail:String? = nil, localURL:String? = nil) {
            self.title = title
            self.url = url
            self.thumbnail = thumbnail
            self.localURL = localURL
        }
        
        required init(coder aDecoder: NSCoder) {
            title = aDecoder.decodeObjectForKey("title") as? String
            url = aDecoder.decodeObjectForKey("url") as? String
            thumbnail = aDecoder.decodeObjectForKey("thumbnail") as? String
            localURL = aDecoder.decodeObjectForKey("localURL") as? String

        }
        
        func encodeWithCoder(aCoder: NSCoder) {
            aCoder.encodeObject(title, forKey: "title")
            aCoder.encodeObject(url, forKey: "url")
            aCoder.encodeObject(thumbnail, forKey: "thumbnail")
            aCoder.encodeObject(localURL, forKey: "localURL")

        }

    }
    override init()
    {
        theObject = YoutubeVideo(title: "", url: "", thumbnail: "",localURL: "")
    }
    
    func performSearch(searchTerm:String, completion:(results:[YoutubeVideo], error:NSError?)->Void) {
        
        var videoArray:[YoutubeVideo] = []
        
        var string = "http://gdata.youtube.com/feeds/api/videos?q=\(searchTerm)&max-results=5&alt=json"
        var encodedString = string.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        
        
        var request = NSURLRequest (URL: NSURL (string: encodedString!)!)
        println("request =\(request.URL)")
    
        var session = NSURLSession.sharedSession()
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err?.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
                completion(results: [], error: err)

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
                            println("title = \(title) url = \(url) thumbnail = \(thumbnail)")
                            var youtubeVideo:YoutubeVideo = YoutubeVideo(title: title, url: url, thumbnail: thumbnail, localURL:"")
                            videoArray .append(youtubeVideo)


                        }
                        completion(results: videoArray,error:error?)

                    }
                    
                }
                    
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                    completion(results: [], error: error?)

                }
            }
        })
        
        task.resume()
        
    }
    typealias CompleteHandlerBlock = () -> ()
    var handlerQueue: [String : CompleteHandlerBlock]!

    var theObject:YoutubeVideo;
    func downloadVideo(url:NSURL, object:YoutubeVideo) {
        
        theObject = object;
        var request:NSURLRequest = NSURLRequest(URL: url)
        var configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.darkbearinteractive.youtubedownloder")
        
        var backgroundSession = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        var downloadTask = backgroundSession.downloadTaskWithRequest(request)
        downloadTask.resume()
         
        
    }
    //MARK: session delegate
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        println("session error: \(error?.localizedDescription).")
    }
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void) {
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust))
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        println("session \(session) has finished the download task \(downloadTask) of URL \(location).")
        let fileManger = NSFileManager.defaultManager()
        let paths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentsURL = paths[0] as NSURL
        
        
        if let title = theObject.title {
            var theTitle =  title.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            var filename = documentsURL .URLByAppendingPathComponent(theTitle).URLByAppendingPathExtension("mp4")
            
            var error:NSError?
            
            println("moving to documents \(filename)")
            
            if fileManger.moveItemAtURL(location, toURL: filename, error: &error) {
                println("Move successful")
                theObject.localURL = filename.relativePath!
                
                var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                var path = paths.stringByAppendingPathComponent("data.plist")
                var fileManager = NSFileManager.defaultManager()
                if (!(fileManager.fileExistsAtPath(path)))
                {
                    var bundle : NSString = NSBundle.mainBundle().pathForResource("data", ofType: "plist")!
                    fileManager.copyItemAtPath(bundle, toPath: path, error:nil)
                }
                if var array = NSMutableArray(contentsOfFile: path) {
                    array.addObject(theObject)
                    var data = NSKeyedArchiver.archivedDataWithRootObject(array)
                    data.writeToFile(path, atomically: true)
                } else {
                    var array = NSMutableArray()
                    array.addObject(theObject)
                    var data = NSKeyedArchiver.archivedDataWithRootObject(array)
                    data.writeToFile(path, atomically: true)
                }
                
            } else {
                println("Moved failed with error: \(error!.localizedDescription)")
            }
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        println("session \(session) download task \(downloadTask) wrote an additional \(bytesWritten) bytes (total \(totalBytesWritten) bytes) out of an expected \(totalBytesExpectedToWrite) bytes.")
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        println("session \(session) download task \(downloadTask) resumed at offset \(fileOffset) bytes out of an expected \(expectedTotalBytes) bytes.")
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if error == nil {
            println("session \(session) download completed")
        } else {
            println("session \(session) download failed with error \(error?.localizedDescription)")
        }
    }
    
    
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        println("background session \(session) finished events.")
        
        if !session.configuration.identifier.isEmpty {
            callCompletionHandlerForSession(session.configuration.identifier)
        }
    }
    
    //MARK: completion handler
    func addCompletionHandler(handler: CompleteHandlerBlock, identifier: String) {
        handlerQueue[identifier] = handler
    }
    
    func callCompletionHandlerForSession(identifier: String!) {
        var handler : CompleteHandlerBlock = handlerQueue[identifier]!
        handlerQueue!.removeValueForKey(identifier)
        handler()
    }
}

