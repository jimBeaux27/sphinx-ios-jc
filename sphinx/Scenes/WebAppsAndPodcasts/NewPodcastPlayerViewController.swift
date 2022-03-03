//
//  NewPodcastPlayerViewController.swift
//  sphinx
//
//  Created by Tomas Timinskas on 27/10/2020.
//  Copyright © 2020 Sphinx. All rights reserved.
//

import UIKit

protocol PodcastPlayerVCDelegate: AnyObject {
    func willDismissPlayer(playing: Bool)
    func shouldShareClip(comment: PodcastComment)
    func shouldGoToPlayer()
    func shouldDismissPlayerView()
}

protocol CustomBoostDelegate: AnyObject {
    func didSendBoostMessage(success: Bool, message: TransactionMessage?)
}

class NewPodcastPlayerViewController: UIViewController {
    
    weak var delegate: PodcastPlayerVCDelegate?
    weak var boostDelegate: CustomBoostDelegate?
    
    @IBOutlet weak var topFixingView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var tableHeaderView: PodcastPlayerView?
    
    var podcast: PodcastFeed! = nil
    
    var chat: Chat? {
        get {
            return podcast.chat
        }
    }
    
    var playerHelper: PodcastPlayerHelper = PodcastPlayerHelper.sharedInstance
    
    var dismissButtonStyle: ModalDismissButtonStyle!
    var tableDataSource: PodcastEpisodesDataSource!
    
    let downloadService = DownloadService.sharedInstance
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadService.setDelegate(delegate: self)
        
        showPodcastInfo()
        
        NotificationCenter.default.addObserver(forName: .onConnectionStatusChanged, object: nil, queue: OperationQueue.main) { (n: Notification) in
            self.tableView.reloadData()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .onConnectionStatusChanged, object: nil)
        
        if isBeingDismissed {
            let playing = playerHelper.isPlaying(podcast.feedID)
            delegate?.willDismissPlayer(playing: playing)
        }
    }
    
    
    static func instantiate(
        podcast: PodcastFeed,
        dismissButtonStyle: ModalDismissButtonStyle,
        delegate: PodcastPlayerVCDelegate,
        boostDelegate: CustomBoostDelegate
    ) -> NewPodcastPlayerViewController {
        let viewController = StoryboardScene.WebApps.newPodcastPlayerViewController.instantiate()
        
        viewController.podcast = podcast
        viewController.dismissButtonStyle = dismissButtonStyle
        viewController.delegate = delegate
        viewController.boostDelegate = boostDelegate
    
        return viewController
    }
    
    func preparePlayer() {
        tableHeaderView?.preparePlayer()
        tableView.reloadData()
        
        updateEpisodes()
    }
    
    
    func showPodcastInfo() {
        showEpisodesTable()
        preparePlayer()
    }
    
    func showEpisodesTable() {
        tableHeaderView = PodcastPlayerView(
            podcast: podcast,
            dismissButtonStyle: dismissButtonStyle,
            delegate: self,
            boostDelegate: self
        )
        
        tableView.tableHeaderView = tableHeaderView
        
        tableDataSource = PodcastEpisodesDataSource(
            tableView: tableView,
            podcast: podcast,
            delegate: self
        )
    }
    
    private func updateEpisodes() {
        if let feedUrl = podcast.feedURLPath {
            ContentFeed.fetchFeedItemsInBackground(feedUrl: feedUrl, contentFeedObjectID: podcast.objectID, completion: {})
        }
    }
}

extension NewPodcastPlayerViewController : PodcastEpisodesDSDelegate {
    func deleteTapped(_ indexPath: IndexPath, episode: PodcastEpisode) {
        playerHelper.shouldDeleteEpisode(episode: episode)
        reload(indexPath.row)
    }
    
    func didTapEpisodeAt(index: Int) {
        tableHeaderView?.didTapEpisodeAt(index: index)
    }
    
    func shouldToggleTopView(show: Bool) {
        topFixingView.isHidden = !show
    }
    
    func cancelTapped(_ indexPath: IndexPath, episode: PodcastEpisode) {
        downloadService.cancelDownload(episode)
        reload(indexPath.row)
    }

    func downloadTapped(_ indexPath: IndexPath, episode: PodcastEpisode) {
        downloadService.startDownload(episode)
        reload(indexPath.row)
    }

    func pauseTapped(_ indexPath: IndexPath, episode: PodcastEpisode) {
        downloadService.pauseDownload(episode)
        reload(indexPath.row)
    }

    func resumeTapped(_ indexPath: IndexPath, episode: PodcastEpisode) {
        downloadService.resumeDownload(episode)
        reload(indexPath.row)
    }
    
    func reload(_ row: Int) {
        tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
    }
}

extension NewPodcastPlayerViewController : PodcastPlayerViewDelegate {
    
    func didTapSubscriptionToggleButton() {
        if let podcast = playerHelper.podcast {
            
            podcast.isSubscribedToFromSearch.toggle()
            
            let contentFeed: ContentFeed? = CoreDataManager.sharedManager.getObjectWith(objectId: podcast.objectID)
            contentFeed?.isSubscribedToFromSearch.toggle()
            contentFeed?.managedObjectContext?.saveContext()
        }
    }
    
    
    func didTapDismissButton() {
        delegate?.shouldDismissPlayerView()
        dismiss(animated: true, completion: nil)
    }
    
    func shouldReloadEpisodesTable() {
        tableView.reloadData()
    }
    
    func shouldShareClip(comment: PodcastComment) {
        self.delegate?.shouldShareClip(comment: comment)
        self.dismiss(animated: true, completion: nil)
    }
    
    func shouldSyncPodcast() {
        chat?.updateMetaData()
    }
    
    func shouldShowSpeedPicker() {
        let selectedValue = playerHelper.playerSpeed
        let pickerVC = PickerViewController.instantiate(values: ["0.5", "0.8", "1.0", "1.2", "1.5", "2.1"], selectedValue: "\(selectedValue)", delegate: self)
        self.present(pickerVC, animated: false, completion: nil)
    }
}

extension NewPodcastPlayerViewController : CustomBoostDelegate {
    func didSendBoostMessage(success: Bool, message: TransactionMessage?) {
        boostDelegate?.didSendBoostMessage(success: success, message: message)
    }
}

extension NewPodcastPlayerViewController : PickerViewDelegate {
    func didSelectValue(value: String) {
        if let floatValue = Float(value), floatValue >= 0.5 && floatValue <= 2.1 {
            playerHelper.changeSpeedTo(value: floatValue, on: podcast)
            tableHeaderView?.configureControls()
        }
    }
}

extension NewPodcastPlayerViewController: URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
}

extension NewPodcastPlayerViewController : DownloadServiceDelegate {
    func shouldReloadRowFor(download: Download) {
        if let index = playerHelper.getIndexFor(episode: download.episode) {
            DispatchQueue.main.async {
              self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
    }
    
    func shouldUpdateProgressFor(download: Download) {
        if let index = playerHelper.getIndexFor(episode: download.episode) {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? PodcastEpisodeTableViewCell {
                cell.updateProgress(progress: download.progress)
            }
        }
    }
}
