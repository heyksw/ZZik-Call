import UIKit

// 사진에서 인식한 텍스트 박스 시각화
class ElementBoxDrawing: NSObject, CALayerDelegate {
    lazy var layer = CALayer()

    // 이미지에 인식된 frame box 사이즈를 view 사이즈에 맞게 조정하는 함수
    func scaleElementBoxSize(elementFrame: CGRect, imageSize: CGSize, viewFrame: CGRect) -> CGRect {
        let viewSize = viewFrame.size
        
        // 비율 처리
        let rView = viewSize.width / viewSize.height
        let rImage = imageSize.width / imageSize.height
        
        // 비율 계산
        var scale: CGFloat
        if rView > rImage { scale = viewSize.height / imageSize.height }
        else { scale = viewSize.width / imageSize.width }
        
        // scale 을 고려한 element size
        let scaledElementWidth = elementFrame.size.width * scale
        let scaledElementHeight = elementFrame.size.height * scale
        
        // scale 을 고려한 image size
        let scaledImageWidth = imageSize.width * scale
        let scaledImageHeight = imageSize.height * scale
        
        // scale 을 고려한 image 좌표
        let scaledImagePointX = (viewSize.width - scaledImageWidth) / 2
        let scaledImagePointY = (viewSize.height - scaledImageHeight) / 2
        
        // sclae 을 고려한 frame 좌표
        let scaledElementPointX = scaledImagePointX + elementFrame.origin.x * scale
        let scaledElementPointY = scaledImagePointY + elementFrame.origin.y * scale
        
        // 모든 계산을 끝낸 frame box
        let scaledElementFrameBox = CGRect(x: scaledElementPointX,
                                       y: scaledElementPointY,
                                       width: scaledElementWidth,
                                       height: scaledElementHeight)
        
        return scaledElementFrameBox
    }
    
    
    // 추가한 Frame 을 Layer 위에 그려주는 함수
    func drawElementBox(_ frameBoxRect: CGRect, _ layer: CALayer, _ colorType: ColorType) {
        let newFrameBoxSublayer = CALayer()
        newFrameBoxSublayer.frame = frameBoxRect
        newFrameBoxSublayer.borderColor = colorType.lineColor
        newFrameBoxSublayer.backgroundColor = colorType.fillColor
        newFrameBoxSublayer.borderWidth = Constants.lineWidth
        self.layer = newFrameBoxSublayer
        
        layer.addSublayer(newFrameBoxSublayer)
    }
    
    
    func getElementBoxLayer() -> CALayer {
        return self.layer
    }
    
    
    // Layer 에서 그렸던 모든 Frame 을 삭제해주는 함수
    func removeFrames(layer: CALayer?) {
        guard let layer = layer else { return }
        guard let sublayers = layer.sublayers else { return }
        for sublayer in sublayers {
            guard let frameLayer = sublayer as CALayer? else { continue }
            frameLayer.removeFromSuperlayer()
        }
    }
    
    // 박스가 선택됐을 때 색상을 변경하는 함수
    func changeBoxColor_Select(_ frameBoxLayer: CALayer, _ colorType: ColorType) {
        frameBoxLayer.borderColor = colorType.lineColor
        frameBoxLayer.backgroundColor = colorType.fillColor
    }
    
    func changeBoxColor_Unselect(_ frameBoxLayer: CALayer, _ colorType: ColorType) {
        frameBoxLayer.borderColor = colorType.lineColor
        frameBoxLayer.backgroundColor = colorType.fillColor
    }
    
}


enum Constants {
    static let colorTypeArray: [ColorType] = [ColorTypes.green, ColorTypes.yellow, ColorTypes.skyBlue, ColorTypes.purple]
    
    static let onBoardingBackgroundColor = UIColor(red: 0.1333, green: 0.5059, blue: 0.7961, alpha: 1.0)
    
    static let blueBlackBackgroundColor = UIColor(red: 7/255, green: 13/255, blue: 56/255, alpha: 1.0)
    static let deepDarkGrayColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0)
    
    static let labelConfidenceThreshold: Float = 0.75
    static let lineWidth: CGFloat = 2
    
    static let yellowLineColor = UIColor(red: 1, green: 0.9804, blue: 0, alpha: 0.4).cgColor
    static let yellowFillColor = UIColor(red: 1, green: 0.9882, blue: 0.6784, alpha: 0.3).cgColor

    static let greenLineColor = UIColor(red: 0, green: 1, blue: 0.4471, alpha: 0.45).cgColor
    static let greenFillColor = UIColor(red: 0, green: 1, blue: 0.4471, alpha: 0.3).cgColor
    
    static let skyblueLineColor = UIColor(red: 0.3882, green: 0.698, blue: 0.9412, alpha: 0.4).cgColor
    static let skyblueFillColor = UIColor(red: 0.3882, green: 0.698, blue: 0.9412, alpha: 0.3).cgColor
    
    static let blueBlackLineColor = UIColor(red: 34/255, green: 96/255, blue: 167/255, alpha: 0.4).cgColor
    static let blueBlackFillColor = UIColor(red: 34/255, green: 96/255, blue: 167/255, alpha: 0.3).cgColor
    
    static let yellowLineColor2 = UIColor(red: 255/255, green: 251/255, blue: 53/255, alpha: 0.6).cgColor
    static let yellowFillColor2 = UIColor(red: 255/255, green: 251/255, blue: 53/255, alpha: 0.4).cgColor
    
    static let purpleLineColor = UIColor(red: 1, green: 0, blue: 0.9647, alpha: 0.45).cgColor
    static let purpleFillColor = UIColor(red: 1, green: 0, blue: 0.9647, alpha: 0.35).cgColor
}


struct ColorType {
    let lineColor: CGColor
    let fillColor: CGColor
}


enum ColorTypes {
    static let green = ColorType(lineColor: Constants.greenLineColor, fillColor: Constants.greenFillColor)
    static let yellow = ColorType(lineColor: Constants.yellowLineColor, fillColor: Constants.yellowFillColor)
    static let skyBlue = ColorType(lineColor: Constants.skyblueLineColor, fillColor: Constants.skyblueFillColor)
    static let purple = ColorType(lineColor: Constants.purpleLineColor, fillColor: Constants.purpleFillColor)
}


