//: Playground - noun: a place where people can play

import UIKit

let url = NSURL(string: "https://itunes.apple.com/us/podcast/the-koy-pond-with-jo-koy/id1092280776?mt=2&i=369797734")
let components = NSURLComponents(URL: url!, resolvingAgainstBaseURL: false)
let queryItems = components?.queryItems
let i = queryItems?.filter({$0.name == "i"}).first
print(i?.value)