//
//  SideBar.swift
//  Aorecare
//
//  Created by Minh Pham on 11/22/16.
//  Copyright © 2016 Minh Pham. All rights reserved.
//

//import UIKit
//
//@objc protocol SideBarDelegate{
//    func sideBarDidSelectButtonAtIndex(_ index:Int)
//    @objc optional func sideBarWillClose()
//    @objc optional func sideBarWillOpen()
//}
//
//class SideBar: NSObject, SideBarTableViewControllerDelegate{
//    
//    let barWidth:CGFloat = 150.0
//    let sideBarTableViewTopInset:CGFloat = 64.0
//    let sideBarControllerView:UIView = UIView()
//    let sideBarTableViewController:SideBarTableViewController = SideBarTableViewController()
//    var originView:UIView! = UIView()
//    
//    var animator:UIDynamicAnimator!
//    var delegate:SideBarDelegate?
//    var isSideBarOpen:Bool = false
//    
//    override init(){
//        super.init()
//    }
//    
//    init(sourceView:UIView, menuItems:[String]){
//        super.init()
//        originView = sourceView
//        sideBarTableViewController.tableData = menuItems
//        
//        animator = UIDynamicAnimator(referenceView: originView)
//        
//        
//        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
//        
//        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
//        
//        originView.addGestureRecognizer(showGestureRecognizer)
//        
//        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
//        
//        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
//        
//        originView.addGestureRecognizer(hideGestureRecognizer)
//        
//    }
//    
//    func setupSideBar(){
//        
//        sideBarControllerView.frame = CGRect(x: -barWidth - 1, y: originView.frame.origin.y, width: barWidth, height: originView.frame.size.height)
//        sideBarControllerView.backgroundColor = UIColor.clear
//        sideBarControllerView.clipsToBounds = false
//        
//        originView.addSubview(sideBarControllerView)
//        
//        let blurView:UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
//        blurView.frame = sideBarControllerView.bounds
//        sideBarControllerView.addSubview(blurView)
//        
//        sideBarTableViewController.delegate = self
//        sideBarTableViewController.tableView.clipsToBounds = false
//        sideBarTableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
//        sideBarTableViewController.tableView.backgroundColor = UIColor.clear
//        sideBarTableViewController.tableView.scrollsToTop = false
//        sideBarTableViewController.tableView.contentInset = UIEdgeInsets(top: sideBarTableViewTopInset, left: 0, bottom: 0, right: 0)
//        sideBarTableViewController.tableView.reloadData()
//        
//        sideBarControllerView.addSubview(sideBarTableViewController.tableView)
//        
//    }
//    
//    
//    func handleSwipe(recognizer:UISwipeGestureRecognizer){
//        if recognizer.direction == UISwipeGestureRecognizerDirection.left{
//            showSideBar(shouldOpen: false)
//            delegate?.sideBarWillClose!()
//        } else {
//            showSideBar(shouldOpen: true)
//            delegate?.sideBarWillOpen!()
//        }
//    }
//    
//    func showSideBar(shouldOpen:Bool){
//        animator.removeAllBehaviors()
//        isSideBarOpen = shouldOpen
//        
//        let gravityX:CGFloat = (shouldOpen) ? 0.5 : -0.5
//        let magnitude:CGFloat = (shouldOpen) ? 20 : -20
//        let boundaryX:CGFloat = (shouldOpen) ? barWidth : -barWidth - 1
//        
//        let gravityBehavior:UIGravityBehavior = UIGravityBehavior(items: [sideBarControllerView])
//        gravityBehavior.gravityDirection = CGVector(dx: gravityX, dy: 0)
//        animator.addBehavior(gravityBehavior)
//        
//        let collisionBehavior:UICollisionBehavior = UICollisionBehavior(items: [sideBarControllerView])
//        collisionBehavior.addBoundary(withIdentifier: "sideBarBoundary" as NSCopying, from: CGPoint(x: boundaryX, y: 20), to: CGPoint(x: boundaryX, y:originView.frame.size.height))
//        animator.addBehavior(collisionBehavior)
//        
//        let pushBehavior:UIPushBehavior = UIPushBehavior(items: [sideBarControllerView], mode: UIPushBehaviorMode.instantaneous)
//        pushBehavior.magnitude = magnitude
//        animator.addBehavior(pushBehavior)
//        
//        let sideBarBehavior:UIDynamicItemBehavior = UIDynamicItemBehavior(items: [sideBarControllerView])
//        sideBarBehavior.elasticity = 0.3
//        animator.addBehavior(sideBarBehavior)
//        
//        
//        
//    }
//    
//    
//    func sideBarControllerDidSelectRow(indexPath: IndexPath) {
//        delegate?.sideBarDidSelectButtonAtIndex(indexPath.row)
//    }
//    
//}

import UIKit

@objc protocol SideBarDelegate{
    func sideBarDidSelectButtonAtIndex(_ index:Int)
    @objc optional func sideBarWillClose()
    @objc optional func sideBarWillOpen()
}

class SideBar: NSObject, SideBarTableViewControllerDelegate {
    
    let barWidth:CGFloat = 150.0
    let sideBarTableViewTopInset:CGFloat = 64.0
    let sideBarContainerView:UIView = UIView()
    let sideBarTableViewController:SideBarTableViewController = SideBarTableViewController()
    var originView:UIView = UIView()
    
    var animator:UIDynamicAnimator!
    var delegate:SideBarDelegate?
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
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
        originView.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(SideBar.handleSwipe(_:)))
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        originView.addGestureRecognizer(hideGestureRecognizer)
        
    }
    
    
    func setupSideBar(){
        
        sideBarContainerView.frame = CGRect(x: -barWidth - 1, y: originView.frame.origin.y, width: barWidth, height: originView.frame.size.height)
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
        sideBarTableViewController.tableView.contentInset = UIEdgeInsetsMake(sideBarTableViewTopInset, 0, 0, 0)
        
        sideBarTableViewController.tableView.reloadData()
        
        sideBarContainerView.addSubview(sideBarTableViewController.tableView)
        
    }
    
    
    func handleSwipe(_ recognizer:UISwipeGestureRecognizer){
        if recognizer.direction == UISwipeGestureRecognizerDirection.left{
            showSideBar(false)
            delegate?.sideBarWillClose?()
            
        }else{
            showSideBar(true)
            delegate?.sideBarWillOpen?()
        }
        
    }
    
    
    func showSideBar(_ shouldOpen:Bool){
        animator.removeAllBehaviors()
        isSideBarOpen = shouldOpen
        
        let gravityX:CGFloat = (shouldOpen) ? 0.5 : -0.5
        let magnitude:CGFloat = (shouldOpen) ? 20 : -20
        let boundaryX:CGFloat = (shouldOpen) ? barWidth : -barWidth - 1
        
        
        let gravityBehavior:UIGravityBehavior = UIGravityBehavior(items: [sideBarContainerView])
        gravityBehavior.gravityDirection = CGVector(dx: gravityX, dy: 0)
        animator.addBehavior(gravityBehavior)
        
        let collisionBehavior:UICollisionBehavior = UICollisionBehavior(items: [sideBarContainerView])
        collisionBehavior.addBoundary(withIdentifier: "sideBarBoundary" as NSCopying, from: CGPoint(x: boundaryX, y: 20), to: CGPoint(x: boundaryX, y: originView.frame.size.height))
        animator.addBehavior(collisionBehavior)
        
        let pushBehavior:UIPushBehavior = UIPushBehavior(items: [sideBarContainerView], mode: UIPushBehaviorMode.instantaneous)
        pushBehavior.magnitude = magnitude
        animator.addBehavior(pushBehavior)
        
        
        let sideBarBehavior:UIDynamicItemBehavior = UIDynamicItemBehavior(items: [sideBarContainerView])
        sideBarBehavior.elasticity = 0.3
        animator.addBehavior(sideBarBehavior)
        
    }
    
    
    func sideBarControlDidSelectRow(_ indexPath: IndexPath) {
        delegate?.sideBarDidSelectButtonAtIndex(indexPath.row)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
