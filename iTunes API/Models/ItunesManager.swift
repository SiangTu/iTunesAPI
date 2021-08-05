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
        print(url)
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data,response,error  in
            if let error = error {
                delegate?.failItunesMusic("Error requesting data, \(error)")
            }else{
                if let safeData = data{
                    self.parseJSON(data: safeData)
                }
            }
        }
        task.resume()
    }
    
    func parseJSON(data: Data) {
        let decoder = JSONDecoder()
        do{
            let itunesData = try decoder.decode(ItunesData.self, from: data)
            if itunesData.resultCount > 0{
                for item in itunesData.results{
                    let title = item.trackName
                    let artist = item.artistName
                    let previewUrl = item.previewUrl
                    let imageUrl = item.artworkUrl100
                    let task = URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                        if let error = error{
                            print(error)
                            self.delegate?.failItunesMusic("圖片載入錯誤")
                            let itunesMusic = ItunesMusic(title: title, artist: artist, albumImage: nil, previewUrl: previewUrl)
                            self.delegate?.setItunesMusic(itunesMusic)
                        }else{
                            if let image = UIImage(data: data!){
                                let itunesMusic = ItunesMusic(title: title, artist: artist, albumImage: image, previewUrl: previewUrl)
                                self.delegate?.setItunesMusic(itunesMusic)
                            }
                        }
                    }
                    task.resume()
                }
            }else{
                delegate?.failItunesMusic("找不到結果")
            }
        }catch{
            delegate?.failItunesMusic("Error decoding data, \(error)")
        }
    }
    
    func formatItunesUrl(keyword: String) -> URL {
        var formatKeyword = ""
        let splitKeywordArray = keyword.split(separator: " ")
        for splitKeyword in splitKeywordArray{
            if splitKeyword != splitKeywordArray[0]{
                formatKeyword += "+"
            }
            formatKeyword += splitKeyword
        }
        var urlString = "https://itunes.apple.com/search?term=\(formatKeyword)&media=music&limit=30"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return URL(string: urlString)!
    }
}
