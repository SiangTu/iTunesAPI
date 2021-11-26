//
//  ResultViewController.swift
//  iTunes API
//
//  Created by 杜襄 on 2021/7/15.
//

import UIKit
import AVFoundation

class ResultViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    
    private var keyword: String?
    private var itunesManager = ItunesManager()
    private var itunesTracks: [ItunesMusic] = []
    private var cellSelected: IndexPath?
    var playingPlayer: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        itunesManager.delegate = self
        configureTableView()
    }
    
    @IBAction func viewdidTapped(_ sender: Any) {
        view.endEditing(true)
    }
    
    func configureTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
        tableView.isHidden = true
    }

    
}

extension ResultViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != ""{
            keyword = searchBar.text
            itunesTracks = []
            itunesManager.performRequest(keyword: keyword!)
            activityIndicator.startAnimating()
            errorLabel.isHidden = true
            tableView.isHidden = true
        }
        searchBar.endEditing(true)
        view.gestureRecognizers![0].isEnabled = false
    }
    
}

extension ResultViewController: ItunesManagerDelegate{
    
    func setItunesMusic(_ itunesMusic: ItunesMusic) {
        itunesTracks.append(itunesMusic)
        DispatchQueue.main.async {
            if self.itunesTracks.count == 30{
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = false
                self.tableView.reloadData()
                
            }
        }
    }
    
    func failItunesMusic(_ error: String) {
        DispatchQueue.main.async{
            self.errorLabel.isHidden = false
            self.errorLabel.text = error
            self.activityIndicator.stopAnimating()
            self.tableView.isHidden = true
            self.view.gestureRecognizers![0].isEnabled = true
        }
        
    }
    
}

extension ResultViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itunesTracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! TableViewCell
        
        let itunesMusic = itunesTracks[indexPath.row]
        cell.titleLabel.text = itunesMusic.title
        cell.artistLabel.text = itunesMusic.artist
        cell.albumImageView.image = itunesMusic.albumImage
        
        if indexPath == cellSelected{
            cell.pauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            cell.controller = self
        }else{
            cell.pauseButton.setImage(nil, for: .normal)
        }
    
        return cell
    }

}

extension ResultViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        cellSelected = indexPath
        tableView.reloadData()
        
        let url = itunesTracks[indexPath.row].previewUrl
        playingPlayer = AVPlayer(url: url)
        playingPlayer?.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
        playingPlayer?.play()
        self.view.endEditing(true)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if change?[NSKeyValueChangeKey(rawValue: "new")] as! Int == 0{
            cellSelected = nil
            playingPlayer = nil
            tableView.reloadData()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}


