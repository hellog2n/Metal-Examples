import UIKit
import AVFoundation
import MetalKit

class MetalCameraViewController: UIViewController, VideoCaptuing, CALayerDelegate {
  let mtkView = MTKView()
  
  func settingPreviewLayer() {
    previewLayer.delegate = self
  }
  
  
  var previewLayer: AVCaptureVideoPreviewLayer!
  override func viewDidLoad() {
    
    let videoCap = VideoCapture(.FRONT)

     previewLayer = AVCaptureVideoPreviewLayer()
    print("GetPreviewLayer")
    previewLayer = settingPreviewLayer()
    setupPreviewLayer()
    
   // videoCap.startRunningSession()
  }
  func setupPreviewLayer(){
          previewLayer.frame = self.view.layer.frame
    self.view.layer.insertSublayer(previewLayer, at: 0)
      }
}
