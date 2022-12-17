//
//  StableDiffusionManager.swift
//  StableDiffusionSwift
//
//  Created by Jia Chen Yee on 17/12/22.
//

import Foundation
import StableDiffusion
import CoreGraphics

@MainActor class StableDiffusionManager: ObservableObject {
    
    struct Image: Identifiable {
        var index: Int
        var cgImage: CGImage
        
        var id: Int { index }
    }
    
    @Published var progress: Double = 0
    
    @Published var images: [Image] = []
    
    @Published var isReady = false
    
    var pipeline: StableDiffusionPipeline!
    
    init() {
        Task(priority: .high) {
            let resourceURL = Bundle.main.url(forResource: "ML Models", withExtension: nil)!
            
            let pipeline = try StableDiffusionPipeline(resourcesAt: resourceURL)
            try pipeline.loadResources()
            
            self.pipeline = pipeline
            self.isReady = true
        }
    }
    
    func setProgress(progress: StableDiffusionPipeline.Progress) {
        self.progress = Double(progress.step + 1) / Double(progress.stepCount + 1)
        self.images = progress.currentImages.enumerated().compactMap { (n, image) in
            if let image {
                return Image(index: n, cgImage: image)
            } else {
                return nil
            }
        }
    }
    
    func setImages(currentImages: [CGImage?]) {
        self.progress = 1
        isReady = true
        self.images = currentImages.enumerated().compactMap { (n, image) in
            if let image {
                return Image(index: n, cgImage: image)
            } else {
                return nil
            }
        }
    }
    
    func generateImage(prompt: String,
                       imageCount: Int = 1,
                       stepCount: Int = 50,
                       seed: Int = 0,
                       disableSafety: Bool = false) {
        isReady = false
        progress = 0
        
        Task.detached(priority: .high) {
            let images = try await self.pipeline.generateImages(prompt: prompt,
                                                                imageCount: imageCount,
                                                                stepCount: stepCount,
                                                                seed: seed,
                                                                disableSafety: disableSafety) { progress in
                DispatchQueue.main.async {
                    self.setProgress(progress: progress)
                }
                
                return true
            }
            await self.setImages(currentImages: images)
        }
    }
}
