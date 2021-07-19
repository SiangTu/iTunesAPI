//
//  ItunesData.swift
//  iTunes API
//
//  Created by 杜襄 on 2021/7/15.
//

import Foundation

struct ItunesData: Decodable {
   var resultCount: Int
   var results: [Song]
}

struct Song: Decodable {
      var artistName: String
      var trackName: String
      var previewUrl: URL
      var artworkUrl100: URL
}

