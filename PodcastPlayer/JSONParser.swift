//
//  JSONParser.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 4/24/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation

class JSONParser {
    static func jsonDictionary(with data: Data?) -> JSONDictionary? {
        do {
            if let data = data,
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary {
                return json
            }
        } catch {
            print("Error: Couldn't parse JSON")
        }
        return nil
    }
    
    static func jsonArray(with data: Data?) -> JSONArray? {
        do {
            if let data = data,
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? JSONArray {
                return json
            }
        } catch {
            print("Error: Couldn't parse JSON")
        }
        return nil
    }
}
