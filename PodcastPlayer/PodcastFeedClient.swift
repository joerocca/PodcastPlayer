//
//  PodcastFeedClient.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 7/8/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation

struct PodcastFeedClient {
    //MARK: Enums
    enum Result {
        case failed(Error?)
        case success([Track])
    }
    
    //MARK: Properties
    private let apiClient: APIClient
    
    //MARK: Initialization
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    //MARK: Workers
    func requestFeed(withFeed feedUrl: URL, completion: @escaping (Result) -> ()) {
        let mainCompletion: (Result) -> Void = { (result: Result) in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let urlRequest = URLRequest(url: feedUrl)
        self.apiClient.request(urlRequest, priority: .veryHigh) { (data, response, error) in
            guard let data = data,
                error == nil else {
                mainCompletion(.failed(error))
                return
            }
            let feedParser = PodcastFeedParser()
            let tracks = feedParser.parse(data: data)
            mainCompletion(.success(tracks))
        }
    }
}
