//
//  TrackerViewController.swift
//  freshness-tracker
//
//  Created by Kaley Leung on 4/9/20.
//  Copyright © 2020 Kaley Leung. All rights reserved.
//

import UIKit

class TrackerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var TrackerTableView: UITableView!
    
    @IBOutlet weak var sortButton: UIButton!
           
    @IBOutlet weak var searchBar: UISearchBar!
    
    var filteredFood: [FoodEntry] = []
    
    var isFiltering : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TrackerTableView.rowHeight = 100
        TrackerTableView.delegate = self
        TrackerTableView.dataSource = self
        searchBar.delegate = self
        UITabBar.appearance().tintColor = UIColor(named: "TrackGreen")!
        //Firebase content
        if(appData.ifTrackerEmpty()){
            fetchTrackerData(completion:{ result in
                if(result){
                    print("Tracker data fetched successfully")
                    self.TrackerTableView.reloadData()
                    print("reload sucessful")
                }else{
                    print("Fail to fetch tracker data from firebase")
                }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        TrackerTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredFood.count
        }
         return appData.tracker.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FoodCell", for: indexPath) as? FoodEntryCell {
            // configure cell
            var currentFood = appData.tracker[indexPath.row]
            
            if isFiltering && filteredFood.count != 0 {
                currentFood = filteredFood[indexPath.row]
            }
            
            if let image = currentFood.image {
                cell.imageLabel.image = image
            }
            cell.nameLabel.text = currentFood.name
            let daysLeft = calculateLeftDays(startDate:  Date(), endDate: currentFood.expireDate)
            if(daysLeft < 0){
                 cell.descriptionLabel.text = "days past"
            }else{
                 cell.descriptionLabel.text = "days left"
            }
            cell.dateLabel.text = String(abs(daysLeft))
            cell.dateLabel.textColor = getLeftDaysColor(daysLeft: daysLeft)
            
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
            let newItem = ListEntry(name: selectedFood.name, checked: false)
            appData.addListEntry(item: newItem)
            appData.sortItems()
            success(true)
        })
        AddAction.backgroundColor = .orange
        AddAction.image = UIImage(systemName: "cart")

        // Write action code for the More

        return UISwipeActionsConfiguration(actions: [TrashAction,AddAction])
    }
    
    @IBAction func sortButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Sort items by:",
        message: "", preferredStyle: .actionSheet)
        
        
        let sortExpireDateAction = UIAlertAction(title: "Expiration Date",style: .default
        ) { (action) in
                    appData.tracker.sort(by: sortExpireDate(this:that:))
                    self.viewWillAppear(false)
        }
        let sortDateAddedAction = UIAlertAction(title: "Date Added", style: .default) { (action) in
                    appData.tracker.sort(by: sortDateAdded(this:that:))
                    self.viewWillAppear(false)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                  style: .cancel) { (action) in
         
        }
             
        alert.addAction(sortExpireDateAction)
        alert.addAction(sortDateAddedAction)
        alert.addAction(cancelAction)
             
        present(alert, animated: true, completion: nil)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isFiltering = false
        viewWillAppear(false)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isFiltering = false
        viewWillAppear(false)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredFood = []
        if searchText == "" {
            isFiltering = false
            viewWillAppear(false)
            return
        }
        for entry in appData.tracker {
           if entry.name.contains(searchText) {
               filteredFood.append(entry)
           }
       }
       isFiltering = true
        
       viewWillAppear(false)
    
    }

}


