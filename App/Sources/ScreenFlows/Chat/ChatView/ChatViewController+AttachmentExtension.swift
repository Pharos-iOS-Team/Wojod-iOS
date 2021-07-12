// Copyright © 2021 Pharos Solutions. All rights reserved.

import InputBarAccessoryView
import UIKit

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func pickImage(pickImageFrom: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = pickImageFrom
        imagePicker.modalPresentationStyle = .overFullScreen
        imagePicker.modalTransitionStyle = .crossDissolve
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            viewModel.selectedImage = image
            self.messageInputBar.inputPlugins.forEach {
                if let attach = $0 as? AttachmentManager {
                    attach.handleInput(of: image)
                }
            }
        }
        dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

extension ChatViewController: UIDocumentPickerDelegate {
    func setDocumentPicker() {
        documentPicker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .open).with {
            $0.modalPresentationStyle = .fullScreen
            $0.allowsMultipleSelection = false
            $0.delegate = self
        }
    }

    func pickFile() {
        guard let documentPicker = documentPicker else { return }
        present(documentPicker, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        urls.forEach { _ = $0.startAccessingSecurityScopedResource() }
        viewModel.selectedFile = urls.first
        self.messageInputBar.inputPlugins.forEach {
            if let attach = $0 as? AttachmentManager {
                attach.handleInput(of: urls.first as AnyObject)
            }
        }
    }
}
