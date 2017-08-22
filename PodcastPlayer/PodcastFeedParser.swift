//
//  PodcastFeedParser.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 7/8/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation

class PodcastFeedParser: NSObject {
    fileprivate var tracks = [Track]()
    fileprivate var eName = String()
    fileprivate var title = String()
    fileprivate var publishDateString = String()
    fileprivate var guid = String()
    fileprivate var desc = String()
    fileprivate var url = String()
    fileprivate var duration = String()
    
    func parse(withData data: Data) -> [Track]? {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        guard parser.parserError == nil else {
            return nil
        }
        return self.tracks
    }
}

extension PodcastFeedParser: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        self.eName = elementName
        
        if elementName == "item" {
            self.title = String()
            self.publishDateString = String()
            self.guid = String()
            self.desc = String()
            self.url = String()
            self.duration = String()
        } else if elementName == "enclosure" {
            guard let url = attributeDict["url"] else {
                    return
            }
            self.url = url
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            guard let publishDate = self.publishDateString.toDate(withFormat: "E, d MMM yyyy HH:mm:ss z"),
                !self.guid.isEmpty,
                !self.title.isEmpty,
                !self.url.isEmpty,
                !self.desc.isEmpty,
                !self.duration.isEmpty else {
                    print("Missing required attributes for Track.")
                    return
            }
            
            let track = Track(guid: self.guid,
                              name: self.title,
                              publishDate: publishDate,
                              url: self.url,
                              desc: self.desc,
                              duration: self.duration)
            self.tracks.append(track)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if self.eName == "title" {
            self.title += trimmedString
        } else if eName == "pubDate" {
            self.publishDateString += trimmedString
        } else if eName == "guid" {
            self.guid += trimmedString
        } else if eName == "description" {
            self.desc += trimmedString
        } else if eName == "itunes:duration" {
            self.duration += trimmedString
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        let parseNSError = parseError as NSError
        print(parseNSError.userInfo)
        print(parseError.localizedDescription)
    }
}
