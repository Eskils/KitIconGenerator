//
//  DocumentExporter.swift
//  KitIconGenerator
//
//  Created by Eskil Gjerde Sviggum on 22/11/2023.
//

import SwiftUI

#if canImport(UIKit)
struct DocumentExporter: UIViewControllerRepresentable {

    var exporting: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentExporter>) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forExporting: [exporting])
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentExporter>) {
    }

}
#endif
