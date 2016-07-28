//
//  ExampleViewController.swift
//  ColorMatchTabs
//
//  Created by anna on 6/15/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class StubContentViewController: UITableViewController {
    
    enum Type {
        case Products, Venues, Reviews, Users
    }
    
    var type: Type!
    private var objects: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupDataSource()
    }
    
    private func setupTableView() {
        tableView.backgroundColor = UIColor.clearColor()
        tableView.allowsSelection = false
        tableView.separatorColor = UIColor.clearColor()
        tableView.registerNib(UINib(nibName: "ExampleTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
    }
    
    private func setupDataSource() {
        if type == .Products || type == .Reviews {
            self.objects = [UIImage(named: "product_card1")!, UIImage(named: "product_card2")!]
        } else if type == .Venues || type == .Users {
            self.objects = [UIImage(named: "venue_card1")!, UIImage(named: "venue_card2")!]
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ExampleTableViewCell
        let image = objects[indexPath.row]
        cell.apply(image)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.bounds.width / 1.4
    }
    
}