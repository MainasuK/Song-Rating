//
//  PlayerHistoryViewController.swift
//  Song Rating
//
//  Created by Cirno MainasuK on 2019-8-21.
//  Copyright © 2019 Cirno MainasuK. All rights reserved.
//

import Cocoa

final class PlayerHistoryViewController: NSViewController {
    
    var shouldEmtpy = false {
        didSet {
            playerHistoryTableView.reloadData()
            playerHistoryTableView.needsDisplay = true
        }
    }
    
    let scrollView = NSScrollView()
    lazy var playerHistoryTableView: NSTableView = {
        let tableView = NSTableView()
        
        let coverColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("track_album_cover"))
        tableView.addTableColumn(coverColumn)
        
        return tableView
    }()
    
    override func loadView() {
        self.view = NSView()
    }
    
}

extension PlayerHistoryViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.documentView = playerHistoryTableView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        // playerHistoryTableView.wantsLayer = true
        // playerHistoryTableView.dataSource = self
    }
    
}

// MARK: - NSTableViewDataSource
extension PlayerHistoryViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 10
    }
    
    
}
