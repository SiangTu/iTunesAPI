//
//  ResultViewController.swift
//  iTunes API
//
//  Created by 杜襄 on 2021/7/15.
//

import UIKit
import AVFoundation

class ResultViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var keyword: String? = "bring me"
    var itunesManager = ItunesManager()
    var itunesTracks: [ItunesMusic] = []
    var errorMessage: String?
    var playingPlayer: AVPlayer?
    var cellSelected: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        itunesManager.delegate = self
        itunesManager.performRequest(keyword: keyword!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        playingPlayer?.pause()
    }
    
    
    
}

extension ResultViewController: ItunesManagerDelegate{
    
    func setItunesMusic(_ itunesMusic: ItunesMusic) {
        itunesTracks.append(itunesMusic)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func failItunesMusic(_ error: String) {
        print(error)
    }
    
}

extension ResultViewController: UITableViewDataSource, TableViewCellDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! TableViewCell
        
        if itunesTracks.count > indexPath.row{
            let itunesMusic = itunesTracks[indexPath.row]
            cell.titleLabel.text = itunesMusic.title
            cell.artistLabel.text = itunesMusic.artist
            cell.albumImageView.image = itunesMusic.albumImage
            //  根據是否正在播放該項，顯示按鈕
            if tableView.cellForRow(at: indexPath)?.isSelected == true{
                cellSelected = indexPath
                cell.pauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                cell.delegate = self
            }else{
                cell.pauseButton.setImage(nil, for: .normal)
            }
        }
        return cell
    }
    
    func pauseMusic() {
        playingPlayer?.pause()
    }
    
}

extension ResultViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cellSelected = cellSelected{
            tableView.reloadRows(at: [indexPath, cellSelected], with: .none)
        }else{
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        if let playingPlayer = playingPlayer {
              playingPlayer.pause()
            }
        let url = itunesTracks[indexPath.row].previewUrl
        playingPlayer = AVPlayer(url: url)
        playingPlayer?.play()
    }
}
