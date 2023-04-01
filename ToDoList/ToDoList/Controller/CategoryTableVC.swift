//
//  CategoryTableVC.swift
//  ToDoList
//
//  Created by Нахид Гаджалиев on 30.03.2023.
//

import UIKit
import CoreData

class CategoryTableVC: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categoriesArray = [Category]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        tableView.register(ToDoItemTableViewCell.self, forCellReuseIdentifier: ToDoItemTableViewCell.identifier)
        navigationSetup()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoItemTableViewCell.identifier,
                                                       for: indexPath) as? ToDoItemTableViewCell else {
            return UITableViewCell()
            
        }
        
        let category = categoriesArray[indexPath.row]
        
        cell.title.text = category.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let vc = ToDoListTableVC()
        let category = categoriesArray[indexPath.row]
        vc.selectedCategory = category
        navigationController?.pushViewController(vc, animated: true)
    }
    
}




// MARK: - ADDING METHODS
extension CategoryTableVC {
    
    // Получение/загрузка cохраненных данных
    private func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {

        do {
            categoriesArray = try context.fetch(request)
        } catch {
            print("Error loading data: \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    
    // Сохранение данных в памяти. Вызывается каждый раз при изменении
    private func saveCategories() {
        
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
        title = "Categories"
    }
    
}




// MARK: - ADDING ACTIONS
extension CategoryTableVC {
    
    @objc private func goToDetail() {
        
        let vc = ToDoListTableVC()
        vc.modalPresentationStyle = .fullScreen
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc private func addToList() {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        // Действие при нажатии на кнопку
        let action = UIAlertAction(title: "Add", style: .default) { [weak self] act in
            guard let text = textField.text else { return }
            guard let contextCopy = self?.context else { return }

            // Создание нового объекта для сохранения
            let newCategory = Category(context: contextCopy)
            newCategory.name = text

            self?.categoriesArray.append(newCategory)

            self?.saveCategories()

        }
        
        // Выскакивает при открытии алерта. Срабатывает один раз
        alert.addTextField { tf in
            tf.placeholder = "Enter here"
            textField = tf
        }
        alert.addAction(action)
        present(alert, animated: true)
        
    }
    
}
