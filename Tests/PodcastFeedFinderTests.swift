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
    let testURL = NSURL(string: "https://itunes.apple.com/us/podcast/truehoop/id974354079?mt=2#episodeGuid=http%3A%2F%2Fwww.espn.com%2Fespnradio%2Fpodcast%2F_%2Fid%2F17204351")!
    let testFeedURL = NSURL(string: "http://www.espn.com/espnradio/podcast/feeds/itunes/podCast?id=12426375")
    
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
        XCTAssertEqual(atpID, "974354079")
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
            XCTAssertEqual(result.mediaURL.absoluteString, "http://play.podtrac.com/espn-truehoop/c.espnradio.com/s:J1X3L/audio/2908650/truehooptv_2016-08-02-181350.64k.mp3?ad_params=zones%3DPreroll%2CPreroll2%2CMidroll%2CMidroll2%2CMidroll3%2CMidroll4%2CMidroll5%2CMidroll6%2CPostroll%2CPostroll2%7Cstation_id%3D2776")
            XCTAssertEqual(result.artworkURL.absoluteString, "http://a2.espncdn.com/combiner/i?img=i/espnradio/logos/truehoop_1x1.png?w=1400&h=1400")
            XCTAssertEqual(result.duration, 3187.0)
            XCTAssertEqual(result.artist, "TrueHoop")
            XCTAssertEqual(result.title, "Refresh Memory: Part 1: 8/3/16")
        }
        
        waitForExpectationsWithTimeout(5.0) { (error) in
            print(error)
        }
    }
    
    func testGetFeedByPodcastName() {
        let expectation = expectationWithDescription("Getting feed URL for test URL by podcast name")
        
        feedFinder.getFeedURLForPodcastName("TrueHoop") { (feedURL) in
            expectation.fulfill()
            XCTAssertEqual(feedURL, self.testFeedURL)
        }
        
        waitForExpectationsWithTimeout(5.0) { (error) in
            print(error)
        }
    }
}
