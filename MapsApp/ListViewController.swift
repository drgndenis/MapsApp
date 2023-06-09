//
//  ListViewController.swift
//  MapsApp
//
//  Created by Denis DRAGAN on 5.06.2023.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    
    var nameArrays = [String]()
    var idArrays = [UUID]()
    var selectedLocName = ""
    var selectedLocId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addLocation))
        
        getData()
    }
    
    // Datanin tableView'a girisi
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newLocationCreated"), object: nil)
    }
    
    @objc func addLocation() {
        selectedLocName = "" // Navbar'dan butona tiklandiginda bos veri gonderiyoruz ve MapsView uzerinde ekleme yapilacak
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    
    @objc func getData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Locations")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                nameArrays.removeAll(keepingCapacity: false)
                idArrays.removeAll(keepingCapacity: false)
                
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String {
                        nameArrays.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        idArrays.append(id)
                    }
                }
                tableView.reloadData()
            }
        } catch {
            print("Error")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArrays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArrays[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedLocName = nameArrays[indexPath.row]
        selectedLocId = idArrays[indexPath.row]
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapsVC" {
            let destinationVC = segue.destination as! MapsViewController
            destinationVC.selectedName = selectedLocName
            destinationVC.selectedId = selectedLocId
        }
    }
}
