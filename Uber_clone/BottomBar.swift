//
//  BottomBar.swift
//  Aorecare
//
//  Created by Minh Pham on 11/22/16.
//  Copyright © 2016 Minh Pham. All rights reserved.
//

import UIKit

@objc protocol BottomBarDelegate{
    func bottomBarDidSelectButtonAtIndex(_ index:Int)
    @objc optional func sideBarWillClose()
    @objc optional func sideBarWillOpen()
}

class BottomBar: NSObject, BottomBarTableViewControllerDelegate {
    
    let barHeight:CGFloat = 300.0
    let sideBarTableViewTopInset:CGFloat = 64.0
    let sideBarContainerView:UIView = UIView()
    let sideBarTableViewController:BottomBarTableViewController = BottomBarTableViewController()
    var originView:UIView = UIView()
    
    var animator:UIDynamicAnimator!
    var delegate:BottomBarDelegate?
    var isSideBarOpen:Bool = false
    
    override init() {
        super.init()
    }
    
    init(sourceView:UIView, menuItems:Array<String>){
        super.init()
        originView = sourceView
        sideBarTableViewController.tableData = menuItems
        
        setupSideBar()
        
        animator = UIDynamicAnimator(referenceView: originView)
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(SideBar.handleSwipe(_:)))
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.up
        originView.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(SideBar.handleSwipe(_:)))
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.down
        originView.addGestureRecognizer(hideGestureRecognizer)
        
    }
    
    
    func setupSideBar(){
        sideBarContainerView.frame = CGRect(x: originView.frame.origin.x, y: -barHeight, width: originView.frame.size.width, height: barHeight )

        sideBarContainerView.backgroundColor = UIColor.clear
        sideBarContainerView.clipsToBounds = false
        
        originView.addSubview(sideBarContainerView)
        
        let blurView:UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
        blurView.frame = sideBarContainerView.bounds
        sideBarContainerView.addSubview(blurView)
        
        
        sideBarTableViewController.delegate = self
        sideBarTableViewController.tableView.frame = sideBarContainerView.bounds
        sideBarTableViewController.tableView.clipsToBounds = false
        sideBarTableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        sideBarTableViewController.tableView.backgroundColor = UIColor.clear
        sideBarTableViewController.tableView.scrollsToTop  = false
        sideBarTableViewController.tableView.contentInset = UIEdgeInsetsMake(sideBarTableViewTopInset,0 , 0, 0)
        
        sideBarTableViewController.tableView.reloadData()
        
        sideBarContainerView.addSubview(sideBarTableViewController.tableView)
        
    }
    
    
    func handleSwipe(_ recognizer:UISwipeGestureRecognizer){
        if recognizer.direction == UISwipeGestureRecognizerDirection.up{
            showSideBar(false)
            delegate?.sideBarWillClose?()
            
        } else {
            showSideBar(true)
            delegate?.sideBarWillOpen?()
        }
        
    }
    
    
    func showSideBar(_ shouldOpen:Bool){
        animator.removeAllBehaviors()
        isSideBarOpen = shouldOpen
        
        let gravityY:CGFloat = (shouldOpen) ? 0.5 : -0.5
        let magnitude:CGFloat = (shouldOpen) ? 20 : -20
        let boundaryY:CGFloat = (shouldOpen) ? barHeight : -barHeight - 1
        
        
        let gravityBehavior:UIGravityBehavior = UIGravityBehavior(items: [sideBarContainerView])
        gravityBehavior.gravityDirection = CGVector(dx: 0, dy: gravityY)
        animator.addBehavior(gravityBehavior)
        
        let collisionBehavior:UICollisionBehavior = UICollisionBehavior(items: [sideBarContainerView])
        collisionBehavior.addBoundary(withIdentifier: "sideBarBoundary" as NSCopying, from: CGPoint(x: originView.frame.size.width, y: boundaryY), to: CGPoint(x: 20, y: boundaryY))
        animator.addBehavior(collisionBehavior)
        
        let pushBehavior:UIPushBehavior = UIPushBehavior(items: [sideBarContainerView], mode: UIPushBehaviorMode.instantaneous)
        pushBehavior.magnitude = magnitude
        animator.addBehavior(pushBehavior)
        
        
        let sideBarBehavior:UIDynamicItemBehavior = UIDynamicItemBehavior(items: [sideBarContainerView])
        sideBarBehavior.elasticity = 0.3
        animator.addBehavior(sideBarBehavior)
        
    }
    
    
    func bottomBarControlDidSelectRow(_ indexPath: IndexPath) {
        delegate?.bottomBarDidSelectButtonAtIndex(indexPath.row)
    }
    
    
    
}

