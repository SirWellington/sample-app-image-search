//
//  Networking.swift
//  ModernImageSearchUIKit
//
//  Created by Wellington Moreno on 1/21/26.
//

import Foundation

protocol ImageSearchAPI {
    func searchImages(
        request: ImageSearchRequest
    ) async throws -> ImageSearchResponse
}

//======================================
// MARK: Request / Response
//======================================
struct ImageSearchRequest {
    var query: String = ""
    var page: Int = 1
}

struct ImageSearchResponse {
    var images: [Image] = []
    var nextPage: Int? = nil
    var totalResults: Int = 0
}

enum NetworkingError: Error {
    case invalidRequest(message: String)
    case jsonDecodeError(Error)
    case operationError(message: String)
}

//======================================
// MARK: Pexels
//======================================
class PexelsAPI: ImageSearchAPI {
    private let session: URLSession
    
    let jsonDecoder = JSONDecoder()
    
    init(session: URLSession = .shared) {
        self.session = session
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func searchImages(
        request: ImageSearchRequest
    ) async throws -> ImageSearchResponse {
        guard !request.query.isEmpty else {
            throw NetworkingError.invalidRequest(
                message: "query cannot be empty"
            )
        }
        
        guard let request = PexelsURL.searchImage(
            query: request.query,
            page: request.page
        ).request else {
            throw NetworkingError.operationError(
                message: "could not create a request"
            )
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let http = (response as? HTTPURLResponse) else {
            throw NetworkingError.operationError(
                message: "did not receive http response"
            )
        }
        
        guard http.statusCode == 200 else {
            let message = "w: HTTP Status code is \(http.statusCode)"
            print(message)
            throw NetworkingError.operationError(message: message)
        }
        
        let pexelsResponse: PexelsSearchResponse
        do {
            pexelsResponse = try jsonDecoder.decode(
                PexelsSearchResponse.self,
                from: data
            )
        } catch {
            throw NetworkingError.jsonDecodeError(error)
        }
        return ImageSearchResponse(pexelsResponse)
    }
    
}

//======================================
// MARK: Pexels Request Object
//======================================
extension PexelsAPI {
    struct PexelsSearchRequest {
        /// The search query. Ocean, Tigers, Pears, etc.
        var query: String = ""
        /// Desired photo orientation. The current supported orientations are: landscape, portrait or square.
        var orientation: Orientation? = nil
        /// The page number you are requesting. Default: 1
        var page: Int = 1
        /// The number of results you are requesting per page. Default: 15 Max: 80
        var perPage: Int = 20
    }
    
    enum Orientation: Codable {
        case portrait
        case landscape
        case square
    }
}

//======================================
// MARK: Pexels Response Object
//======================================
extension PexelsAPI {
    struct PexelsSearchResponse: Codable {
        let page: Int
        let perPage: Int
        let photos: [PexelPhoto]
        let totalResults: Int
        let nextPage: String
        
        struct PexelPhoto: Codable {
            let id: Int
            let height: Int
            let width: Int
            let photographer: String
            let photographerId: Int
            let url: String
            let src: Variations
            let alt: String
            
            struct Variations: Codable {
                let original: String
                let large: String
                let medium: String
                let small: String
                let portrait: String
                let landscape: String
                let tiny: String
            }
        }
    }
}

//======================================
// MARK: Pexels URL
//======================================
extension PexelsAPI {
    enum PexelsURL {
        static let mainAPI = "https://api.pexels.com/v1"
        static let searchAPI = "\(mainAPI)/search"
        
        case searchImage(query: String, page: Int)
        
        var request: URLRequest? {
            switch self {
            case .searchImage(let query, let page):
                guard var urlComponents = URLComponents(string: Self.searchAPI) else {
                    print("w: could not generated a URLComponent")
                    return nil
                }
                
                urlComponents.queryItems = [
                    URLQueryItem(name: "query", value: query),
                    URLQueryItem(name: "page", value: String(page))
                ]
                guard let url = urlComponents.url else {
                    print("w: could not generate URL from \(urlComponents)")
                    return nil
                }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.addValue(
                    AppSecrets.pexelsApiKey,
                    forHTTPHeaderField: "Authorization"
                )
                return request
            }
        }
    }
}

//======================================
// MARK: Mapping
//======================================
extension ImageSearchResponse {
    init(_ pexels: PexelsAPI.PexelsSearchResponse) {
        images = pexels.photos.compactMap {
            Image($0)
        }
        totalResults = pexels.totalResults
    }
}
extension Image {
    init?(_ pexels: PexelsAPI.PexelsSearchResponse.PexelPhoto) {
        guard let smallUrl = URL(string: pexels.src.small) else { return nil }
        guard let fullUrl = URL(string: pexels.src.original) else { return nil }
        id = String(pexels.id)
        thumbnailURL = smallUrl
        fullSizeURL = fullUrl
        size = CGSize(
            width: CGFloat(pexels.width),
            height: CGFloat(pexels.height)
        )
    }
}
