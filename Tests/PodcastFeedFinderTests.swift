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
    let testURL = URL(string: "https://itunes.apple.com/us/podcast/pti/id147232181?mt=2#episodeGuid=http%3A%2F%2Fwww.espn.com%2Fespnradio%2Fpodcast%3Fid%3D19353544")!
    let testFeedURL = URL(string: "http://joeroganexp.joerogan.libsynpro.com/rss")
    
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
        let expectation = self.expectation(description: "Getting feed URL for test URL")
        
        feedFinder.getFeedURLForPodcastLink(testURL) { (feedURL) in
            expectation.fulfill()
            
            XCTAssertEqual(feedURL, self.testFeedURL)
        }
        
        waitForExpectations(timeout: 5.0) { (error) in
            print(error)
        }
    }
    
    func testMediaURL() {
        let expectation = self.expectation(description: "Getting media URL for test URL")
        
        try! feedFinder.getMediaURLForPodcastLink(testURL) { (result) in
            expectation.fulfill()
            XCTAssertEqual(result.mediaURL.absoluteString, "http://play.podtrac.com/espn-pti/c.espnradio.com/s:J1X3L/audio/3352723/pti_2017-05-10-190923.64k.mp3?ad_params=zones%3DPreroll%2CPreroll2%2CMidroll%2CMidroll2%2CMidroll3%2CMidroll4%2CMidroll5%2CMidroll6%2CPostroll%2CPostroll2%7Cstation_id%3D674")
          
            XCTAssertEqual(result.artworkURL.absoluteString, "http://a.espncdn.com/i/espnradio/stations/espn/podcasts/pti_1400.jpg")
          
            XCTAssertEqual(result.duration, 1308.0)
            XCTAssertEqual(result.artist, "PTI")
            XCTAssertEqual(result.title, "All On Harden? : 5/10/17")
        }
        
        waitForExpectations(timeout: 5.0) { (error) in
            print(error)
        }
    }
    
    func testGetFeedByPodcastName() {
        let expectation = self.expectation(description: "Getting feed URL for test URL by podcast name")
        
        feedFinder.getFeedURLForPodcastName("The Joe Rogan Experience") { (feedURL) in
            expectation.fulfill()
            XCTAssertEqual(feedURL, self.testFeedURL)
        }
        
        waitForExpectations(timeout: 5.0) { (error) in
            print(error)
        }
    }
}
