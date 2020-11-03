//
//  CGImageCropper.swift
//  MLScreenShot
//
//  Created by Trystan Rivers on 2020/11/03.
//  Copyright © 2020 Trystan Rivers. All rights reserved.
//

import Cocoa
import Foundation
import Vision
import CoreGraphics

public enum FaceCropResult {
    case success(CGImage)
    case notFound
    case failure(Error)
}

public extension CGImage {
    func getCroppingRectSingle(for face: VNFaceObservation, margin: CGFloat) -> CGRect {
        var totalX = CGFloat(0)
        var totalY = CGFloat(0)
        var totalW = CGFloat(0)
        var totalH = CGFloat(0)
        
        var minX = CGFloat.greatestFiniteMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        let numFaces = CGFloat(1)

        let w = face.boundingBox.width * CGFloat(width)
        let h = face.boundingBox.height * CGFloat(height)
        let x = face.boundingBox.origin.x * CGFloat(width)
        
        let y = (1 - face.boundingBox.origin.y) * CGFloat(height) - h
        
        totalX += x
        totalY += y
        totalW += w
        totalH += h
        minX = .minimum(minX, x)
        minY = .minimum(minY, y)
        
        // 7
        let avgX = totalX / numFaces
        let avgY = totalY / numFaces
        let avgW = totalW / numFaces
        let avgH = totalH / numFaces
        
        // 8
        let offset = margin + avgX - minX
        
        // 9
        return CGRect(x: avgX - offset, y: avgY - offset, width: avgW + (offset * 2), height: avgH + (offset * 2))
    }

    func faceCropSingle(face: VNFaceObservation ,margin: CGFloat = 100, completion: @escaping (FaceCropResult) -> Void) {
        let croppingRect = self.getCroppingRectSingle(for: face, margin: margin)
        let faceImage = self.cropping(to: croppingRect)
        
        guard let result = faceImage else {
            completion(.notFound)
            return
        }
        
        completion(.success(result))
    }
    
    func faceCrop(margin: CGFloat = 0, completion: @escaping (FaceCropResult) -> Void) {
        let req = VNDetectFaceRectanglesRequest { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let results = request.results else {
                completion(.notFound)
                return
            }
            
            var faces: [VNFaceObservation] = []
            for result in results {
                guard let face = result as? VNFaceObservation else { continue }
                faces.append(face)
            }
            
            let croppingRect = self.getCroppingRect(for: faces, margin: margin)
            let faceImage = self.cropping(to: croppingRect)
            
            guard let result = faceImage else {
                completion(.notFound)
                return
            }
            
            completion(.success(result))
        }
        
        do {
            try VNImageRequestHandler(cgImage: self, options: [:]).perform([req])
        } catch let error {
            completion(.failure(error))
        }
    }
    
    private func getCroppingRect(for faces: [VNFaceObservation], margin: CGFloat) -> CGRect {
        var totalX = CGFloat(0)
        var totalY = CGFloat(0)
        var totalW = CGFloat(0)
        var totalH = CGFloat(0)
        
        var minX = CGFloat.greatestFiniteMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        let numFaces = CGFloat(faces.count)
        
        for face in faces {
            
            let w = face.boundingBox.width * CGFloat(width)
            let h = face.boundingBox.height * CGFloat(height)
            let x = face.boundingBox.origin.x * CGFloat(width)
            
            let y = (1 - face.boundingBox.origin.y) * CGFloat(height) - h
            
            totalX += x
            totalY += y
            totalW += w
            totalH += h
            minX = .minimum(minX, x)
            minY = .minimum(minY, y)
        }
        
        let avgX = totalX / numFaces
        let avgY = totalY / numFaces
        let avgW = totalW / numFaces
        let avgH = totalH / numFaces
        
        let offset = margin + avgX - minX
        
        return CGRect(x: avgX - offset, y: avgY - offset, width: avgW + (offset * 2), height: avgH + (offset * 2))
    }
}
