//
//  TasksViewController.swift
//  ToDoFIRE
//
//  Created by Nurtugan on 4/2/19.
//  Copyright © 2019 Nurtugan Nuraly. All rights reserved.
//

import UIKit
import Firebase

class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  var user: UserL!
  var ref: DatabaseReference!
  var tasks = Array<Task>()
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let currentUser = Auth.auth().currentUser else { return }
    user = UserL(user: currentUser)
    ref = Database.database().reference(withPath: "users").child(String(user.uid)).child("tasks")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    ref.observe(.value) { [weak self] snapshot in
      var _tasks = Array<Task>()
      
      for item in snapshot.children {
        let task = Task(snapshot: item as! DataSnapshot)
        _tasks.append(task)
      }
      
      self?.tasks = _tasks
      self?.tableView.reloadData()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    ref.removeAllObservers()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tasks.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    cell.backgroundColor = .clear
    cell.textLabel?.textColor = .white
    let task = tasks[indexPath.row]
    let taskTitle = task.title
    let isCompleted = task.completed
    cell.textLabel?.text = taskTitle
    toggleCompletion(cell, isCompleted: isCompleted)
    
    return cell
  }
  
  @IBAction func addTapped(_ sender: UIBarButtonItem) {
    
    let alertController = UIAlertController(title: "New Task", message: "Add new task", preferredStyle: .alert)
    alertController.addTextField()
    
    let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
      
      guard let textField = alertController.textFields?.first, textField.text != "" else { return }
      let task = Task(title: textField.text!, userId: (self?.user.uid)!)
      let taskRef = self?.ref.child(task.title.lowercased())
      taskRef?.setValue(task.convertToDictionary())
      
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    alertController.addAction(saveAction)
    alertController.addAction(cancelAction)
    
    present(alertController, animated: true, completion: nil)
    
  }
  
  @IBAction func signOutTapped(_ sender: UIBarButtonItem) {
    do {
      try Auth.auth().signOut()
    } catch {
      print(error.localizedDescription)
    }
    
    dismiss(animated: true, completion: nil)
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let task = tasks[indexPath.row]
      task.ref?.removeValue()
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    let task = tasks[indexPath.row]
    let isCompleted = !task.completed
    
    toggleCompletion(cell, isCompleted: isCompleted)
    task.ref?.updateChildValues(["completed": isCompleted])
  }
  
  func toggleCompletion(_ cell: UITableViewCell, isCompleted: Bool) {
    cell.accessoryType = isCompleted ? .checkmark : .none
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
}
