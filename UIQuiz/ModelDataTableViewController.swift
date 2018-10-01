//
//  ModelDataTableViewController.swift
//  UIQuiz
//
//  Created by Niels Andreas Østman on 25/09/2018.
//  Copyright © 2018 Niels Østman. All rights reserved.
//

import UIKit

class ModelDataTableViewController: UITableViewController, UISearchBarDelegate {
    //MARK: Properties
    
    @IBOutlet var table: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var data = [ModelDataContainer]()
    var currentData = [ModelDataContainer]()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        alterLayout()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func viewDidAppear(_ animated: Bool) {
//        searchBar.showsScopeBar = false
    }
    override func viewDidDisappear(_ animated: Bool) {
//        searchBar.showsScopeBar = true
    }
    //MARK: Private Methods
    private func setupSearchBar(){
        searchBar.delegate = self
    }
    func alterLayout() {
        tabBarController?.viewControllers![0].title = "Explore".localized
        tabBarController?.viewControllers![1].title = "Quiz".localized
        tabBarController?.viewControllers![2].title = "Learn".localized
        tabBarController?.viewControllers![3].title = "Options".localized
        table.tableHeaderView = UIView()
        // search bar in section header
        table.estimatedSectionHeaderHeight = 50
        // search bar in navigation bar
        //navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchBar)
        navigationItem.titleView = searchBar
        searchBar.showsScopeBar = true
        searchBar.sizeToFit()
//        searchBar.showsScopeBar = false // you can show/hide this dependant on your layout
        searchBar.placeholder = "Search..."
//        searchBar.backgroundColor = UIColor.white
//        searchBar.barTintColor = UIColor.white
        let titleTextAttributesSelected = [NSAttributedStringKey.foregroundColor: UIColor.green]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributesSelected, for: .selected)
    }
    private func loadData() {
        let values = Theme.GetModelData().values.sorted(by: { $0.key > $1.key })
        data += values
        currentData = data
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currentData.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ModelDataViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ModelDataTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ModelDataViewCell.")
        }
        // Configure the cell...
        let dat = currentData[indexPath.row]
        
        cell.TitleLabel.text = dat.title
        cell.ISOLabel.text = dat.pictureName
        var image: UIImage? = UIImage(named: dat.pictureName)
        if image == nil {
            image = UIImage(named: "DefaultImage")
        }
        if image != nil{
            cell.signImage.image = image
        }
        return cell
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentData = data.filter({ dat -> Bool in
            switch searchBar.selectedScopeButtonIndex {
            case 0:
                if searchText.isEmpty { return true }
                return dat.title.lowercased().contains(searchText.lowercased())
            case 1:
                if searchText.isEmpty { return dat.type == .Safe_Condition }
                return dat.title.lowercased().contains(searchText.lowercased()) &&
                    dat.type == .Safe_Condition
            case 2:
                if searchText.isEmpty { return dat.type == .Fire_Protection }
                return dat.title.lowercased().contains(searchText.lowercased()) &&
                    dat.type == .Fire_Protection
            case 3:
                if searchText.isEmpty { return dat.type == .Mandatory }
                return dat.title.lowercased().contains(searchText.lowercased()) &&
                    dat.type == .Mandatory
            case 4:
                if searchText.isEmpty { return dat.type == .Prohibition }
                return dat.title.lowercased().contains(searchText.lowercased()) &&
                    dat.type == .Prohibition
            case 5:
                if searchText.isEmpty { return dat.type == .Warning }
                return dat.title.lowercased().contains(searchText.lowercased()) &&
                    dat.type == .Warning
            default:
                return false
            }
        })
        
        table.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let searchText = searchBar.text!
        currentData = data.filter({ dat -> Bool in
            switch selectedScope {
            case 0:
                if searchText.isEmpty { return true }
                return dat.title.lowercased().contains(searchText.lowercased())
            case 1:
                if searchText.isEmpty { return dat.type == .Safe_Condition }
                return dat.title.lowercased().contains(searchText.lowercased()) &&
                    dat.type == .Safe_Condition
            case 2:
                if searchText.isEmpty { return dat.type == .Fire_Protection }
                return dat.title.lowercased().contains(searchText.lowercased()) &&
                    dat.type == .Fire_Protection
            case 3:
                if searchText.isEmpty { return dat.type == .Mandatory }
                return dat.title.lowercased().contains(searchText.lowercased()) &&
                    dat.type == .Mandatory
            case 4:
                if searchText.isEmpty { return dat.type == .Prohibition }
                return dat.title.lowercased().contains(searchText.lowercased()) &&
                    dat.type == .Prohibition
            case 5:
                if searchText.isEmpty { return dat.type == .Warning }
                return dat.title.lowercased().contains(searchText.lowercased()) &&
                    dat.type == .Warning
            default:
                return false
            }
        })
        
        table.reloadData()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        searchBar.showsScopeBar = true
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        searchBar.showsScopeBar = false
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
//        searchBar.showsScopeBar = true
        let destinationNavigationController = segue.destination as! UINavigationController
        guard let modelDataDetailViewController = destinationNavigationController.topViewController as? DetailViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        guard let selectedMealCell = sender as? ModelDataTableViewCell else {
            fatalError("Unexpected sender: \(sender)")
        }
        
        guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
            fatalError("The selected cell is not being displayed by the table")
        }
        let selectedDat = currentData[indexPath.row]
        modelDataDetailViewController.key = selectedDat.key
    }
    

}
