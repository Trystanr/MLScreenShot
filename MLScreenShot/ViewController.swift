//
//  ViewController.swift
//  MLScreenShot
//
//  Created by Trystan Rivers on 2020/10/06.
//  Copyright © 2020 Trystan Rivers. All rights reserved.
//

import Cocoa
import Foundation
import Vision
import CoreGraphics

public extension CGImage {
    func getCroppingRectSingle(for face: VNFaceObservation, margin: CGFloat) -> CGRect {
        // 2
        var totalX = CGFloat(0)
        var totalY = CGFloat(0)
        var totalW = CGFloat(0)
        var totalH = CGFloat(0)
        
        // 3
        var minX = CGFloat.greatestFiniteMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        let numFaces = CGFloat(1)
        
        // 4

       // 5
        let w = face.boundingBox.width * CGFloat(width)
       let h = face.boundingBox.height * CGFloat(height)
       let x = face.boundingBox.origin.x * CGFloat(width)
       
       // 6
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

    func faceCropSingle(face: VNFaceObservation ,margin: CGFloat = 0, completion: @escaping (FaceCropResult) -> Void) {
//            let croppingRect = self.getCroppingRect(for: faces, margin: margin)
        
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
            
            // 1
            let croppingRect = self.getCroppingRect(for: faces, margin: margin)
                                                 
            // 10
            let faceImage = self.cropping(to: croppingRect)
            
            // 11
            guard let result = faceImage else {
                completion(.notFound)
                return
            }
            
            // 12
            completion(.success(result))
        }
        
        do {
            try VNImageRequestHandler(cgImage: self, options: [:]).perform([req])
        } catch let error {
            completion(.failure(error))
        }
    }
    
    private func getCroppingRect(for faces: [VNFaceObservation], margin: CGFloat) -> CGRect {
        
        // 2
        var totalX = CGFloat(0)
        var totalY = CGFloat(0)
        var totalW = CGFloat(0)
        var totalH = CGFloat(0)
        
        // 3
        var minX = CGFloat.greatestFiniteMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        let numFaces = CGFloat(faces.count)
        
        // 4
        for face in faces {
            
            // 5
            let w = face.boundingBox.width * CGFloat(width)
            let h = face.boundingBox.height * CGFloat(height)
            let x = face.boundingBox.origin.x * CGFloat(width)
            
            // 6
            let y = (1 - face.boundingBox.origin.y) * CGFloat(height) - h
            
            totalX += x
            totalY += y
            totalW += w
            totalH += h
            minX = .minimum(minX, x)
            minY = .minimum(minY, y)
        }
        
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

    
}

public enum FaceCropResult {
    case success(CGImage)
    case notFound
    case failure(Error)
}

class Line: NSView {
    var myClassVar: Int!
    var arrFaces: [NSRect]! = []
    
    override init(frame frameRect: NSRect) {
        super.init(frame:frameRect);
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    init(frame frameRect: NSRect, otherInfo:Int) {
        super.init(frame:frameRect);
    }
    
    func setVar(i: Int) {
        self.myClassVar  = i
    }
    
    func addFace(n: CGRect) {
        self.arrFaces.append(n)
    }

    override func draw(_ dirtyRect: NSRect) {
        let myPath = NSBezierPath()
        
        let winPath = NSBezierPath()
        
        let clearPath = NSBezierPath()
        NSColor.red.setStroke()
        
        
        
        clearPath.move(to: NSPoint(x: 0, y: 0))
        clearPath.line(to: NSPoint(x: 0, y: self.frame.height))
        clearPath.line(to: NSPoint(x: self.frame.width, y: self.frame.height))
        clearPath.line(to: NSPoint(x: self.frame.width, y: 0))
        clearPath.line(to: NSPoint(x: 0, y: 0))
        
        
//        winPath.move(to: NSPoint(x: 0, y: 0))
//        winPath.line(to: NSPoint(x: self.frame.width, y: self.frame.height))
//        winPath.stroke()
        
        for face in arrFaces {
            print("Face at:")
            print(face)
            
            
            myPath.move(to: CGPoint(x: face.origin.x, y: face.origin.y))
            myPath.line(to: CGPoint(x: face.origin.x, y: face.origin.y + face.height))
            myPath.line(to: CGPoint(x: face.origin.x + face.width, y: face.origin.y + face.height))
            myPath.line(to: CGPoint(x: face.origin.x + face.width, y: face.origin.y))
            myPath.line(to: CGPoint(x: face.origin.x, y: face.origin.y))
            myPath.stroke()
        }
    }
}

class ViewController: NSViewController {

    @IBOutlet var imgScreenshotView: NSImageView!
    @IBOutlet var lblFaceCount: NSTextField!
    
//    @IBOutlet var imgFaceView: NSImageView!
//    @IBOutlet var imgFaceView2: NSImageView!
    
//    @IBOutlet var miniFaceView: NSView!
//    @IBOutlet var miniClipView: NSClipView!
//    @IBOutlet var miniScrollView: NSScrollView!
    
    @IBOutlet var newImgView: NSView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func btnScreenshotPressed(_ sender: Any) {
        TakeScreensShots(folderName: "Capture-")
    }
    
    func TakeScreensShots(folderName: String){
        
        var displayCount: UInt32 = 0;
        var result = CGGetActiveDisplayList(0, nil, &displayCount)
        if (result != CGError.success) {
            print("error: \(result)")
            return
        }
        let allocated = Int(displayCount)
        let activeDisplays = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: allocated)
        result = CGGetActiveDisplayList(displayCount, activeDisplays, &displayCount)
        
        if (result != CGError.success) {
            print("error: \(result)")
            return
        }
           
        for i in 1...displayCount {
            let unixTimestamp = CreateTimeStamp()
            let fileUrl = URL(fileURLWithPath: folderName + "\(unixTimestamp)" + "_" + "\(i)" + ".jpg", isDirectory: true)
            let screenShot:CGImage = CGDisplayCreateImage(activeDisplays[Int(i-1)])!
            let bitmapRep = NSBitmapImageRep(cgImage: screenShot)
            let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
            
            
            do {
                print(fileUrl)
                try jpegData.write(to: fileUrl, options: .atomic)
                
                imgScreenshotView.image = NSImage(byReferencing: fileUrl)
                
                let nsImg = NSImage(byReferencing: fileUrl)
                
                guard let cgImg = nsImg.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                    fatalError("can't convert image")
                }
                
                let sourceImage = NSImage(byReferencing: fileUrl)
                var resultImage = sourceImage
                
                let  detectFaceRectangles = VNDetectFaceRectanglesRequest { (request, error) in
                    if let results = request.results as? [VNFaceObservation] {
                        
                        print(results.count)
                        self.lblFaceCount.stringValue = String(results.count)
                        
//
                        for result in  results {
                            
//                            let croppingRect = CGRect(
                            
                        }
                        
                        
                    }
                }
                
                let detectFaceRequest = VNDetectFaceLandmarksRequest { (request, error) in
                  //4
                  if let results = request.results as? [VNFaceObservation] {
                    print(results.count)
                    
                    self.lblFaceCount.stringValue = String(results.count)
//                    self.imgScreenshotView.alphaValue = 0.1
                    
                    
                    let frame = self.imgScreenshotView.frame
                    
                    let line = Line(frame: frame)
                    line.translatesAutoresizingMaskIntoConstraints = true
                    line.autoresizingMask = [.maxXMargin, .maxYMargin, .minXMargin, .minYMargin, .width, .height]
                    
                    
                    
                    for (i, faceObservation) in results.enumerated() {
                        let boundingBox = faceObservation.boundingBox
                        
                        let size = CGSize(width: boundingBox.width * self.imgScreenshotView.bounds.width,
                                          height: boundingBox.height * self.imgScreenshotView.bounds.height)
                        let origin = CGPoint(x: boundingBox.minX * self.imgScreenshotView.bounds.width,
                                             y: (faceObservation.boundingBox.minY) * self.imgScreenshotView.bounds.height)
                        
                        
                        line.addFace(n: CGRect(origin: origin, size: size))
                        
                        cgImg.faceCropSingle(face: faceObservation ,completion: { [weak self] result in
                            switch result {
                            case .success(let cgImage):
                                DispatchQueue.main.async {
                                   
                                    
                                    let fr: NSRect = NSMakeRect(CGFloat(i * 110), 0, 100, 100)
                                    let v: NSView = NSView(frame: fr)
                                    v.wantsLayer = true
                                    
                                    v.layer?.backgroundColor = NSColor.green.cgColor
                                    
                                    self?.newImgView.addSubview(v)
                                    
                                    var subView = NSImageView(frame: fr)
                                    subView.image = NSImage(cgImage: cgImage, size: NSSize(width: 100, height: 100))
                                    self?.newImgView.addSubview(subView)
                                    
                                    
//                                    self?.imgFaceView.image = NSImage(cgImage: cgImage, size: NSSize(width: 100, height: 100))
                                }
                            case .notFound, .failure( _):
                                print("error")
                            default:
                                print("something went very wrong")
                            }
                        })
                        
                        

                    }
                    
                    
                    self.view.addSubview(line)
                    
                    //5
//                    for faceObservation in results {
//                      //6
//                      guard let landmarks = faceObservation.landmarks else {
//                          continue
//                      }
//                      let boundingRect = faceObservation.boundingBox
//                      var landmarkRegions: [VNFaceLandmarkRegion2D] = []
//                      //7
//                      if let faceContour = landmarks.faceContour {
//                          landmarkRegions.append(faceContour)
//                      }
//                      //8
////                      resultImage = self.drawOnImage(source: resultImage, boundingRect: boundingRect, faceLandmarkRegions: landmarkRegions)
//                    }
                  }
                }
                //3
                let vnImage = VNImageRequestHandler(cgImage: cgImg, options: [:])
                try? vnImage.perform([detectFaceRequest])
               
                
                
            }
            catch {print("error: \(error)")}
        }
    }

    func CreateTimeStamp() -> Int32
    {
        return Int32(Date().timeIntervalSince1970)
    }
    
    func detectedFace(request: VNRequest, error: Error?) {
      // 1
      guard
        let results = request.results as? [VNFaceObservation],
        let result = results.first
        else {
          // 2
          // No face  detected
          return
      }
        
      // 3
      let box = result.boundingBox
      print(box)
    }
    
    

    


    
}

