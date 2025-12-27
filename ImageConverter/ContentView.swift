//
//  ContentView.swift
//  ImageConverter
//
//  Created on 2025-12-27
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var selectedFormat: ImageFormat = .png
    @State private var quality: Double = 0.9
    @State private var isDragging = false
    @State private var selectedImages: [URL] = []
    @State private var statusMessage = ""
    @State private var isProcessing = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("محول صيغ الصور")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
                .padding(.top, 30)

            // Drop Zone
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(isDragging ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 500, height: 250)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isDragging ? Color.blue : Color.gray.opacity(0.3),
                                style: StrokeStyle(lineWidth: 3, dash: [10])
                            )
                    )

                VStack(spacing: 15) {
                    Image(systemName: isDragging ? "arrow.down.circle.fill" : "photo.on.rectangle.angled")
                        .font(.system(size: 60))
                        .foregroundColor(isDragging ? .blue : .gray)

                    Text(isDragging ? "أفلت الصور هنا" : "اسحب الصور هنا")
                        .font(.title2)
                        .foregroundColor(.secondary)

                    Text("أو انقر لاختيار الصور")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if !selectedImages.isEmpty {
                        Text("\(selectedImages.count) صورة محددة")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.top, 5)
                    }
                }
            }
            .onDrop(of: [.fileURL], isTargeted: $isDragging) { providers in
                handleDrop(providers: providers)
                return true
            }
            .onTapGesture {
                selectImagesFromDialog()
            }

            // Format Selection
            VStack(alignment: .leading, spacing: 10) {
                Text("اختر الصيغة المطلوبة:")
                    .font(.headline)

                HStack(spacing: 12) {
                    ForEach(ImageFormat.allCases) { format in
                        Button(action: {
                            selectedFormat = format
                        }) {
                            Text(format.rawValue)
                                .font(.system(size: 14, weight: .medium))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedFormat == format ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedFormat == format ? .white : .primary)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 40)

            // Quality Slider
            if selectedFormat == .jpeg || selectedFormat == .jpg || selectedFormat == .heic {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("الجودة:")
                            .font(.headline)
                        Text("\(Int(quality * 100))%")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Slider(value: $quality, in: 0.1...1.0, step: 0.1)
                        .frame(width: 300)
                }
                .padding(.horizontal, 40)
            }

            // Convert Button
            Button(action: {
                convertImages()
            }) {
                HStack {
                    if isProcessing {
                        ProgressView()
                            .scaleEffect(0.8)
                            .frame(width: 20, height: 20)
                    } else {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                    Text(isProcessing ? "جاري التحويل..." : "حول الصور")
                        .font(.headline)
                }
                .frame(width: 200, height: 44)
                .background(selectedImages.isEmpty || isProcessing ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(selectedImages.isEmpty || isProcessing)
            .buttonStyle(.plain)

            // Status Message
            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .padding(.horizontal, 40)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .frame(width: 600, height: 700)
        .alert("تنبيه", isPresented: $showAlert) {
            Button("حسناً", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier) { data, error in
                guard let data = data,
                      let path = String(data: data, encoding: .utf8),
                      let url = URL(string: path) else {
                    return
                }

                let fileURL = URL(fileURLWithPath: url.path)

                if isImageFile(url: fileURL) {
                    DispatchQueue.main.async {
                        if !selectedImages.contains(fileURL) {
                            selectedImages.append(fileURL)
                        }
                    }
                }
            }
        }
    }

    private func selectImagesFromDialog() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.image, .png, .jpeg, .tiff, .gif, .bmp, .heic]
        panel.message = "اختر الصور المراد تحويلها"

        if panel.runModal() == .OK {
            selectedImages = panel.urls.filter { isImageFile(url: $0) }
        }
    }

    private func isImageFile(url: URL) -> Bool {
        let imageExtensions = ["png", "jpg", "jpeg", "tiff", "tif", "bmp", "gif", "heic", "heif", "webp"]
        return imageExtensions.contains(url.pathExtension.lowercased())
    }

    private func convertImages() {
        guard !selectedImages.isEmpty else { return }

        isProcessing = true
        statusMessage = ""

        Task {
            do {
                let savePanel = NSSavePanel()
                savePanel.message = "اختر مجلد حفظ الصور المحولة"
                savePanel.canCreateDirectories = true
                savePanel.nameFieldStringValue = "converted_images"

                let response = await savePanel.beginSheetModal(for: NSApp.keyWindow!)

                if response == .OK, let saveURL = savePanel.url {
                    try? FileManager.default.createDirectory(at: saveURL, withIntermediateDirectories: true)

                    var successCount = 0
                    var failCount = 0

                    for imageURL in selectedImages {
                        do {
                            let imageData = try ImageConverterService.convertImage(
                                from: imageURL,
                                to: selectedFormat,
                                quality: quality
                            )

                            let fileName = imageURL.deletingPathExtension().lastPathComponent
                            let newFileName = "\(fileName)_converted.\(selectedFormat.fileExtension)"
                            let outputURL = saveURL.appendingPathComponent(newFileName)

                            try ImageConverterService.saveImage(data: imageData, to: outputURL)
                            successCount += 1

                        } catch {
                            print("Error converting \(imageURL.lastPathComponent): \(error)")
                            failCount += 1
                        }
                    }

                    await MainActor.run {
                        isProcessing = false
                        if failCount == 0 {
                            statusMessage = "تم تحويل \(successCount) صورة بنجاح! ✓"
                        } else {
                            statusMessage = "تم تحويل \(successCount) صورة، فشل \(failCount)"
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            selectedImages.removeAll()
                            statusMessage = ""
                        }
                    }
                } else {
                    await MainActor.run {
                        isProcessing = false
                    }
                }

            } catch {
                await MainActor.run {
                    isProcessing = false
                    alertMessage = "حدث خطأ أثناء التحويل: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
