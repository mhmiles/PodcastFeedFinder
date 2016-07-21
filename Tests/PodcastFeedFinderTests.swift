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
            XCTAssertEqual(result.mediaURL.absoluteString, "http://c.espnradio.com/s:J1X3L/audio/2880082/fivethirtyeightelections_2016-07-21-000322.64k.mp3?ad_params=zones%3DPreroll%2CPreroll2%2CMidroll%2CMidroll2%2CMidroll3%2CMidroll4%2CMidroll5%2CMidroll6%2CPostroll%2CPostroll2%7Cstation_id%3D4278")
            XCTAssertEqual(result.artworkURL.absoluteString, "http://a.espncdn.com/combiner/i?img=i/espnradio/logos/538_elections_1x1.png?w=1400&h=1400")
            XCTAssertEqual(result.duration, 863)
            XCTAssertEqual(result.artist, "FiveThirtyEight Elections")
            XCTAssertEqual(result.title, "RNC Emergency Pod! Boos Cruz: 7/20/16")
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
