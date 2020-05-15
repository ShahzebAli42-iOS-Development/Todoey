
import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categories = [Category]()
    var index : IndexPath? = nil
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        loadcategories()
    }
    // MARK: - Table view data source
    // Number of cells to be used
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    // Updating text at each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell"
            , for: indexPath)
        index = indexPath
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.name
        return cell
       }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "gotoItems", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexpath = tableView.indexPathForSelectedRow {
            destinationVC.selectedcategory = categories[indexpath.row]
        }
    }
    // MARK: - Data Manipulation methods
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        
        var textfield = UITextField()
               // Alert to user to enter new category
               let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
               let action = UIAlertAction(title: "Add", style: .default) { (action) in
                   //What Will Happen when the user clicks the Add button
                   let newcategory = Category(context: self.context)
                   newcategory.name = textfield.text!
                   if newcategory.name != "" {
                       self.categories.append(newcategory)
                       self.savecategories()
                   }
                   else {
                       let alertController = UIAlertController(title: "Error", message:
                              "Unnamed Category", preferredStyle: .alert)
                          alertController.addAction(UIAlertAction(title: "Close", style: .default))
                          self.present(alertController, animated: true, completion: nil)
                   }
               }
               alert.addTextField { (alertTextField) in
                   alertTextField.placeholder = "Create New Category"
                   textfield = alertTextField
               }
               alert.addAction(action)
               present(alert, animated: true , completion: nil)
        
    }
    
    func savecategories()
       {
           do {
               try context.save()
           } catch  {
               print("ERROR IN SAVING CONTEXT \(error) ")
           }
           self.tableView.reloadData()
       }
       //Reading---load context from database--Categories will be loaded from database
       func loadcategories()
       {
           let request : NSFetchRequest<Category> = Category.fetchRequest()
           do {
               try categories = context.fetch(request)
           } catch {
               print("ERROR IN LOADING CONTEXT \(error) ")
           }
           tableView.reloadData()
       }
}

