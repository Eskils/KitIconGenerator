//
//  DocumentPicker.swift
//  KitIconGenerator
//
//  Created by Eskil Gjerde Sviggum on 22/11/2023.
//

import SwiftUI
import UniformTypeIdentifiers

#if canImport(UIKit)
struct DocumentPicker: UIViewControllerRepresentable {

    @Binding
    var url: URL?
    
    var contentTypes: [UTType] = [.image]

    func makeCoordinator() -> DocumentPicker.Coordinator {
        return DocumentPicker.Coordinator(parent: self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: DocumentPicker.UIViewControllerType, context: UIViewControllerRepresentableContext<DocumentPicker>) {
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {

        var parent: DocumentPicker

        init(parent: DocumentPicker){
            self.parent = parent

        }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            controller.dismiss(animated: true)
            
            self.parent.url = urls.first

        }

    }

}
#endif
