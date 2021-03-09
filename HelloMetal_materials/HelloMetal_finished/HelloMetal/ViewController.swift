
import Metal
import UIKit





@available(iOS 13.0, *)
class ViewController : UIViewController{
  var metalLayer: CAMetalLayer!
  var device: MTLDevice!
  var vertexBuffer: MTLBuffer!
  var pipelineState: MTLRenderPipelineState!
  var commandQueue: MTLCommandQueue!
  var timer: CADisplayLink!
  
  
override func viewDidLoad() {
  super.viewDidLoad()
    
  device = MTLCreateSystemDefaultDevice()
  
  
  metalLayer = setMetalLayer()
  view.layer.addSublayer(metalLayer)
  
  
  let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
  vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
  
  
  // 만들어 놓은 vertex와 fragment shader를 설정해준다.
  let defaultLibrary = device.makeDefaultLibrary()!
  let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
  let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")
  
  // 렌더 파이프라인에 넣기 전에 configuration할 부분을 명시해준다.
  let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
  pipelineStateDescriptor.vertexFunction = vertexProgram
  pipelineStateDescriptor.fragmentFunction = fragmentProgram
  pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
  
  // pipelineState에 만들어놓은 descriptor을 넣어주어 configuration을 실행한다.
  pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
  
 
  commandQueue = device.makeCommandQueue()
  
  timer = CADisplayLink(target: self, selector: #selector(gameloop))
  timer.add(to: RunLoop.main, forMode: .default)
  
  
}
  
  func setMetalLayer() -> CAMetalLayer{
    metalLayer = CAMetalLayer()
    metalLayer.device = device
    metalLayer.pixelFormat = .bgra8Unorm
    metalLayer.framebufferOnly = true
    metalLayer.frame = view.layer.frame
    return metalLayer
  }

  
  let vertexData: [Float] = [
    0.0, 0.5, 0.0,
    -0.5, -0.5, 0.0,
    0.5, -0.5, 0.0
    
  ]
  
  
  func render(){
    // ToDO
    guard let drawable = metalLayer?.nextDrawable() else { return }
    let renderPassDescriptor = MTLRenderPassDescriptor()
    renderPassDescriptor.colorAttachments[0].texture = drawable.texture
    renderPassDescriptor.colorAttachments[0].loadAction = .clear
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
      red: 0.0,
      green: 0.0,
      blue: 0.0,
      alpha: 1.0)
    
    let commandBuffer = commandQueue.makeCommandBuffer()!
    
    let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
    renderEncoder.setRenderPipelineState(pipelineState)
    renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
    renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
    renderEncoder.endEncoding()
    
    commandBuffer.present(drawable)
    commandBuffer.commit()
    
  }
  
  @objc func gameloop(){
    autoreleasepool {
      self.render()
    }
  }
}
