//
//  FacesViewController.swift
//  MLScreenShot
//
//  Created by Trystan Rivers on 2020/11/03.
//  Copyright © 2020 Trystan Rivers. All rights reserved.
//

import Cocoa
import Foundation
import Vision
import CoreGraphics

import PythonKit

class View: NSView {
  override var isFlipped: Bool { return true }
}

class FacesViewController: NSViewController {
    
    @IBOutlet var FaceView: NSView!
    @IBOutlet var faceLabel: NSTextField!
    @IBOutlet var faceButton: NSButton!
    @IBOutlet var faceLoading: NSProgressIndicator!
    @IBOutlet var faceCountLabel: NSTextField!
    
    typealias CompletionHandler = (_ success:Array<String>) -> Void
    
    var facesLoaded = false
    var globalFaceCount = 0
    
    var classStudents = [
        "Britney_Spears",
        "Brad_Pitt",
        "Sharon_Stone",
        "Dwayne_Johnson",
        "Whoopi_Goldberg",
    ]
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        if facesLoaded == true {
            var windowFrame:NSRect = self.view.window!.frame
            if ( globalFaceCount == 1) {
                windowFrame.size.width = 220.0
                windowFrame.origin.x -= 40.0
            } else if ( globalFaceCount == 2) {
                windowFrame.size.width = 300.0
            } else if ( globalFaceCount == 3) {
                windowFrame.size.width = 380.0
            } else {
                windowFrame.size.width = 460.0
                windowFrame.origin.x -= 170.0
            }
            
            self.view.window!.setFrame(windowFrame, display: true, animate: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func faceScreenshotClick(_ sender: Any) {
        faceButton.isHidden = true
        faceLoading.isHidden  = false
        faceLoading.startAnimation(self)
        
        facesLoaded = true
        DispatchQueue.main.async {
            self.TakeScreensShot(folderName: "Capture-", completionHandler: { (presentStudents) -> Void in
                self.faceLoading.stopAnimation(self)
                self.faceLoading.isHidden = true
                self.faceCountLabel.isHidden = false
                
                self.globalFaceCount = presentStudents.count
                if (presentStudents.count != self.classStudents.count) {
                    let set2 = Set(presentStudents)
                    print("absent students")
                    print(self.classStudents.filter {!set2.contains($0)} )
                    self.faceCountLabel.stringValue = String(presentStudents.count) + "/" + String(self.classStudents.count)
                }
                
                print("present students")
                print(presentStudents)
                
                NSAnimationContext.runAnimationGroup({
                    (context: NSAnimationContext!) -> Void in
                        context.duration = 0.33
                        context.allowsImplicitAnimation = true

                        var windowFrame:NSRect = self.view.window!.frame
//                        windowFrame.size.width = 460.0
                        if ( presentStudents.count == 1) {
                            windowFrame.size.width = 220.0
                            windowFrame.origin.x -= 40.0
                        } else if ( presentStudents.count == 2) {
                            windowFrame.size.width = 300.0
                        } else if ( presentStudents.count == 3) {
                            windowFrame.size.width = 380.0
                        } else {
                            windowFrame.size.width = 460.0
                            windowFrame.origin.x -= 170.0
                        }
                        
                        
                        self.view.window!.setFrame(windowFrame, display: true, animate: true)
                    },
                    completionHandler:
                    {
                        () -> Void in
                    }
                )

            })
        }
        
    }
    
    func runPythonCode(filepath: String) -> PythonObject {
       let sys = Python.import("sys")
       sys.path.append("/Users/trystan/Desktop/ML-Python/")
       let example = Python.import("face_plot_swift")
       return example.get_name(filepath)[0][0]
    }
    
    func TakeScreensShot(folderName: String, completionHandler: CompletionHandler) {
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
        
        var presentStudents = [String]()
        
        
        
        for i in 1...displayCount {
            let unixTimestamp = CreateTimeStamp()
            let fileUrl = URL(fileURLWithPath: folderName + "\(unixTimestamp)" + "_" + "\(i)" + ".jpg", isDirectory: true)
            let screenShot:CGImage = CGDisplayCreateImage(activeDisplays[Int(i-1)])!
            let bitmapRep = NSBitmapImageRep(cgImage: screenShot)
            let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
            
            
            do {
                print(fileUrl)
                
                try jpegData.write(to: fileUrl, options: .atomic)

                let nsImg = NSImage(byReferencing: fileUrl)
                
                guard let cgImg = nsImg.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                    fatalError("can't convert image")
                }
                
                let detectFaceRequest = VNDetectFaceRectanglesRequest { (request, error) in

                  if let results = request.results as? [VNFaceObservation] {
                    print(results.count)
                    
                    var facesCount = results.count
                    self.faceCountLabel.stringValue = String(results.count)
                    
                    let subviewFrame = CGRect(origin: .zero, size: CGSize(width: 910, height: 100))

                    let documentView = View(frame: subviewFrame)
                    documentView.wantsLayer = true
                    
                    for (i, faceObservation) in results.enumerated() {
                        
                        cgImg.faceCropSingle(face: faceObservation ,completion: { [weak self] result in
                            switch result {
                            case .success(let cgImage):
//                                DispatchQueue.main.async {
                                    let fr: NSRect = NSMakeRect(CGFloat(i * 110), 0, 100, 100)
                                    let v: NSView = NSView(frame: fr)
                                    v.wantsLayer = true
                                    
                                    v.layer?.backgroundColor = NSColor.green.cgColor
                                    
                                    let fileUrlFace = URL(fileURLWithPath: folderName + "\(unixTimestamp)" + "_" + "\(i)" + "_face.jpg", isDirectory: true)
                                    let bitmapRepFace = NSBitmapImageRep(cgImage: cgImage)
                                    let jpegDataFace = bitmapRepFace.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
                                    
                                    do {
                                        print("\n")
                                        print("Face Detection")
                                        
                                        let start = fileUrlFace.absoluteString.index(fileUrlFace.absoluteString.startIndex, offsetBy: 7)
                                        let end = fileUrlFace.absoluteString.index(fileUrlFace.absoluteString.endIndex, offsetBy: -1)
                                        let range = start..<end

                                        let mySubstring = fileUrlFace.absoluteString[range]
                                    
                                        try jpegDataFace.write(to: fileUrlFace, options: .atomic)
                                        
//                                        let faceName = self?.runPythonCode(filepath: String(mySubstring))
//                                        let faceNameUnwrapped = String(faceName!)!
                                        
                                        let faceName = "111Name Surname1"
                                        let faceNameUnwrapped = faceName
                                        
                                        let faceStart = faceNameUnwrapped.index(faceNameUnwrapped.startIndex, offsetBy: 3)
                                        let faceEnd = faceNameUnwrapped.index(faceNameUnwrapped.endIndex, offsetBy: -1)
                                        let faceRange = faceStart..<faceEnd

                                        let faceNameCapped = faceNameUnwrapped[faceRange]
                                        
                                        let fr = CGRect(origin: CGPoint(x: (i*80)+0, y: 20), size: CGSize(width: 70, height: 70))
                                        let subView = NSImageView(frame: fr)
                                        subView.image = NSImage(cgImage: cgImage, size: NSSize(width: 224, height: 224))
                                        subView.wantsLayer = true
                                        subView.layer?.cornerRadius = 4.0
                                        subView.layer?.masksToBounds = true
                                        
                                        let gradient = CAGradientLayer()
                                        gradient.colors = [
                                          NSColor.blue.withAlphaComponent(0.2).cgColor,
                                          NSColor.blue.withAlphaComponent(0.4).cgColor
                                        ]
                                        
                                        let label = NSTextField()
                                        gradient.frame = CGRect(origin: CGPoint(x: (i*80)+0, y: 20), size: CGSize(width: 70, height: 70))
                                        label.frame = CGRect(origin: CGPoint.init(x: (i*80)+0, y: 75), size: CGSize(width: 70, height: 10))
                                        
                                        label.stringValue = String(faceNameCapped)
                                        print(faceNameCapped)
                                        presentStudents.append(String(faceNameCapped))
                                        
                                        label.backgroundColor = NSColor.white.withAlphaComponent(0.8)
                                        label.textColor = .black
                                        label.isBezeled = false
                                        label.isEditable = false
                                        label.font = NSFont(name: label.font!.fontName, size: 8.0)
                                        label.alignment = .center
                                        
//                                        documentView.layer?.addSublayer(gradient)
                                        documentView.addSubview(subView)
                                        documentView.addSubview(label)
                                        
                                    }
                                        catch {print("error: \(error)")}
//                                }
                            case .notFound, .failure( _):
                                print("error")
                            default:
                                print("something went very wrong")
                            }
                        })
                    }
                    
                    let scrollViewFrame = CGRect(origin:  CGPoint(x: 111, y:0),
                                       size: CGSize(width: 339, height: 110))
                    let scrollView = NSScrollView(frame: scrollViewFrame)
                    scrollView.backgroundColor = NSColor.white.withAlphaComponent(0.1)
                    scrollView.drawsBackground = false
                    scrollView.documentView = documentView
                    scrollView.contentView.scroll(to: .zero)
                    
                    self.FaceView.wantsLayer = true
                    self.FaceView.addSubview(scrollView)
                    
                  }
                }
                let vnImage = VNImageRequestHandler(cgImage: cgImg, options: [:])
                try? vnImage.perform([detectFaceRequest])
            }
            catch {print("error: \(error)")}
        }
        
        completionHandler(presentStudents)
    }

    func CreateTimeStamp() -> Int32
    {
        return Int32(Date().timeIntervalSince1970)
    }
    
    func detectedFace(request: VNRequest, error: Error?) {
      guard
        let results = request.results as? [VNFaceObservation],
        let result = results.first
        else {
          return
      }
      let box = result.boundingBox
      print(box)
    }

    
    
    @IBAction func quit(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
}
