import Foundation
import AVFoundation
import UIKit

enum FrontOrBack {
  case FRONT, BACK, DEFAULT
}


class VideoCapture {
  let captureSession: AVCaptureSession

  init(_ position: FrontOrBack = .FRONT){
    captureSession = AVCaptureSession()
  }
  
  
  
  func helloGenerator(message: String) -> (String, String) -> String {
    func hello(firstName: String, lastName: String) -> String {
      return lastName + firstName + message
    }
    
    return hello
  }
  
  func helloGenerator2(message:String) -> (String, String) -> String {
    return { (firstName: String, lastName: String) -> String in {
     return lastName + firstName + message
    }()
    
    }
  }
  
  func helloGenerator3(message: String) -> (String, String) -> String {
    return { firstName, lastName in
      return lastName + firstName + message
    }
  }
  
  func helloGenerator4(message: String) -> (String, String) -> String {
    return { $1 + $0 + message}
  }
  
  
  func manipulate(number: Int, using block: (Int) -> Int) -> Int {
    return block(number)
  }
  
  func d(){
    manipulate(number: 10, using: {(number : Int) -> Int in {
      return number * 2
    }()
  })
}
}
