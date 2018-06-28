//
//  PoliceAPI.swift
//  GeoCrimes
//
//  Created by Jovito Royeca on 28/06/2018.
//  Copyright © 2018 Jovito Royeca. All rights reserved.
//

import UIKit
import CoreLocation
import PromiseKit

/*
 * The Police API caller.
 */
class PoliceAPI: NSObject {
    
    /*
     * Calls the API, calls inserting of JSON into Core Data, then fetches and returns results via Promises.
     */
    func searchCrimes(onYear year: Int, onMonth month: Int, atLatitude latitude: CLLocationDegrees, atlongitude longitude: CLLocationDegrees) -> Promise<[Crime]?> {
        return Promise { seal in
            guard let urlString = "https://data.police.uk/api/crimes-at-location?date=\(year)-\(month < 10 ? "0" : "")\(month)&lat=\(latitude)&lng=\(longitude)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                let url = URL(string: urlString) else {
                let error = NSError(domain: NSURLErrorDomain, code: 305, userInfo: [NSLocalizedDescriptionKey: "BaD URL"])
                seal.reject(error)
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            firstly {
                URLSession.shared.dataTask(.promise, with: request)
            }.compactMap {
                try JSONSerialization.jsonObject(with: $0.data) as? [[String: Any]]
            }.then { json in
                CoreDataAPI.sharedInstance.saveQueryResults(json: json)
            }.done {
                let crimes = CoreDataAPI.sharedInstance.fetchCrimes()
                seal.fulfill(crimes)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
}
