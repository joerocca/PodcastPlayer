//
//  ParsePodcastTracksOperation.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 5/9/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation

class ParsePodcastTracksOperation: Operation {
    var tracks = [Track]()
    var eName = String()
    var title = String()
    var publishDate = String()
    var guid = String()
    var desc = String()
    var url = String()
    var duration = String()
    
    override func main() {
        guard let dataProvider = self.dependencies
            .filter({$0 is FetchPodcastTracksOperation})
            .first as? FetchPodcastTracksOperation,
            let data = dataProvider.data else {
                
                fatalError()
        }
        
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
    }
}

extension ParsePodcastTracksOperation: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        self.eName = elementName
        
        if elementName == "item" {
            title = String()
            publishDate = String()
            guid = String()
            desc = String()
            url = String()
            duration = String()
        } else if elementName == "enclosure" {
            guard let url = attributeDict["url"],
                let duration = attributeDict["length"] else {
                    return
            }
            self.url = url
            self.duration = duration
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let track = Track(guid: self.guid,
                              name: self.title,
                              publishDate: self.publishDate,
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
            self.publishDate += trimmedString
        } else if eName == "guid" {
            self.guid += trimmedString
        } else if eName == "description" {
            self.desc += trimmedString
        }
    }
}
