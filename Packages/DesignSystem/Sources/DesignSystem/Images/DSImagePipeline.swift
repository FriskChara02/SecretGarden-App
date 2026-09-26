//
//  DSImagePipeline.swift
//  DesignSystem
//
//  Created by Loi Nguyen on 26/9/26.
//

// The ONLY place in the entire app allowed to configure Nuke's ImagePipeline
// (memory cache + disk cache). Call configure() exactly once, as early as possible
// (App init) — following the same pattern as DSFontRegistrar.registerFonts().
// No other file is permitted to create its own ImageCache/DataCache/ImagePipeline.

import Nuke
import Foundation

public enum DSImagePipeline {

    public static func configure() {
        let memoryCache = ImageCache()
        memoryCache.costLimit = 150 * 1024 * 1024   // ~150MB of decoded images in RAM
        memoryCache.countLimit = 200                 // maximum of 200 photos held simultaneously

        let dataCache = try? DataCache(name: "com.yourname.secretgarden.imagecache")
        dataCache?.sizeLimit = 300 * 1024 * 1024    // ~300MB of original images on the drive

        var configuration = ImagePipeline.Configuration()
        configuration.imageCache = memoryCache
        configuration.dataCache = dataCache
        configuration.dataCachePolicy = .automatic

        ImagePipeline.shared = ImagePipeline(configuration: configuration)
    }
}
