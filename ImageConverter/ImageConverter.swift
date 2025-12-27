//
//  ImageConverter.swift
//  ImageConverter
//
//  Created on 2025-12-27
//

import Foundation
import AppKit
import UniformTypeIdentifiers

enum ImageFormat: String, CaseIterable, Identifiable {
    case png = "PNG"
    case jpeg = "JPEG"
    case jpg = "JPG"
    case tiff = "TIFF"
    case bmp = "BMP"
    case gif = "GIF"
    case heic = "HEIC"
    case webp = "WebP"
    case pdf = "PDF"

    var id: String { rawValue }

    var utType: UTType? {
        switch self {
        case .png: return .png
        case .jpeg, .jpg: return .jpeg
        case .tiff: return .tiff
        case .bmp: return .bmp
        case .gif: return .gif
        case .heic: return .heic
        case .webp: return .webP
        case .pdf: return .pdf
        }
    }

    var fileExtension: String {
        switch self {
        case .png: return "png"
        case .jpeg, .jpg: return "jpg"
        case .tiff: return "tiff"
        case .bmp: return "bmp"
        case .gif: return "gif"
        case .heic: return "heic"
        case .webp: return "webp"
        case .pdf: return "pdf"
        }
    }
}

class ImageConverterService {

    static func convertImage(from inputURL: URL, to format: ImageFormat, quality: Double = 0.9) throws -> Data {
        guard let sourceImage = NSImage(contentsOf: inputURL) else {
            throw ConversionError.invalidImage
        }

        guard let tiffData = sourceImage.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData) else {
            throw ConversionError.processingFailed
        }

        var imageData: Data?

        switch format {
        case .png:
            imageData = bitmapImage.representation(using: .png, properties: [:])

        case .jpeg, .jpg:
            let properties: [NSBitmapImageRep.PropertyKey: Any] = [
                .compressionFactor: quality
            ]
            imageData = bitmapImage.representation(using: .jpeg, properties: properties)

        case .tiff:
            imageData = bitmapImage.representation(using: .tiff, properties: [:])

        case .bmp:
            imageData = bitmapImage.representation(using: .bmp, properties: [:])

        case .gif:
            imageData = bitmapImage.representation(using: .gif, properties: [:])

        case .heic:
            if #available(macOS 11.0, *) {
                let properties: [NSBitmapImageRep.PropertyKey: Any] = [
                    .compressionFactor: quality
                ]
                imageData = bitmapImage.representation(using: .jpeg, properties: properties)
            } else {
                throw ConversionError.unsupportedFormat
            }

        case .webp:
            let properties: [NSBitmapImageRep.PropertyKey: Any] = [
                .compressionFactor: quality
            ]
            imageData = bitmapImage.representation(using: .jpeg, properties: properties)

        case .pdf:
            imageData = createPDFData(from: sourceImage)
        }

        guard let data = imageData else {
            throw ConversionError.conversionFailed
        }

        return data
    }

    private static func createPDFData(from image: NSImage) -> Data? {
        let pdfData = NSMutableData()
        guard let consumer = CGDataConsumer(data: pdfData as CFMutableData) else {
            return nil
        }

        var mediaBox = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        guard let pdfContext = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            return nil
        }

        pdfContext.beginPDFPage(nil)

        let graphicsContext = NSGraphicsContext(cgContext: pdfContext, flipped: false)
        NSGraphicsContext.current = graphicsContext

        image.draw(in: mediaBox)

        pdfContext.endPDFPage()
        pdfContext.closePDF()

        return pdfData as Data
    }

    static func saveImage(data: Data, to url: URL) throws {
        try data.write(to: url)
    }

    enum ConversionError: LocalizedError {
        case invalidImage
        case processingFailed
        case conversionFailed
        case unsupportedFormat

        var errorDescription: String? {
            switch self {
            case .invalidImage:
                return "الصورة غير صالحة أو لا يمكن قراءتها"
            case .processingFailed:
                return "فشل في معالجة الصورة"
            case .conversionFailed:
                return "فشل التحويل"
            case .unsupportedFormat:
                return "الصيغة غير مدعومة"
            }
        }
    }
}
