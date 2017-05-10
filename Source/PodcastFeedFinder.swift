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

typealias FeedFinderCompletion = ((URL) -> ())

public struct PodcastFeedFinderResult {
    public let mediaURL: URL
    public let artworkURL: URL
    public let duration: TimeInterval
    public let artist: String
    public let title: String
}

public enum FeedFinderError: Error {
    case podcastNotFoundByName
    case podcastNotFoundByID
    case podcastIDNotFound
    case episodeGUIDNotFound
    case alamofireError(NSError)
}

open class PodcastFeedFinder {
    open static let sharedFinder = PodcastFeedFinder()
    
    func getFeedURLForPodcastLink(_ link: URL, completion: @escaping ((URL) -> ())) {
        if let podcastID = try? getPodcastIDFromURL(link) {
            getFeedURLForID(podcastID, completion: completion)
        } else {
            let podcastName = link.deletingLastPathComponent().lastPathComponent
            getFeedURLForPodcastName(podcastName, completion: completion)
        }
    }

    open func getMediaURLForPodcastLink(_ link: URL, completion: @escaping ((PodcastFeedFinderResult) -> ())) throws {
        let components = URLComponents(url: link, resolvingAgainstBaseURL: false)
        guard let fragment = components?.fragment , fragment.hasPrefix("episodeGuid")  else {
            print("No episode guid in link")
            return
        }
        
        let episodeGuid = fragment.substring(from: fragment.characters.index(fragment.startIndex, offsetBy: "episodeGuid=".characters.count))
        
        getFeedURLForPodcastLink(link) { (feedURL) in
            Alamofire.request(feedURL, method: .get).responseData(completionHandler: { (response) in
                guard let data = response.data else {
                    print("Feed fetching error")
                    return
                }
                
                let feed = try! XMLDocument(data: data)
                
                if let itemNode = feed.firstChild(xpath: "*/item[guid = '\(episodeGuid)']"),
                    let mediaURLString = itemNode.firstChild(xpath: "enclosure")?.attr("url"),
                    let mediaURL = URL(string: mediaURLString),
                    let artworkURLString = (itemNode.firstChild(css: "itunes:image") ?? feed.firstChild(css: "itunes:image")!).attr("href"),
                    let artworkURL = URL(string: artworkURLString),
                    let durationString = itemNode.firstChild(xpath: "itunes:duration")?.stringValue,
                    let artist = feed.firstChild(xpath: "channel/title")?.stringValue,
                    let title = itemNode.firstChild(xpath: "title")?.stringValue
                {
                    let durationComponents = durationString.components(separatedBy: ":")
                    let duration = durationComponents.enumerated().reduce(TimeInterval(0), { (acc, value) -> TimeInterval in
                        return acc + TimeInterval(value.element)!*pow(60, Double(durationComponents.count-value.offset-1))
                    })
                    
                    completion(PodcastFeedFinderResult(mediaURL: mediaURL, artworkURL: artworkURL, duration: duration, artist: artist, title: title))
                }
                
            })
        }
    }
    
    internal func getPodcastIDFromURL(_ url: URL) throws -> String {
        let lastComponent = url.lastPathComponent
        
        if lastComponent.hasPrefix("id") {
            return lastComponent.substring(from: lastComponent.characters.index(lastComponent.startIndex, offsetBy: 2))
        }
        
        throw FeedFinderError.podcastIDNotFound
    }
    
    internal func getFeedURLForID(_ podcastID: String, completion: @escaping FeedFinderCompletion) {
        Alamofire.request("https://itunes.apple.com/lookup", method: .get, parameters: ["id": podcastID]).responseJSON { (response) in
            switch response.result {
            case .success(let JSON as [String: Any]):
                if let result = (JSON["results"] as? NSArray)?.firstObject as? NSDictionary, let feedURLString = result["feedUrl"] as? String, let feedURL = URL(string: feedURLString) {
                    completion(feedURL)
                }
                
            case .failure:
                print("ERROR")
            default:
                abort()
           }
        }
    }
    
    internal func getFeedURLForPodcastName(_ name: String, completion: @escaping FeedFinderCompletion) {
      let parameters = [
        "term": name,
        "media": "podcast"
        ]
      
        Alamofire.request("https://itunes.apple.com/search", method: .get,
                          parameters: parameters).responseJSON { (response) in
            switch response.result {
            case .success(let JSON as [String: Any]):
                if let results = JSON["results"] as? [NSDictionary], let result = results.filter({ $0["kind"] as? String == "podcast" }).first, let feedURLString = result["feedUrl"] as? String, let feedURL = URL(string: feedURLString) {
                    completion(feedURL)
                } else {
                    
                }
                
            case .failure:
                print("ERROR")
                
            default:
                abort()
            }
        }
    }
}
