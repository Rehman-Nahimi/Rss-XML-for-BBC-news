//
//  APIservice.swift
//  BBC RSS view app
//
//  Created by Ray Nahimi on 9/05/2024.
//

import Foundation
import FeedKit

struct Item: Identifiable {
    var id: UUID = UUID()
    var title: String?
    var description: String?
    var link: String?
    var pubDate: Date?
    var img: String?
}

class ApiService {
  func getItems(from endpoint: String = "https://feeds.bbci.co.uk/news/rss.xml", completion: @escaping (Result<[Item], Error>) -> Void) throws {
    guard let url = URL(string: endpoint) else { throw TSError.invalidURL }

    let parser = FeedParser(URL: url)
    parser.parseAsync { result in
      switch result {
      case .success(let feed):
        guard let rssFeed = feed.rssFeed else {
          completion(.failure(TSError.invalidResponse))
          return
        }

        let items: [Item] = rssFeed.items?.map({ rssFeedItem in
          Item(title: rssFeedItem.title,
               description: rssFeedItem.description,
               link: rssFeedItem.link,
               pubDate: rssFeedItem.pubDate,
               img: rssFeedItem.media?.mediaThumbnails?.first?.attributes?.url)
        }) ?? []
        completion(.success(items))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  enum TSError: Error{
    case invalidURL
    case invalidResponse
  }
}
