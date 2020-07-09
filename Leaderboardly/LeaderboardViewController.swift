//
//  LeaderboardViewController.swift
//  Leaderboardly
//
//  Created by Simon Bromberg on 2020-01-30.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import UIKit

class LeaderboardViewController: UIViewController, UITableViewDelegate {
    private var leaderboard = [LeaderboardEntry]()

    @IBOutlet var tableView: UITableView!
    private var dataSource: UITableViewDiffableDataSource<Int, LeaderboardEntry>!

    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)

        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        getLeaderboard()
    }

    private func getLeaderboard(_ completion: (() -> Void)? = nil) {
        ApiManager.shared.getLeaderboard { [weak self] (leaderboard, error) in
            self?.leaderboard = leaderboard ?? []
            self?.leaderboard.sort(by: { $0.score > $1.score })

            DispatchQueue.main.async {
                completion?()
                
                self?.reloadTableViewData()
            }
        }
    }

    // MARK: - Table View

    private func setupTableView() {
        let diffableDataSource = UITableViewDiffableDataSource<Int, LeaderboardEntry>(tableView: tableView, cellProvider: { (tableView, indexPath, leaderboardEntry) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LeaderboardEntryCell

            let emoji = self.emojiForRow(indexPath.row)
            let suffix = emoji == nil ? "" : " \(emoji!)"
            cell.nameLabel.text = "\(indexPath.row + 1): \(leaderboardEntry.name)\(suffix)"

            cell.scoreLabel.text = "\(leaderboardEntry.score)"
            cell.profileImageView.image = UIImage(systemName: "person") // placeholder

            return cell
        })
        diffableDataSource.defaultRowAnimation = .top

        dataSource = diffableDataSource
        tableView.dataSource = dataSource

        tableView.refreshControl = refreshControl
    }

    private func emojiForRow(_ row: Int) -> String? {
        switch row {
        case 0:
            return "🥇"
        case 1:
            return "🥈"
        case 2:
            return "🥉"
        case leaderboard.count - 1:
            return "☹️"
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        _ = ApiManager.shared.getImageData(with: leaderboard[indexPath.row].imageURL) { (imageData, error) in
            DispatchQueue.main.async {
                if let imageData = imageData,
                    let image = UIImage(data: imageData),
                    let cell = tableView.cellForRow(at: indexPath) as? LeaderboardEntryCell {
                    cell.profileImageView.image = image
                }
            }
        }
    }

    private func reloadTableViewData() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, LeaderboardEntry>()
        snapshot.appendSections([0])
        snapshot.appendItems(leaderboard)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    @objc private func didPullToRefresh() {
        getLeaderboard { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
}

final class Cache<Key: Hashable, Value> {
    private let wrapped = NSCache<NSString, UIImage>()
}
