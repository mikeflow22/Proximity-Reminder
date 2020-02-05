//
//  ReminderListTableViewController.swift
//  ReminderApp
//
//  Created by Michael Flowers on 1/30/20.
//  Copyright © 2020 Michael Flowers. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import CoreLocation

class ReminderListTableViewController: UITableViewController {

    //MARK: - Singleton
    let fetchedResultsController = Reminder.fetchedResultsController()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //we need this in  order to get the reminders from the persistent store to populate the tableView
       fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try fetchedResultsController.performFetch()
        } catch  {
            print("Error in: \(#function)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)")
        }
        
        //check authorization status
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .denied: locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse: locationManager.startUpdatingLocation()
        case .restricted: break
        @unknown default: break
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath)

        let reminder = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = reminder.note

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let reminder = fetchedResultsController.object(at: indexPath)
            reminder.managedObjectContext?.delete(reminder)
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cellSegue"{
            
        }
    }
}

//MARK: - NSFetchedResultsController delegate methods
extension ReminderListTableViewController:  NSFetchedResultsControllerDelegate {
    //will tell the tableViewController get ready to do something.
       func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
           tableView.beginUpdates()
       }
       
       func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
           tableView.endUpdates()
       }
       
       func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                       didChange anObject: Any,
                       at indexPath: IndexPath?,
                       for type: NSFetchedResultsChangeType,
                       newIndexPath: IndexPath?) {
           switch type {
           case .insert:
               //there was a new entry so now we need to make a new cell.
               guard let newIndexPath = newIndexPath else {return}
               tableView.insertRows(at: [newIndexPath], with: .automatic)
           case .delete:
               guard let indexPath = indexPath else {return}
               tableView.deleteRows(at: [indexPath], with: .fade)
           case .move:
               guard let indexPath = indexPath, let newIndexpath = newIndexPath else {return}
               tableView.moveRow(at: indexPath, to: newIndexpath)
           case .update:
               guard let indexPath = indexPath else {return}
               tableView.reloadRows(at: [indexPath], with: .automatic)
           @unknown default:
            fatalError()
        }
           
       }
       
       func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
               switch type {
           case .insert:
               let indexSet = IndexSet(integer: sectionIndex)
                   tableView.insertSections(indexSet, with: .automatic)
           case .delete:
               let indexSSet = IndexSet(integer: sectionIndex)
               tableView.deleteSections(indexSSet, with: .automatic)
           default:
               break
           }
       }
}
