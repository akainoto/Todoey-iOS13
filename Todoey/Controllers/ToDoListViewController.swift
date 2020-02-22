//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
                
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
                    
        loadItems(with: request)
    }

    //MARK: - TableView and DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        //Ternary Operator. Works like an if statement. If true use checkmark, if not true, use none.
        //Ternary Operater: "value = condition ? valueTrue : valueFalse"
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - TableView and Delegates
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Toggling Checkmark true or false. = ! means the opposite.
        // It changes to the opposite of the current state, on or off.
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
    
        // Flashes Gray rather than maintains Gray upon clicking
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // What will happen when the user clicks "Add Item" on UIAlert
                        
            let newItem = Item(context: self.context)
            
            newItem.title = textField.text!
            newItem.done = false
            
            self.itemArray.append(newItem)
            
            self.saveItems()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manipulation Methods
    
    func saveItems() {
        
        // Saves the data to the array IN DOCUMENTS FOLDER for when App is closed
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        //Reloads table with new items appended to the Array
        self.tableView.reloadData()
    }
    
    func loadItems(with request:NSFetchRequest<Item> = Item.fetchRequest()) {
            
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
}
//MARK: - Search Bar Methods

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        // Predicate is a way to query the database
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
                
        //sort the data
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            
            loadItems()
            
            DispatchQueue.main.async {
                
                // Go to origonal state
                searchBar.resignFirstResponder()
            }
        }
    }
}


