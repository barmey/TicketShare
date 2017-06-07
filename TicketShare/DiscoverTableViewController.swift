//
//  TicketTableViewController.swift
//  TicketShare
//
//  Created by Shay H on 18/03/2017.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit

class DiscoverTableViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    var ticketsList = [Ticket]()
    var recommendedTicketsList = [Ticket]()
    var currSegmentTicketsList = [Ticket]()
    var ticketsSearchResults:Array<Ticket>?
    let detailSegueIdentifier = "ShowTicketDetailSegue"
    var headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 1.0, height: 33.0))
    var selectedSegment = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        self.tableView.backgroundColor = UIColor.clear
        self.searchDisplayController?.searchResultsTableView.backgroundColor = UIColor.init(white: 1.0, alpha: 0.8)
        self.searchDisplayController?.searchResultsTableView.separatorColor = UIColor.clear
        
        let segBar = UISegmentedControl(items: ["All","Nearby","For You"])
        let tableframe = self.tableView.frame
        segBar.tintColor = UIColor(red: 186.0 / 255.0, green: 50.0 / 255.0, blue: 218.0 / 255.0, alpha: 1.0)
        segBar.backgroundColor = UIColor.white
        segBar.layer.cornerRadius = 14.5
        segBar.layer.borderColor = segBar.tintColor.cgColor
        segBar.layer.borderWidth = 1.0
        segBar.layer.masksToBounds = true
        segBar.frame = CGRect(x: tableframe.minX + 15, y: 0.0, width: tableframe.width - 30, height: 29.0)
        segBar.selectedSegmentIndex = 0
        segBar.addTarget(self, action: "segmentClicked:", for: .valueChanged)
        self.headerView.addSubview(segBar)
        
        NotificationCenter.default.addObserver(self, selector:
            #selector(self.ticketsListDidUpdate), name: NSNotification.Name(rawValue: notifyTicketListUpdate),object: nil)
        NotificationCenter.default.addObserver(self, selector:
            #selector(self.recommendedTickets), name: NSNotification.Name(rawValue: notifyRecommendedTickets),object: nil)
        
        Model.instance.getAllTicketsAndObserve()
        Model.instance.getRecommendedTickets()
    }
    
    @objc func ticketsListDidUpdate(notification:NSNotification){
        self.ticketsList = notification.userInfo?["tickets"] as! [Ticket]
        self.tableView!.reloadData()
    }
    
    @objc func recommendedTickets(notification:NSNotification){
        self.recommendedTicketsList = notification.userInfo?["tickets"] as! [Ticket]
        self.tableView!.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return self.ticketsSearchResults?.count ?? 0
        } else if self.selectedSegment == -1 {
            return self.ticketsList.count
        } else {
            return self.currSegmentTicketsList.count
        }
    }
    
    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 155
    }
    
    override public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(section == 0){
            return self.headerView;
        }
        return nil;
    }
    
    override public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*let cell = tableView.dequeueReusableCell(withIdentifier: "TicketTableViewCell", for: indexPath) as! TicketTableViewCell
         
         cell.nameLabel!.text = self.ticketsList[indexPath.row].title
         cell.amountLabel!.text = String(self.ticketsList[indexPath.row].amount)
         cell.priceLabel!.text = String(self.ticketsList[indexPath.row].price) + "₪"
         
         if let imUrl = self.ticketsList[indexPath.row].imageUrl{
         Model.instance.getImage(urlStr: imUrl, callback: { (image) in
         cell.ticketImageView!.image = image
         })
         }
         
         return cell*/
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TicketTableViewCell") as! TicketTableViewCell
        
        var arrayOfTickets:Array<Ticket>?
        if tableView == self.searchDisplayController!.searchResultsTableView {
            arrayOfTickets = self.ticketsSearchResults
        } else if self.selectedSegment == -1 {
            arrayOfTickets = self.ticketsList
        } else {
            arrayOfTickets = self.currSegmentTicketsList
        }
        
        if arrayOfTickets != nil && arrayOfTickets!.count >= indexPath.row
        {
            let tickets = arrayOfTickets![indexPath.row]
            
            cell.nameLabel!.text = tickets.title
            cell.amountLabel!.text = String(tickets.amount) + "x"
            cell.amountLabel.layer.borderColor = cell.amountLabel.textColor.cgColor
            cell.amountLabel.layer.borderWidth = 2.0
            cell.amountLabel.layer.cornerRadius = 6.0
            
            cell.priceLabel!.text = String(tickets.price) + "₪"
            cell.locLabel.text = tickets.address
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let result = formatter.string(from: date)
            cell.dateLabel.text = result
            
            switch tickets.eventType {
            case 1:
                cell.typeImg.image = UIImage(named: "concert")
            case 2:
                cell.typeImg.image = UIImage(named: "sports")
            case 3:
                cell.typeImg.image = UIImage(named: "festival")
            case 4:
                cell.typeImg.image = UIImage(named: "theater")
            default:
                cell.typeImg.image = UIImage(named: "unknown")
            }
            
            if tableView != self.searchDisplayController!.searchResultsTableView {
                // Load more species if needed
                // see https://grokswift.com/rest-tableview-in-swift/ for details
            }
        }
        
        return cell
    }
    
    func segmentClicked(_ sender: UISegmentedControl) {
        self.selectedSegment = sender.selectedSegmentIndex
        
        // TO DO call function to filter
        switch self.selectedSegment {
        case 1:
            self.currSegmentTicketsList = self.ticketsList
        case 2:
            self.currSegmentTicketsList = self.recommendedTicketsList
        default:
            self.currSegmentTicketsList = self.ticketsList
        }
        
        self.tableView!.reloadData()
    }
    
    func filterContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        var arrayOfTickets:[Ticket]
        
        if self.selectedSegment == -1 {
            arrayOfTickets = self.ticketsList
        } else {
            arrayOfTickets = self.currSegmentTicketsList
        }
        
        if arrayOfTickets.isEmpty {
            self.ticketsSearchResults = nil
            return
        }
        self.ticketsSearchResults = arrayOfTickets.filter({( aTicket: Ticket) -> Bool in
            // to start, let's just search by name
            return aTicket.title.lowercased().range(of: searchText.lowercased()) != nil
        })
    }
    
    func searchDisplayController(_ controller: UISearchDisplayController, shouldReloadTableForSearch searchString: String?) -> Bool {
        self.filterContentForSearchText(searchText: searchString!)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.tableView.reloadData()
    }
    
//    func searchDisplayController(_ controller: UISearchDisplayController, willShowSearchResultsTableView tableView: UITableView) {
//        self.tableView.isHidden = true
//    }
//    
//    func searchDisplayController(_ controller: UISearchDisplayController, didHideSearchResultsTableView tableView: UITableView) {
//        self.tableView.isHidden = false
//    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == detailSegueIdentifier {
            let destination = segue.destination as? TicketDetailsViewController
            
            if self.searchDisplayController!.isActive {
                let indexPath = self.searchDisplayController?.searchResultsTableView.indexPathForSelectedRow
                if indexPath != nil {
                    destination?.selectedTicket = (self.ticketsSearchResults?[indexPath!.row])!
                }
            } else {
                let indexPath = self.tableView?.indexPathForSelectedRow
                if indexPath != nil {
                    destination?.selectedTicket = self.ticketsList[indexPath!.row]
                }
            }
        }
    }
    
    @IBAction func unwindToDiscover(segue: UIStoryboardSegue) {
    }
}
