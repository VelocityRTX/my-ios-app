//
//  ProfilePictureSelectionView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/28/25.
//

import SwiftUI
import PhotosUI

// Update ProfilePictureSelectionView
struct ProfilePictureSelectionView: View {
    @ObservedObject var introViewModel: IntroTutorialViewModel
    @State private var isShowingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        VStack {
            Text("Profile Picture")
                .font(.largeTitle)
                .padding()
            
            Text("Add a photo to personalize your profile")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let image = introViewModel.profileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .padding()
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 150, height: 150)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.gray)
                    )
                    .padding()
            }
            
            VStack(spacing: 15) {
                Button(action: {
                    sourceType = .photoLibrary
                    isShowingImagePicker = true
                }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Choose from Library")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.theme.accent)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                // Only show camera button if camera is available
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button(action: {
                        sourceType = .camera
                        isShowingImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "camera")
                            Text("Take Photo")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.theme.secondary)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                
                Button(action: {
                    // Skip setting profile pic
                    introViewModel.currentPage += 1
                }) {
                    Text("Skip for now")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .padding()
        }
        .sheet(isPresented: $isShowingImagePicker) {
            // Make sure to provide sourceType parameter
            ImagePicker(selectedImage: $introViewModel.profileImage, sourceType: sourceType)
        }
    }
}

// Add this to the same file
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
