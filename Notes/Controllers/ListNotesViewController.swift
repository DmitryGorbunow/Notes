//
//  ViewController.swift
//  Notes
//
//  Created by Dmitry Gorbunow on 12/23/22.
//

import UIKit

protocol ListNotesDelegate: AnyObject {
    func refreshNotes()
    func deleteNote(with id: UUID)
}

class ListNotesViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .insetGrouped)
        tableView.backgroundColor = .systemGroupedBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let searchController = UISearchController()
    
    private var allNotes: [Note] = [] {
        didSet {
            
            filteredNotes = allNotes
        }
    }
    private var filteredNotes: [Note] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.title = "Notes"
        
        addSubviews()
        addConstraints()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ListNoteTableViewCell.self, forCellReuseIdentifier: ListNoteTableViewCell.identifier)
        tableView.contentInset = .init(top: 0, left: 0, bottom: 30, right: 0)
        
        searchController.delegate = self
        configureSearchBar()
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "pencil.line"), style: .plain, target: self, action: #selector(createNewNoteClicked))
        
        fetchNotesFromStorage()
        
    }
    
    private func addSubviews() {
        view.addSubview(tableView)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func indexForNote(id: UUID, in list: [Note]) -> IndexPath {
        let row = Int(list.firstIndex(where: { $0.id == id }) ?? 0)
        return IndexPath(row: row, section: 0)
    }
    
    private func configureSearchBar() {
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.delegate = self
    }
    
    @objc func createNewNoteClicked(_ sender: UIButton) {
        goToEditNote(createNote())
    }
    
    private func goToEditNote(_ note: Note) {
        let controller = EditNoteViewController()
        controller.note = note
        controller.delegate = self
       
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func createNote() -> Note {
        let note = CoreDataManager.shared.createNote()
        
        allNotes.insert(note, at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        
        return note
    }
    
    private func fetchNotesFromStorage() {
        allNotes = CoreDataManager.shared.fetchNotes()
    }
    
    private func deleteNoteFromStorage(_ note: Note) {
        deleteNote(with: note.id)
        CoreDataManager.shared.deleteNote(note)
    }
    
    private func searchNotesFromStorage(_ text: String) {
        allNotes = CoreDataManager.shared.fetchNotes(filter: text)
        tableView.reloadData()
    }
}

extension ListNotesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListNoteTableViewCell.identifier) as? ListNoteTableViewCell else {
            return UITableViewCell()
        }
        cell.setup(note: filteredNotes[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToEditNote(filteredNotes[indexPath.row])
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteNoteFromStorage(filteredNotes[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension ListNotesViewController: UISearchControllerDelegate, UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        search("")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        searchNotesFromStorage(query)
    }
    
    func search(_ query: String) {
        if query.count >= 1 {
            filteredNotes = allNotes.filter { $0.text.lowercased().contains(query.lowercased()) }
        } else{
            filteredNotes = allNotes
        }
        
        tableView.reloadData()
    }
}

extension ListNotesViewController: ListNotesDelegate {
    
    func refreshNotes() {
        allNotes = allNotes.sorted { $0.lastUpdated > $1.lastUpdated }
        tableView.reloadData()
    }
    
    func deleteNote(with id: UUID) {
        let indexPath = indexForNote(id: id, in: filteredNotes)
        
        filteredNotes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        allNotes.remove(at: indexForNote(id: id, in: allNotes).row)
    }
}
