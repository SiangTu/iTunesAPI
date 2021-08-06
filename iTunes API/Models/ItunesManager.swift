//
//  SearchManager.swift
//  iTunes API
//
//  Created by 杜襄 on 2021/7/15.
//

import UIKit

protocol ItunesManagerDelegate {
    func setItunesMusic(_ itunesMusic: ItunesMusic)
    func failItunesMusic(_ error: String)
}
struct ItunesManager {
    
    var delegate: ItunesManagerDelegate?
    
    func performRequest(keyword: String){
        let url = formatItunesUrl(keyword: keyword)
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data,response,error  in
            if let error = error {
                delegate?.failItunesMusic("Error requesting data, \(error)")
            }else{
                if let safeData = data{
                    self.parseJSON(data: safeData)
                }else{
                    delegate?.failItunesMusic("data is nil")
                }
            }
        }
        task.resume()
    }
    
    func formatItunesUrl(keyword: String) -> URL {
        let formatKeyword = keyword.replacingOccurrences(of: " ", with: "+")
        var urlString = "https://itunes.apple.com/search?term=\(formatKeyword)&media=music&limit=30"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return URL(string: urlString)!
    }
    
    func parseJSON(data: Data) {
        let decoder = JSONDecoder()
        do{
            let itunesData = try decoder.decode(ItunesData.self, from: data)
            if itunesData.resultCount < 1{
                delegate?.failItunesMusic("Error result number is 0")
                return
            }
            for item in itunesData.results{
                let task = URLSession.shared.dataTask(with: item.artworkUrl100) { (data, response, error) in
                    var itunesMusic = ItunesMusic(title: item.trackName,
                                                  artist: item.artistName,
                                                  albumImage: nil,
                                                  previewUrl: item.previewUrl)
                    if let error = error{
                        self.delegate?.failItunesMusic("Error requesting image, \(error)")
                    }else{
                        if let image = UIImage(data: data!){
                            itunesMusic.albumImage = image
                        }else{
                            self.delegate?.failItunesMusic("Error coverting data to UIImage")
                        }
                    }
                    self.delegate?.setItunesMusic(itunesMusic)
                }
                task.resume()
            }
        }catch{
            delegate?.failItunesMusic("Error decoding data, \(error)")
        }
    }
}
