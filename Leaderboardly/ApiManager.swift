//
//  ApiManager.swift
//  Leaderboardly
//
//  Created by Simon Bromberg on 2020-01-30.
//  Copyright © 2019 SBromberg. All rights reserved.
//

import Foundation

class ApiManager {
	private var baseURL = "https://millie.global/api/v1/"
	
    private let defaultSession = URLSession(configuration: .default)
    private let apiKey = "VVGIB2MJKUW26bFzY54mKISdnBWAtrmA"
    
	static var shared = ApiManager()

	enum Endpoint: String {
		case leaderboard
	}

	private var dataTask: URLSessionDataTask?

    enum ApiManagerError: Error {
        case invalidBaseURL
        case noData(Error?)
        case decodingFailure(Error?)
    }

    func getLeaderboard(_ completion: @escaping (_ scores: [LeaderboardEntry]?, _ error: ApiManagerError?) -> Void) {
		guard var url = URL(string: baseURL) else {
            completion(nil, .invalidBaseURL)
            return
        }
        url.appendPathComponent(Endpoint.leaderboard.rawValue)

        // Cancel any previously running tasks
        dataTask?.cancel()

        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "X-ApiKey")

		dataTask = defaultSession.dataTask(with: request) { data, response, error in
			guard let data = data else {
                completion(nil, .noData(error))
                return
            }
            
			var scores: [LeaderboardEntry]?

			do {
                scores = try JSONDecoder().decode([LeaderboardEntry].self, from: data)
                completion(scores, nil)
			} catch {
                print(error)
                completion(nil, .decodingFailure(error))
            }
		}

		dataTask?.resume()
	}

    func getImageData(with url: URL, completion: @escaping (_ image: Data?, _ error: ApiManagerError?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                completion(data, nil)
            } else {
                completion(nil, .noData(error))
            }
        }

        task.resume()

        return task
    }
}
