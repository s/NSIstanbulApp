//
//  imageDownloadingService.swift
//  Saturdays
//
//  Created by Said Ozcan on 04/06/2017.
//  Copyright © 2017 Said Ozcan. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

public enum ImageDownloadServiceResult {
    case success(UIImage)
    case failure(Error)
}

public class ImageDownloadingService {
    
    //MARK: Properties
    fileprivate lazy var imageDownloader : ImageDownloader = {
        return ImageDownloader(
            configuration: ImageDownloader.defaultURLSessionConfiguration(),
            downloadPrioritization: .lifo,
            maximumActiveDownloads: 4,
            imageCache: AutoPurgingImageCache()
        )
    }()
    fileprivate var receipts : [URL:RequestReceipt] = [:]
    
    //MARK: Lifecycle
    public init() {}
    
    //MARK: Public
    public func download(url: URL,
                  downloadProgressHandler: ((Progress) -> Void)?,
                  completionHandler:((ImageDownloadServiceResult, URL) -> Void)?)
    {
        let downloadRequest = URLRequest(url: url)
        let receipt : RequestReceipt? = imageDownloader.download(downloadRequest) { response in
            guard let completionHandler = completionHandler else { return }
            if let error = response.error {
                completionHandler(ImageDownloadServiceResult.failure(error), url)
                return
            }
            
            if let image = response.result.value {
                self.receipts[url] = nil
                completionHandler(ImageDownloadServiceResult.success(image), url)
                return
            } else {
                //TODO: return an error
                return
            }
        }
        if let receipt = receipt {
            self.receipts[url] = receipt
        }
    }
    
    public func cancel(downloading url:URL) {
        if let receipt = self.receipts[url] {
            imageDownloader.cancelRequest(with: receipt)
        }
    }
    
    public func prefetch(_ imageUrls:[URL]) {
        for url in imageUrls {
            self.download(url: url, downloadProgressHandler: nil, completionHandler: nil)
        }
    }
    
    public func cancelPrefetcing(_ imageUrls:[URL]) {
        for url in imageUrls {
            self.cancel(downloading: url)
        }
    }

}

public extension UIImageView {
    
    public func setImage(url: URL) {
        self.af_setImage(withURL: url)
    }
    
}
