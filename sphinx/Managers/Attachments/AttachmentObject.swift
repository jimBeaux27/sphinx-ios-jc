//
//  AttachmentObject.swift
//  sphinx
//
//  Created by Tomas Timinskas on 20/04/2020.
//  Copyright © 2020 Tomas Timinskas. All rights reserved.
//

import UIKit

public struct AttachmentObject {
    var data: Data!
    var image: UIImage?
    var mediaKey: String?
    var type: AttachmentsManager.AttachmentType
    var text: String?
    var paidMessage: String?
    var price: Int = 0
    var fileName: String? = nil
    
    init(data: Data,
         fileName: String? = nil,
         mediaKey: String? = nil,
         type: AttachmentsManager.AttachmentType,
         text: String? = nil,
         paidMessage: String? = nil,
         image: UIImage? = nil,
         price: Int = 0) {
        
        self.data = data
        self.fileName = fileName
        self.mediaKey = mediaKey
        self.type = type
        self.image = image
        self.text = text
        self.paidMessage = paidMessage
        self.price = price
    }
    
    func getUploadData() -> Data? {
        if type == AttachmentsManager.AttachmentType.Audio ||
           type == AttachmentsManager.AttachmentType.Gif ||
           type == AttachmentsManager.AttachmentType.Text ||
           type == AttachmentsManager.AttachmentType.GenericFile ||
           type == AttachmentsManager.AttachmentType.PDF {
            return data
        }
        return nil
    }
    
    func getMessageData() -> Data? {
        if type == AttachmentsManager.AttachmentType.Text {
            return data
        }
        return nil
    }
    
    func getDecryptedData() -> Data? {
        if let data = getUploadData(), let mediaKey = mediaKey, let decryptedData = SymmetricEncryptionManager.sharedInstance.decryptData(data: data, key: mediaKey) {
            return decryptedData
        }
        return nil
    }
    
    func getNameParam() -> String {
        switch(type) {
        case .Photo, .Gif:
            return "image"
        case .Video:
            return "video"
        case .Audio:
            return "audio"
        case .Text:
            return "text"
        case .PDF:
            return "file"
        case .GenericFile:
            return "file"
        }
    }
    
    func getMimeType() -> String {
        return getFileAndMime().1
    }
    
    func getFileName() -> String {
        return getFileAndMime().0
    }
    
    func getFileAndMime() -> (String, String) {
        return AttachmentObject.getFileAndMime(type: self.type, fileName: self.fileName)
    }
    
    static func getFileAndMime(type: AttachmentsManager.AttachmentType, fileName: String?) -> (String, String) {
        switch (type) {
            case .Video:
                return ("video.mov", "video/mov")
            case .Photo:
                return ("image.jpg", "image/jpg")
            case .Audio:
                return ("audio.m4a", "audio/m4a")
            case .Text:
                return ("message.txt", "sphinx/text")
            case .Gif:
                return ("image.gif", "image/gif")
            case .PDF:
                return (fileName ?? "file.pdf", "application/pdf")
            case .GenericFile:
                return (fileName ?? "file", fileName?.mimeTypeForPath() ?? "file.txt")
        }
    }
}
