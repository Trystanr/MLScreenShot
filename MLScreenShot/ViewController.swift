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

import PythonKit

class ViewController: NSViewController {

    @IBOutlet var imgScreenshotView: NSImageView!
    @IBOutlet var lblFaceCount: NSTextField!
    
    @IBOutlet var newImgView: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(Python.version)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func btnScreenshotPressed(_ sender: Any) {
        TakeScreensShot(folderName: "Capture-")
    }
    
    func runPythonCode(filepath: String) -> PythonObject {
       let sys = Python.import("sys")
       sys.path.append("/Users/trystan/Desktop/ML-Python/")
       let example = Python.import("face_plot_swift")
       return example.get_name(filepath)[0][0]
    }
    
    func TakeScreensShot(folderName: String){
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
                
                
                let detectFaceRequest = VNDetectFaceRectanglesRequest { (request, error) in

                  if let results = request.results as? [VNFaceObservation] {
                    print(results.count)
                    
                    self.lblFaceCount.stringValue = String(results.count)
                    
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
                                    
                                    let subView = NSImageView(frame: fr)
                                    subView.image = NSImage(cgImage: cgImage, size: NSSize(width: 224, height: 224))
                                    self?.newImgView.addSubview(subView)
                                    
                                    let fileUrlFace = URL(fileURLWithPath: folderName + "\(unixTimestamp)" + "_" + "\(i)" + "_face.jpg", isDirectory: true)
                                    let bitmapRepFace = NSBitmapImageRep(cgImage: cgImage)
                                    let jpegDataFace = bitmapRepFace.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!

                                    do {
                                        print("\n")
                                        print("Face Detection\n")
                                        
                                        let start = fileUrlFace.absoluteString.index(fileUrlFace.absoluteString.startIndex, offsetBy: 7)
                                        let end = fileUrlFace.absoluteString.index(fileUrlFace.absoluteString.endIndex, offsetBy: -1)
                                        let range = start..<end

                                        let mySubstring = fileUrlFace.absoluteString[range]
                                    
                                        try jpegDataFace.write(to: fileUrlFace, options: .atomic)
                                        
                                        let faceName = self?.runPythonCode(filepath: String(mySubstring))
                                        
                                        let faceNameUnwrapped = String(faceName!)!
                                        let faceStart = faceNameUnwrapped.index(faceNameUnwrapped.startIndex, offsetBy: 3)
                                        let faceEnd = faceNameUnwrapped.index(faceNameUnwrapped.endIndex, offsetBy: -1)
                                        let faceRange = faceStart..<faceEnd

                                        let faceNameCapped = faceNameUnwrapped[faceRange]
                                        
                                        let label = NSTextField()
                                        label.frame = CGRect(origin: CGPoint.init(x: i * 110, y: 0), size: CGSize(width: 100, height: 44))
                                        label.stringValue = String(faceNameCapped)
                                        label.backgroundColor = .white
                                        label.textColor = .black
                                        label.isBezeled = false
                                        label.isEditable = false
                                        label.sizeToFit()
                                        
                                        self?.newImgView.addSubview(label)
                                    }
                                        catch {print("error: \(error)")}
                                }
                            case .notFound, .failure( _):
                                print("error")
                            default:
                                print("something went very wrong")
                            }
                        })
                        

                    }
                    
                    
                    self.view.addSubview(line)

                  }
                }
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

