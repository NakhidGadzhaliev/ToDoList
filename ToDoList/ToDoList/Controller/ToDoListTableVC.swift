//
//  ToDoListTableVC.swift
//  ToDoList
//
//  Created by Нахид Гаджалиев on 25.03.2023.
//

import UIKit
import CoreData

class ToDoListTableVC: UITableViewController {
    
    lazy var searchController = UISearchController()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var itemArray = [Item]()
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ToDoItemTableViewCell.self, forCellReuseIdentifier: ToDoItemTableViewCell.identifier)
        navigationSetup()
        setupSearchController()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoItemTableViewCell.identifier,
                                                       for: indexPath) as? ToDoItemTableViewCell else {
            return UITableViewCell()
            
        }
        
        let item = itemArray[indexPath.row]
        cell.title.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    // MARK: - Table view delegate method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItem()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}




// MARK: - ADDING METHODS
extension ToDoListTableVC {
    
    // MARK: Updates for search controller
    private func setupSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Enter"
        searchController.searchBar.backgroundColor = .white
        searchController.searchBar.tintColor = .gray
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // Получение/загрузка cохраненных данных
    private func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        guard
            let category = selectedCategory,
            let name = category.name else { return }
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", name)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,
                                                                                    additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error loading data: \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    // Сохранение данных в памяти. Вызывается каждый раз при изменении
    private func saveItem() {
        
        do {
           try context.save()
        } catch {
            print("Error saving context: \(error.localizedDescription)")
        }
        
        tableView.reloadData()
    }
    
    private func navigationSetup() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(addToList))
        navigationController?.navigationBar.tintColor = .white
        title = "Items"
    }
    
}




// MARK: - ADDING ACTIONS
extension ToDoListTableVC {
    
    @objc private func addToList() {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        
        // Действие при нажатии на кнопку
        let action = UIAlertAction(title: "Add item", style: .default) { [weak self] act in
            guard let text = textField.text else { return }
            guard let contextCopy = self?.context else { return }
            
            // Создание нового объекта для сохранения
            let newItem = Item(context: contextCopy)
            newItem.title = text
            newItem.done = false
            newItem.parentCategory = self?.selectedCategory
            
            self?.itemArray.append(newItem)

            self?.saveItem()

        }
        
        // Выскакивает при открытии алерта. Срабатывает один раз
        alert.addTextField { tf in
            tf.placeholder = "Create new item"
            textField = tf
        }
        alert.addAction(action)
        present(alert, animated: true)
        
    }
    
}





// MARK: - UISearchBarDelegate
extension ToDoListTableVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text?.count == 0 {
            loadItems()
        }
    }
    
}
