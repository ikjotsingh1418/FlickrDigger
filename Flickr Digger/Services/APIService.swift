//
//  APIService.swift
//  Flickr Digger
//
//  Created by Ikjot Singh on 9/1/19.
//   .
//

import Foundation

// MARK:- Emum
// Custom error enumerator to be returned in case of error in network call
enum APIError : String {
    case noNetwork = "No Internet Connection"
    case reqTimedOut = "Request Timed out"
    case someError = "OOPS! Some error occured"
}

// MARK:- Protocol
protocol APIServiceProtocol {
    func fetchPhotosForSearchKeyword(keyword : String, forPage page: Double, completion : @escaping (_ success: Bool, _ photos: Photos?, _ error: APIError? ) -> () )
}


class APIService : APIServiceProtocol {
    // MARK:- Network Call
    func fetchPhotosForSearchKeyword(keyword: String, forPage page: Double, completion: @escaping (Bool, Photos?, APIError?) -> ()) {
        // parameters for URL creation
        let parameters = ["api_key" :constants.APIDetails.FlickerAPIKey,
                          "method"  :constants.APIDetails.FlickerAPIMethod,
                          "per_page"  :constants.APIDetails.PhotosPerRequest,
                          "text"  :keyword,
                          "format"  :"json",
                          "page"  :page,
                          "nojsoncallback" : 1] as [String : Any]
        
        // createURLFromParameters returns the URL formed with aforementioned keys and values
        guard let url = createURLFromParameters(parameters: parameters) else { return }
        
        // data task called
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else{
                let errorStr = APIService.getAPIErrorForErrorCode(code: error?.code)
                OperationQueue.main.addOperation({
                completion(false,nil,errorStr)
                })
                return
            }
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let flickrData = try decoder.decode(ParentModel.self, from: data)
                print(flickrData)
                OperationQueue.main.addOperation({
                completion(true,flickrData.photos,nil)
                })
            } catch let err {
                print("Error", err)
                completion(false,nil,nil)
               
            }
        }.resume()
    }
    
    // MARK:- Helping methods
    private func createURLFromParameters(parameters: [String : Any]) -> URL? {
        var components = URLComponents()
        components.scheme = constants.APIDetails.APIScheme
        components.host = constants.APIDetails.APIHost
        components.path = constants.APIDetails.APIPath
        
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url
    }
    
    static func getAPIErrorForErrorCode(code: Int?) -> APIError {
        switch code {
        case -1001 : return APIError.reqTimedOut
        case -1009 : return APIError.noNetwork
        default : return APIError.someError
        }
    }

    
}

// MARK:- Extentions

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}
