//
//  PodcastFeedFinderTests.swift
//  PodcastFeedFinderTests
//
//  Created by Miles Hollingsworth on 6/2/16.
//  Copyright © 2016 Miles Hollingsworth. All rights reserved.
//

import XCTest
@testable import PodcastFeedFinder

class PodcastFeedFinderTests: XCTestCase {
    
    let feedFinder = PodcastFeedFinder()
    let testURL = NSURL(string: "https://Podcast.apple.com/us/podcast/monday-morning-podcast/id480486345?mt=2#episodeGuid=65d71aecadf5018ca01948e5b753980c")!
    let testFeedURL = NSURL(string: "http://billburr.libsyn.com/rss")
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPodcastID() {
        let atpID = feedFinder.getPodcastIDFromURL(testURL)
        XCTAssertEqual(atpID, "480486345")
    }
    
    func testGetFeedURL() {
        let expectation = expectationWithDescription("Getting feed URL for test URL")
        
        feedFinder.getFeedURLForPodcastLink(testURL) { (feedURL) in
            expectation.fulfill()
            
            XCTAssertEqual(feedURL, self.testFeedURL)
        }
        
        waitForExpectationsWithTimeout(5.0) { (error) in
            print(error)
        }
    }
    
    func testMediaURL() {
        let expectation = expectationWithDescription("Getting media URL for test URL")
        
        feedFinder.getMediaURLForPodcastLink(testURL) { (result) in
            expectation.fulfill()
            XCTAssertEqual(result.mediaURL.absoluteString, "http://traffic.libsyn.com/billburr/MMPC_6-27-16.mp3")
            XCTAssertEqual(result.artworkURL.absoluteString, "http://static.libsyn.com/p/assets/4/7/9/b/479b005a1d9a6fe6/Burr_image-062.jpg")
            XCTAssertEqual(result.duration, 4506)
        }
        
        waitForExpectationsWithTimeout(5.0) { (error) in
            print(error)
        }
    }
    
    func testGetFeedByPodcastName() {
        let expectation = expectationWithDescription("Getting feed URL for test URL by podcast name")
        
        feedFinder.getFeedURLForPodcastName("monday-morning-podcast") { (feedURL) in
            expectation.fulfill()
            XCTAssertEqual(feedURL, self.testFeedURL)
        }
        
        waitForExpectationsWithTimeout(5.0) { (error) in
            print(error)
        }
    }
}
