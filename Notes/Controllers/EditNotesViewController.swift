//
//  EditNotesViewController.swift
//  Notes
//
//  Created by Dmitry Gorbunow on 12/24/22.
//

import UIKit
import PhotosUI

class EditNoteViewController: UIViewController {
    
    static let identifier = "EditNoteViewController"
    
    var note: Note!
    weak var delegate: ListNotesDelegate?
    private var itemProviders = [NSItemProvider]()
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 20)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubviews()
        addConstraints()
        textView.text = note?.text
        textView.attributedText = note.attributeString
        textView.delegate = self
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "photo"), style: .plain, target: self, action: #selector(addImageClicked)),
            UIBarButtonItem(image: UIImage(systemName: "bold"), style: .plain, target: self, action: #selector(boldTapped)),
            UIBarButtonItem(image: UIImage(systemName: "italic"), style: .plain, target: self, action: #selector(italicTapped)),
            UIBarButtonItem(image: UIImage(systemName: "underline"), style: .plain, target: self, action: #selector(underlineTapped))
        ]
    }
    
    private func addSubviews() {
        view.addSubview(textView)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func addImageClicked() {
        presentPicker(filter: PHPickerFilter.images)
    }
    
    @objc private func boldTapped() {
        
        let range = textView.selectedRange
        let string = NSMutableAttributedString(attributedString:
                                                textView.attributedText)
        let boldAttribute = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)
        ]
        string.addAttributes(boldAttribute, range: textView.selectedRange)
        textView.attributedText = string
        textView.selectedRange = range
    }
    
    @objc private func italicTapped() {
        
        let range = textView.selectedRange
        let string = NSMutableAttributedString(attributedString:
                                                textView.attributedText)
        let italicAttribute = [
            NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 20)
        ]
        string.addAttributes(italicAttribute, range: textView.selectedRange)
        textView.attributedText = string
        textView.selectedRange = range
    }
    
    @objc private func underlineTapped() {
        let range = textView.selectedRange
        let string = NSMutableAttributedString(attributedString:
                                                textView.attributedText)
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
        
        string.addAttributes(underlineAttribute, range: textView.selectedRange)
        textView.attributedText = string
        textView.selectedRange = range
    }
    
    private func presentPicker(filter: PHPickerFilter) {
        var configuration = PHPickerConfiguration()
        configuration.filter = filter
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textView.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func updateNote() {
        CoreDataManager.shared.save()
        note.lastUpdated = Date()
        delegate?.refreshNotes()
    }
    
    private func deleteNote() {
        delegate?.deleteNote(with: note.id)
        CoreDataManager.shared.deleteNote(note)
    }
    
    func insertImage(_ image: UIImage) {
        let newImageWidth = (textView.bounds.size.width - 15 )
        let scale = newImageWidth/image.size.width
        let newImageHeight = image.size.height * scale - 20
        let newImage = imageValue(with: image, scaledTo: CGSize(width: newImageWidth, height: newImageHeight))
       
        let attachment = NSTextAttachment()
        attachment.image = newImage
        
        let attString = NSAttributedString(attachment: attachment)
        self.textView.textStorage.insert(attString, at: self.textView.selectedRange.location)
        self.textView.font = .systemFont(ofSize: 20)
    }
    
    func imageValue(with image: UIImage, scaledTo newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? UIImage()
    }
}

extension EditNoteViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        note?.text = textView.text
        note.attributeString = textView.attributedText
        if note?.title.isEmpty ?? true {
            deleteNote()
        } else {
            updateNote()
        }
    }
}

extension EditNoteViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        self.itemProviders = results.map(\.itemProvider)
        let item = itemProviders.first
        if ((item?.canLoadObject(ofClass: UIImage.self)) != nil ) {
            item?.loadObject(ofClass: UIImage.self, completionHandler: { (image, error) in
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        self.insertImage(image)
                    } else {
                        print(error?.localizedDescription ?? "")
                    }
                }
            })
        } else {
            print("no")
        }
    }
}


