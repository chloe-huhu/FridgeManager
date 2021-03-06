//
//  ViewController.swift
//  FridgeManager
//
//  Created by ChloeHuHu on 2020/12/25.
//

import AVFoundation
import UIKit

protocol qRCodeDelegate: AnyObject {
    
    func sendInite(userUID: String)
}

class QRCodeViewController: UIViewController {

    @IBOutlet weak var topbarView: UIView!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    var invitedFriend: String?

    weak var delegate: qRCodeDelegate?
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.qr]
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        
        contentLabel.lineBreakMode = .byTruncatingTail
        contentLabel.numberOfLines = 0
        
        
            // 取得後置鏡頭來擷取影片
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // 使用前一個裝置物件來取得 AVCaptureDeviceInput 類別的實例
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // 初始化一個AVCaptureMetadataOutput物件並將其設定作為擷取session的輸出裝置
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // 設定委派並使用預設的調度佇列來執行回呼（call back）
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
//            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // 初始化影片預覽層，並將其作為子層加入 viewPreview 視圖的圖層中
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
        // Move the message label and top bar to the front
        view.bringSubviewToFront(contentLabel)
        view.bringSubviewToFront(topbarView)
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension QRCodeViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // 檢查metadataObjects陣列為非空值，他至少需要包含一個物件
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            contentLabel.text = "沒有偵測到 QR code"
            return
        }
        
        // 取得元資料(metadata)物件
        
        if let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
           
            if supportedCodeTypes.contains(metadataObj.type) {
                
                // 若發現的元物件和QRCode的元物件相同，便更新狀態標籤的文字並設定邊界
                let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
                qrCodeFrameView?.frame = barCodeObject!.bounds
                
                if metadataObj.stringValue != nil {
                    
                    contentLabel.text = " 搜索到朋友\n請朋友至冰箱邀請列表確認 "
                    
                    guard let friendUID = metadataObj.stringValue else { return }
                    
                    delegate?.sendInite(userUID: friendUID)
                    
                    print("=============", friendUID)
                }
            }
      
        } else { return }
    }
    

}
