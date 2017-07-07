//
//  iTunesClient.swift
//  PodcastPlayer
//
//  Created by Joe Rocca on 7/6/17.
//  Copyright © 2017 Joe Rocca. All rights reserved.
//

import Foundation

class iTunesClient {
    //MARK: Enums
    enum Result {
        case failed(Error?)
        case success([Podcast])
    }
    
    //MARK: Properties
    private let apiClient: APIClient
    private weak var currentSearchOperation: URLSessionTaskOperation?
    
    //MARK: Initialization
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    //MARK: Workers
    func searchPodcasts(withQuery query: String, completion: @escaping (Result) -> ()) {
        self.cancelCurrentSearchOperation()
        
        let mainCompletion: (Result) -> Void = { (result: Result) in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        guard let urlEncodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            let url = URL(string: "https://itunes.apple.com/search?term=\(urlEncodedQuery)&entity=podcast") else {
                fatalError()
        }
        
        let urlRequest = URLRequest(url: url)
        self.currentSearchOperation = apiClient.request(urlRequest, priority: .veryHigh) { (data, response, error) in

            guard let data = data,
                let json = JSONParser.jsonDictionary(with: data),
                let podcastDicts = json["results"] as? [[String: Any]] else {
                    mainCompletion(.failed(error))
                    return
            }
            
            var podcasts = [Podcast]()
            for podcastDict in podcastDicts {
                guard let podcast = Podcast.fromJSON(json: podcastDict) else {
                    print("Error parsing Podcast")
                    continue
                }
                podcasts.append(podcast)
            }
            
            mainCompletion(.success(podcasts))
        }
    }
    
    //MARK: Helpers
    func cancelCurrentSearchOperation() {
        self.currentSearchOperation?.cancel()
    }
}
