//
//  PodcastFeedFinder.swift
//  PodcastFeedFinder
//
//  Created by Miles Hollingsworth on 6/2/16.
//  Copyright © 2016 Miles Hollingsworth. All rights reserved.
//

import Foundation
import Alamofire
import Fuzi

typealias FeedFinderCompletion = (NSURL -> ())

public struct PodcastFeedFinderResult {
    public let mediaURL: NSURL
    public let artworkURL: NSURL
    public let duration: NSTimeInterval
    public let artist: String
    public let title: String
}

public enum FeedFinderError: ErrorType {
    case PodcastNotFoundByName
    case PodcastNotFoundByID
    case PodcastIDNotFound
    case EpisodeGUIDNotFound
    case AlamofireError(NSError)
}

public class PodcastFeedFinder {
    public static let sharedFinder = PodcastFeedFinder()
    
    func getFeedURLForPodcastLink(link: NSURL, completion: (NSURL -> ())) {
        if let podcastID = try? getPodcastIDFromURL(link) {
            getFeedURLForID(podcastID, completion: completion)
        } else if let podcastName = link.URLByDeletingLastPathComponent?.lastPathComponent {
            getFeedURLForPodcastName(podcastName, completion: completion)
        }
    }
    
    public func getMediaURLForPodcastLink(link: NSURL, completion: (PodcastFeedFinderResult -> ())) throws {
        let components = NSURLComponents(URL: link, resolvingAgainstBaseURL: false)
        guard let fragment = components?.fragment where fragment.hasPrefix("episodeGuid")  else {
            print("No episode guid in link")
            return
        }
        
        let episodeGuid = fragment.substringFromIndex(fragment.startIndex.advancedBy("episodeGuid=".characters.count))
        
        getFeedURLForPodcastLink(link) { (feedURL) in
            Alamofire.request(.GET, feedURL.absoluteString).response(completionHandler: { (request, response, data, error) in
                let feed = try! XMLDocument(data: data!)

                if let itemNode = feed.firstChild(xpath: "*/item[guid = '\(episodeGuid)']"),
                    mediaURLString = itemNode.firstChild(xpath: "enclosure")?.attr("url"),
                    mediaURL = NSURL(string: mediaURLString),
                    artworkURLString = (itemNode.firstChild(css: "itunes:image") ?? feed.firstChild(css: "itunes:image")!).attr("href"),
                    artworkURL = NSURL(string: artworkURLString),
                    durationString = itemNode.firstChild(xpath: "itunes:duration")?.stringValue,
                    artist = feed.firstChild(xpath: "channel/title")?.stringValue,
                    title = itemNode.firstChild(xpath: "title")?.stringValue
                {
                    let durationComponents = durationString.componentsSeparatedByString(":")
                    let duration = durationComponents.enumerate().reduce(NSTimeInterval(0), combine: { (acc, value) -> NSTimeInterval in
                        return acc + NSTimeInterval(value.element)!*pow(60, Double(durationComponents.count-value.index-1))
                    })
                    
                    completion(PodcastFeedFinderResult(mediaURL: mediaURL, artworkURL: artworkURL, duration: duration, artist: artist, title: title))
                }
            })
        }
    }
    
    internal func getPodcastIDFromURL(url: NSURL) throws -> String {
        if let lastComponent = url.lastPathComponent {
            return lastComponent.substringFromIndex(lastComponent.startIndex.advancedBy(2))
        }
        
        throw FeedFinderError.PodcastIDNotFound
    }
    
    internal func getFeedURLForID(podcastID: String, completion: FeedFinderCompletion) {
         Alamofire.request(.GET, "https://itunes.apple.com/lookup", parameters: ["id": podcastID], encoding: .URL, headers: nil).responseJSON { (response) in
            switch response.result {
            case .Success(let JSON):
                if let result = (JSON["results"] as? NSArray)?.firstObject as? NSDictionary, feedURLString = result["feedUrl"] as? String, feedURL = NSURL(string: feedURLString) {
                    completion(feedURL)
                }
                
            case .Failure:
                print("ERROR")
           }
        }
    }
    
    internal func getFeedURLForPodcastName(name: String, completion: FeedFinderCompletion) {
        Alamofire.request(.GET, "https://itunes.apple.com/search", parameters: ["term": name], encoding: .URL, headers: nil).responseJSON { (response) in
            switch response.result {
            case .Success(let JSON):
                if let results = JSON["results"] as? [NSDictionary], result = results.filter({ $0["kind"] as? String == "podcast" }).first, feedURLString = result["feedUrl"] as? String, feedURL = NSURL(string: feedURLString) {
                    completion(feedURL)
                } else {
                    
                }
                
            case .Failure:
                print("ERROR")
            }
        }
    }
}