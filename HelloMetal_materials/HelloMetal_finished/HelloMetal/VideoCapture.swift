import Foundation
import AVFoundation
import UIKit

protocol VideoCaptuing {
  func settingPreviewLayer()
}

// MARK:- 전면 후면을 관리합니다.
enum FrontOrBack {
  case FRONT, BACK, DEFAULT
}

// MARK:- 카메라 동의 상태를 관리합니다.
private enum SessionSetupResult {
  case success, notAuthorized, configurationFailed
}

// MARK:- Video Caputring을 위한 클래스 입니다.
class VideoCapture {
  
  // session object들이 소통하는 공간
  private let sessionQueue = DispatchQueue(label: "session Queue")
  private var setupResult: SessionSetupResult = .success
  var captureSession: AVCaptureSession
  var previewLayer: AVCaptureVideoPreviewLayer? = nil
  var videoOutput : AVCaptureVideoDataOutput!
  var cvPixelBuffer: CVPixelBuffer?
  
  // 카메라 변수를 초기화 합니다.
  init(_ position: FrontOrBack = .FRONT){
    
    captureSession = AVCaptureSession()
    // 카메라 사용 가능 상태를 체크한다.
    self.checkPermission()
    
    // 세션을 시작한다.
    
  }
    
  func settingPreviewLayer() -> AVCaptureVideoPreviewLayer{
    let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
  return previewLayer
  }
  
  
  // MARK:- Check Camera Permission
  func checkPermission(){
    
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      print("Autorized")
      // 카메라 접근이 가능합니다.
      break
      
    case .notDetermined:
      print("NotDetermined")
      sessionQueue.suspend()
      // 카메라 접근 요청을 하였으나, 사용자가 아직 승인을 하지 않았거나 접근을 거절했습니다.
      AVCaptureDevice.requestAccess(for: .video) { granted in
                  if !granted {
                    // 접근 요청을 하였으나 사용자가 승인을 하지 않았습니다.
                    self.setupResult = .notAuthorized
                     // self.setupCaptureSession()
                  }
                    self.sessionQueue.resume()
                  
              }
      break
      
    case .restricted:
      // 사용자가 제한 때문에 카메라 접근을 할 수 없습니다.
      print("Restricted")
      break
      
    case .denied:
      print("Denied")
      // 사용자가 카메라 접근을 이전에 거부 했습니다.
      self.setupResult = .notAuthorized
    }
    
    
    sessionQueue.async {
      self.setupAndStartCaptureSession()
      
      }
      
    }
  
  
  
  // MARK:- Setup CaptureSession - After Checking Permission
  func SettingResult() {
    
    sessionQueue.async {
      
    switch self.setupResult {
    case .notAuthorized:
      DispatchQueue.main.async {
        // ToDo Something
      }
    case .success:
      break
      
    case .configurationFailed:
      DispatchQueue.main.async {
        // ToDo Something
      }
    }
      
    }
  }
  
  
  
  func setupVideoInput(){
    
    // Video Input을 추가한다.
    do {
      var defaultVideoDevice: AVCaptureDevice?
      
      
      // 어떤 카메라를 선택할지 골라 VideoDevice를 세팅한다.
      if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
        // Dual Camera (BACK)
        defaultVideoDevice = dualCameraDevice
      }
      else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
        // Wide Angle Camera (BACK)
        defaultVideoDevice = backCameraDevice
      }
      else if let frontCameraDevice = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front) {
        // True Depth Camera (FRONT)
        defaultVideoDevice = frontCameraDevice
      }
      
      let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice!)
      
      // videoDeviceInput을 세션에 추가할 수 있는지 확인 합니다.
      if captureSession.canAddInput(videoDeviceInput) {
        captureSession.addInput(videoDeviceInput)
        
      }
      else {
        // Video Input을 세션에 추가할 수 없다면 예외 처리를 합니다.
        print("Could not add Video Device input to the Session")
              setupResult = .configurationFailed
              captureSession.commitConfiguration()
              return
      }
    }
    catch {
      // Video Input을 만들 수 없는 경우 에러 처리를 합니다.
      print("Could not create video device input: \(error)")
            setupResult = .configurationFailed
            captureSession.commitConfiguration()
            return
    }
    
    
  }
  
  
  func setupAudioInput() {
    // audio Input을 추가합니다.
    do {
      let audioDevice = AVCaptureDevice.default(for: .audio)
      let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
      
      
      if captureSession.canAddInput(audioDeviceInput) {
        captureSession.addInput(audioDeviceInput)
      }
      else {
        // Audio Input을 세션에 추가할 수 없다면 예외 처리를 합니다.
        print("Could not add Audio Device Input to the Session")
            }
      }
    catch {
      print("Could not creeatee audio device input: \(error)")
      setupResult = .configurationFailed
      captureSession.commitConfiguration()
      return
    }
  }
  
  
  
  
  // MARK:- Stopping Session
  func stopRunningSession(){
    sessionQueue.async {
      // 세션을 중지합니다.
      if self.setupResult == .success {
        self.captureSession.stopRunning()
      }
    }
  }
  func startRunningSession(){
    sessionQueue.async {
      if !self.captureSession.isRunning {
        self.captureSession.startRunning()
    }
    }
  }
  
  
  // MARK:- Setup CaptureSession - IF Success
  
  func setupAndStartCaptureSession(){
    
    // 카메라를 허용하지 않았다면 Return 처리
    if setupResult != .success {
      return
    }
    
    DispatchQueue.global(qos: .userInitiated).async{
      self.captureSession = AVCaptureSession()
      self.captureSession.beginConfiguration()
      
      // do some configuration
      // preset을 이용하여 quality level of the output을 조절합니다.
      if self.captureSession.canSetSessionPreset(.inputPriority) {
        self.captureSession.sessionPreset = .inputPriority
      }
      self.captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
      
      self.setupAudioInput()
      self.setupVideoInput()
      
      //setup output
                  self.setupOutput()
      self.captureSession.commitConfiguration()
      
      print("CommitConfigurate")
      
         
      // start running it
      self.captureSession.startRunning()
      print("Session Start")
      }
    
    
    }
  
  
  func setupOutput(){
          videoOutput = AVCaptureVideoDataOutput()
          let videoQueue = DispatchQueue(label: "videoQueue", qos: .userInteractive)
          videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
          
          if captureSession.canAddOutput(videoOutput) {
              captureSession.addOutput(videoOutput)
          } else {
              fatalError("could not add video output")
          }
      }
  
  
  
  }

extension MetalCameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }
}
  


