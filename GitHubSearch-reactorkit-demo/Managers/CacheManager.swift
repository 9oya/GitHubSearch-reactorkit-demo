//
//  CacheManager.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/6/23.
//

import Kingfisher

protocol CacheManagerProtocol {
    
    func retrieveImage(
        with resource: Resource,
        options: KingfisherOptionsInfo?,
        progressBlock: DownloadProgressBlock?,
        downloadTaskUpdated: DownloadTaskUpdatedBlock?,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)?) -> DownloadTask?
    
}

extension KingfisherManager: CacheManagerProtocol {
}
