import UIKit

extension MetalCameraViewController {
  
  func setupView(){
    view.backgroundColor = .black
    mtkView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(mtkView)
    
    let constraints = [
    mtkView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    mtkView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    mtkView.topAnchor.constraint(equalTo: view.topAnchor),
    mtkView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
    ]
    
    NSLayoutConstraint.activate(constraints)

  }
}
