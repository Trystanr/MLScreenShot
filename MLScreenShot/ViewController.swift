//
//  ViewController.swift
//  MLScreenShot
//
//  Created by Trystan Rivers on 2020/10/06.
//  Copyright © 2020 Trystan Rivers. All rights reserved.
//

import Cocoa
import Vision


class ViewController: NSViewController {

    @IBOutlet var imgScreenshotView: NSImageView!
    @IBOutlet var lblFaceCount: NSTextField!
    
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
                
                let detectFaceRequest = VNDetectFaceLandmarksRequest { (request, error) in
                  //4
                  if let results = request.results as? [VNFaceObservation] {
                    print(results.count)
                    self.lblFaceCount.stringValue = String(results.count)
                  

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

