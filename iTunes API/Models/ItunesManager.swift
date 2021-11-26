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
        let config = URLSessionConfiguration.default
//        config.timeoutIntervalForRequest = 10
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: url) { data,response,error  in
            if error != nil {
                delegate?.failItunesMusic("網路連線錯誤")
            }else{
                if let safeData = data{
                    self.parseJSON(data: safeData)
                }else{
                    delegate?.failItunesMusic("網路連線錯誤")
                    print("response data is nil")
                }
            }
        }
        task.resume()
    }
    
    func formatItunesUrl(keyword: String) -> URL {
        var formatKeyword = keyword.trimmingCharacters(in: .whitespaces)
        formatKeyword = formatKeyword.replacingOccurrences(of: " ", with: "+")
        var urlString = "https://itunes.apple.com/search?term=\(formatKeyword)&media=music&limit=30"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return URL(string: urlString)!
    }
    
    func parseJSON(data: Data) {
        let decoder = JSONDecoder()
        do{
            let itunesData = try decoder.decode(ItunesData.self, from: data)
            if itunesData.resultCount < 1{
                delegate?.failItunesMusic("搜尋不到相關結果")
                return
            }
            for item in itunesData.results{
                let task = URLSession.shared.dataTask(with: item.artworkUrl100) { (data, response, error) in
                    var itunesMusic = ItunesMusic(title: item.trackName,
                                                  artist: item.artistName,
                                                  albumImage: nil,
                                                  previewUrl: item.previewUrl)
                    if let error = error{
                        print("Error coverting data to UIImage \(error)")
                    }else{
                        if let image = UIImage(data: data!){
                            itunesMusic.albumImage = image
                        }else{
                            print("Error coverting data to UIImage")
                        }
                    }
                    self.delegate?.setItunesMusic(itunesMusic)
                }
                task.resume()
            }
        }catch{
            delegate?.failItunesMusic("資料存取錯誤")
        }
    }
}
