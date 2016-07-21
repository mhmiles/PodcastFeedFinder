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
    let testURL = NSURL(string: "https://itunes.apple.com/us/podcast/fivethirtyeight-elections/id1077418457?mt=2#episodeGuid=http%3A%2F%2Fespn.go.com%2Fespnradio%2Fpodcast%2F_%2Fid%2F17117009")!
    let testFeedURL = NSURL(string: "http://espn.go.com/espnradio/podcast/feeds/itunes/podCast?id=14554755")
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPodcastID() {
        let atpID = try! feedFinder.getPodcastIDFromURL(testURL)
        XCTAssertEqual(atpID, "1077418457")
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
        
        try! feedFinder.getMediaURLForPodcastLink(testURL) { (result) in
            expectation.fulfill()
            XCTAssertEqual(result.mediaURL.absoluteString, "http://traffic.libsyn.com/billburr/MMPC_6-27-16.mp3")
            XCTAssertEqual(result.artworkURL.absoluteString, "http://static.libsyn.com/p/assets/4/7/9/b/479b005a1d9a6fe6/Burr_image-062.jpg")
            XCTAssertEqual(result.duration, 4506)
            XCTAssertEqual(result.artist, "Monday Morning Podcast")
            XCTAssertEqual(result.title, "Monday Morning Podcast 6-27-16")
        }
        
        waitForExpectationsWithTimeout(5.0) { (error) in
            print(error)
        }
    }
    
    func testGetFeedByPodcastName() {
        let expectation = expectationWithDescription("Getting feed URL for test URL by podcast name")
        
        feedFinder.getFeedURLForPodcastName("fivethirtyeight-elections") { (feedURL) in
            expectation.fulfill()
            XCTAssertEqual(feedURL, self.testFeedURL)
        }
        
        waitForExpectationsWithTimeout(5.0) { (error) in
            print(error)
        }
    }
}
