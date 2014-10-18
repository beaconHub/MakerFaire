//
//  MasterViewController.swift
//  MakerFaire
//
//  Created by Harry Ng on 12/10/14.
//  Copyright (c) 2014 request. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    let notificationCenter = NSNotificationCenter.defaultCenter()
    var rangedBeacons = [CLBeacon]()
    var managedObjectContext: NSManagedObjectContext? = nil


    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        LocationManager.sharedInstance.startRangingBeaconRegions(BeaconFactory.beaconRegionsToBeRanged())
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        notificationCenter.addObserver(self, selector: Selector("enteredRegion:"), name: kRangedBeaconRegionNotificationName, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
            let object = self.rangedBeacons[indexPath.row] as CLBeacon
            (segue.destinationViewController as DetailViewController).detailItem = object
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rangedBeacons.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let object = self.rangedBeacons[indexPath.row] as CLBeacon
        cell.textLabel?.text = object.proximityUUID.UUIDString
    }

    var _fetchedResultsController: NSFetchedResultsController? = nil

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath)!, atIndexPath: indexPath)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    //MARK: - NSNotification
    
    func enteredRegion (notification: NSNotification) {
        if let dict = notification.userInfo as? Dictionary<String, [AnyObject]> {
            if let beacons = dict[kRangedBeaconRegionNotificationUserInfoBeaconsKey] {
                let count = self.rangedBeacons.count
                for object in beacons {
                    let beacon = object as CLBeacon
                    let predicate = NSPredicate(format: "proximityUUID.UUIDString == %@ AND major == %@ AND minor == %@", beacon.proximityUUID.UUIDString, beacon.major, beacon.minor)
                    let filteredArray = self.rangedBeacons.filter { predicate.evaluateWithObject($0) }
                    if filteredArray.isEmpty {
                        self.rangedBeacons.append(beacon)
                    }
                }
                if self.rangedBeacons.count > count {
                    self.tableView.reloadData()
                }
            }
        }
    }
    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */

}

