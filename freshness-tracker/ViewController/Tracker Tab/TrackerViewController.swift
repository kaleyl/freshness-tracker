//
//  TrackerViewController.swift
//  freshness-tracker
//
//  Created by Kaley Leung on 4/9/20.
//  Copyright © 2020 Kaley Leung. All rights reserved.
//

import UIKit

class TrackerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var TrackerTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TrackerTableView.rowHeight = 110
        TrackerTableView.delegate = self
        TrackerTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        TrackerTableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return appData.tracker.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FoodCell", for: indexPath) as? FoodEntryCell {
            // configure cell
            let currentFood = appData.tracker[indexPath.row]
            
            if let image = currentFood.image {
                cell.imageLabel.image = image
            }
            cell.nameLabel.text = currentFood.name
            let daysLeft = calculateLeftDays(startDate:  Date(), endDate: currentFood.expireDate)
            cell.dateLabel.text = String(daysLeft)
            cell.dateLabel.textColor = getLeftDaysColor(daysLeft: daysLeft)
            cell.descriptionLabel.text = "days left"
            
            return cell
        } else {
            return UITableViewCell()
        }
     }
    
    
    /*
    credit to:
    https://stackoverflow.com/questions/32004557/swipe-able-table-view-cell-in-ios-9
    */
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
     
        let selectedFood = appData.tracker[indexPath.item]
        
        // Write action code for the trash
        let TrashAction = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            appData.removeFood(name: selectedFood.name)
            self.viewWillAppear(false)
            success(true)
        })
        TrashAction.backgroundColor = .red
        TrashAction.image = UIImage(systemName: "trash")

        // Write action code for the Flag
        let AddAction = UIContextualAction(style: .normal, title:  "Add", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
    
            //action here
            success(true)
        })
        AddAction.backgroundColor = .orange
        AddAction.image = UIImage(systemName: "cart")

        // Write action code for the More
 

        return UISwipeActionsConfiguration(actions: [TrashAction,AddAction])
    }

}
