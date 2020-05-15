

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    var array = [Item]()
    var index : IndexPath? = nil
    var selectedcategory : Category? {
        didSet {
            loaditems()
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
       // print (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        //loaditems()
    }
    
    
    //MARK: Table View DataSource Methods
    // Number of cells to be used
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    
    // Updating text at each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell"
            , for: indexPath)
        let item = array[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    //MARK: Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = array[indexPath.row]
        item.done = !item.done
        saveitems()
        index =  indexPath
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: Add New Item to the table using coredata
    @IBAction func additem(_ sender: UIBarButtonItem) {
        
        var textfield = UITextField()
        // Alert to user to enter new item
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //What Will Happen when the user clicks the Add item button
            let newitem = Item(context: self.context)
            newitem.title = textfield.text!
            if newitem.title != "" {
                newitem.done = false
                newitem.parentcategory = self.selectedcategory
                self.array.append(newitem)
                self.saveitems()
            }
            else {
                let alertController = UIAlertController(title: "Error", message:
                       "Unnamed Entry", preferredStyle: .alert)
                   alertController.addAction(UIAlertAction(title: "Return", style: .default))
                   self.present(alertController, animated: true, completion: nil)
            }
            
            
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textfield = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true , completion: nil)
    }
    
    //save context for coredata -- Items will be saved to the created Database
    func saveitems()
    {
        do {
            try context.save()
        } catch  {
            print("ERROR IN SAVING CONTEXT \(error) ")
        }
        self.tableView.reloadData()
    }
    //Reading---load context from database--items will be loaded from database
    func loaditems()
    {
        let request : NSFetchRequest<Item> = Item.fetchRequest()

        
        let predicate = NSPredicate(format: "parentcategory.name MATCHES %@", selectedcategory!.name!)
        
        request.predicate = predicate
        do {
            try array = context.fetch(request)
        } catch {
            print("ERROR IN LOADING CONTEXT \(error) ")
        }
        
        tableView.reloadData()
    }
    
    //Delete-- item from database using coredata
    @IBAction func DeleteItem(_ sender: UIBarButtonItem) {
        if index != nil {
            if array[(index?.row)!].done == true {
                context.delete(array[(index?.row ?? nil.self)!])
                array.remove(at: (index?.row)! )
                saveitems()
            }
            else
            {
                let alertController2 = UIAlertController(title: "Todoey", message:
                    "No item selected", preferredStyle: .alert)
                alertController2.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self.present(alertController2, animated: true, completion: nil)
            }
        }
        else
        {
            let alertController2 = UIAlertController(title: "Todoey", message:
                "No item selected", preferredStyle: .alert)
            alertController2.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alertController2, animated: true, completion: nil)
        }
    }
}

// implementing search query
extension TodoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        let categorypredicate = NSPredicate(format: "parentcategory.name MATCHES %@", selectedcategory!.name!)
        
        let searchpredicate = NSPredicate(format: "title CONTAINS[cd] %@" , searchBar.text!)
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categorypredicate,searchpredicate])
        
        request.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        do {
                   try array = context.fetch(request)
               } catch {
                   print("ERROR IN LOADING CONTEXT \(error) ")
               }
               tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loaditems()
        }
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
}

