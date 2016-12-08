//
//  ViewController.swift
//  NavigationBarManager
//
//  Created by Sarun Wongpatcharapakorn on 12/01/2016.
//  Copyright (c) 2016 Sarun Wongpatcharapakorn. All rights reserved.
//

import UIKit
import NavigationBarManager

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var refreshControl: UIRefreshControl!
    var navBarManager: NavigationBarManager!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBarManager = NavigationBarManager(viewController: self, scrollView: collectionView)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(sender:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            // Fallback on earlier versions
            collectionView.addSubview(refreshControl)
        }
        
        
        let rect = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 100)
        let redView = UIView(frame: rect)
        redView.backgroundColor = UIColor.red
        navBarManager.extensionView = redView
    }
    
    func didPullToRefresh(sender: AnyObject) {
        longRunningProcess()
    }
    
    private func longRunningProcess() {
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 2, execute: {
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Collection View
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        clear()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        return cell
    }
    
    private var numberOfItems = 10
    @IBAction func didTapLoad(_ sender: Any) {
        load()
    }
    
    private func clear() {
        numberOfItems = 0
        collectionView.reloadData()
    }
    
    private func load() {
        numberOfItems = 10
        collectionView.reloadData()
    }
    
    // MARK: - Scroll View
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        navBarManager.handleScrollViewDidScroll(scrollView: scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == true {
            // have inertia, handle in scrollViewDidEndDecelerating
            return
        }
        
        navBarManager.handleScrollViewDidEnd(scrollView: scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // stop
        navBarManager.handleScrollViewDidEnd(scrollView: scrollView)
    }
}

