// 문자인식을 담당하는 뷰 컨트롤러
import UIKit
import Foundation
import PhotosUI

import MLKitTextRecognitionKorean
import MLKitVision
import SnapKit

import NetworkExtension
import SystemConfiguration.CaptiveNetwork
import CoreLocation
import SystemConfiguration

struct ExtractedResult {
    var ID: String
    var PW: String
}


// MARK: - RecognizeViewController
class RecognizeViewController: UIViewController {
    var areButtonsFloated = false
    var areButtonsMoving = false
    
    let elementBoxDrawing = ElementBoxDrawing()
    let textRecognize = TextRecognizing()
    var recognizedResultText: Text? = nil
    var elementBoxInfoArray: [ElementBoxInfo] = []
    let textLinkedList = LinkedList()
    
    let mainDispatchQueue = DispatchQueue.main
    let textRecognizeDispatchQueue = DispatchQueue.global()
    
    let thereIsNoText = "사진에서 아무 글자도 인식하지 못했어요."
    let clickTheBoxes = "텍스트 박스를 클릭해보세요!"
    
    let shareImage = UIImage(named: "shareImage")
    let copyImage = UIImage(named: "copyImage")
    let callImage = UIImage(named: "callImage")
    let crossImage = UIImage(named: "crossImage")
    let selectAllImage = UIImage(named: "selectAllImage")
    let unselectAllImage = UIImage(named: "unselectAllImage")
    let galleryImage = UIImage(named: "galleryImage")
    
    let blueBlackBackgroundColor = UIColor(red: 7/255, green: 13/255, blue: 56/255, alpha: 1.0)
    var isSharingActivityPresented = false
    
    lazy var phPickerConfiguration = PHPickerConfiguration()
    lazy var picker = PHPickerViewController(configuration: phPickerConfiguration)
    
    lazy var safetyAreaBottomInsets = view.safeAreaInsets.bottom
    
    lazy var safetyArea: UIView = {
        let view = UIView()
        view.backgroundColor = blueBlackBackgroundColor
        return view
    }()
    
    lazy var topSuperView: UIView = {
        let view = UIView()
        view.backgroundColor = blueBlackBackgroundColor
        return view
    }()
    
    lazy var topTextView: UITextView = {
        let view = UITextView()
        view.autocorrectionType = .no
        view.layer.borderWidth = 2.5
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 5
        view.font = .systemFont(ofSize: 15)
        view.delegate = self
        view.backgroundColor = .black
        return view
    }()
    
    var receivedImage: UIImage?
    
    let imageSuperScrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .black
        return view
    }()
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .black
        return view
    }()
    
    // imageView 를 어둡게 만들어줄 dimView
    let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.7
        view.isHidden = true
        return view
    }()

    let floatingView: UIStackView  = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 1, alpha: 0)
        view.alignment = .fill
        view.distribution = .equalSpacing
        return view
    }()
    
    
    let floatingLeftView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0)
        return view
    }()
    
    let floatingMiddleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0)
        return view
    }()
    
    let floatingRightView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0)
        return view
    }()
    
    lazy var selectAllButton: UIButton = {
        let button = UIButton()
        button.setImage(selectAllImage, for: .normal)
        button.alpha = 0
        return button
    }()
    
    // 전체 선택, 전체 해제 변경을 위한 불값
    var selectAll: Bool = true
    
    lazy var copyButton: UIButton = {
        let button = UIButton()
        button.setImage(copyImage, for: .normal)
        button.alpha = 0
        return button
    }()
    
    lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(shareImage, for: .normal)
        button.backgroundColor = UIColor(white: 1, alpha: 0)
        button.alpha = 0
        return button
    }()
    
    // 인식된 글자 프레임박스들이 이 레이어 위에 그려짐
    var imageViewLayer = CALayer()
    
    lazy var bottomSuperView: UIView = {
        let view = UIView()
        view.backgroundColor = blueBlackBackgroundColor
        return view
    }()
    
    
    // 하단 버튼들이 들어갈 footer 스택 뷰
    lazy var bottomStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = blueBlackBackgroundColor
        view.alignment = .fill
        view.distribution = .equalSpacing
        return view
    }()

    lazy var bottomLeftView: UIView = {
        let view = UIView()
        view.backgroundColor = blueBlackBackgroundColor
        return view
    }()
    
    lazy var bottomMiddleView: UIView = {
        let view = UIView()
        view.backgroundColor = blueBlackBackgroundColor
        return view
    }()
    
    lazy var bottomRightView: UIView = {
        let view = UIView()
        view.backgroundColor = blueBlackBackgroundColor
        return view
    }()
    
    lazy var galleryButton: UIButton = {
        let button = UIButton()
        button.setImage(galleryImage, for: .normal)
        return button
    }()
    
    lazy var crossButton: UIButton = {
        let button = UIButton()
        //button.setTitle("십자 버튼", for: .normal)
        button.setImage(crossImage, for: .normal)
        button.backgroundColor = blueBlackBackgroundColor
        button.layer.cornerRadius = 10
        return button
    }()
    
    lazy var callButton: UIButton = {
        let button = UIButton()
        button.setImage(callImage, for: .normal)
        button.backgroundColor = blueBlackBackgroundColor
        button.layer.cornerRadius = 10
        return button
    }()
    
    
    // 상태바 색상 변경
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        
        setPHPicker()
        
        // 뷰 터치 이벤트
        let tapGetPosition = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        self.view.addGestureRecognizer(tapGetPosition)
        
        // 버튼 터치 이벤트
        galleryButton.addTarget(self, action: #selector(tapGalleryButton), for: .touchDown)
        crossButton.addTarget(self, action: #selector(tapCrossButton), for: .touchDown)
        callButton.addTarget(self, action: #selector(tapCallButton), for: .touchDown)
        
        selectAllButton.addTarget(self, action: #selector(tapSelectAllButton(_:)), for: .touchDown)
        copyButton.addTarget(self, action: #selector(tapCopyButton(_:)), for: .touchDown)
        shareButton.addTarget(self, action: #selector(tapShareButton(_:)), for: .touchDown)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrideUserInterfaceStyle = .dark
        
        setNavigationBar()
        
        setUI()
        
        // 키보드 등장 이슈 처리
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: self.view.window)
        
        // 넘겨 받은 이미지 문자 인식, 박스 그리기
        recognizeReceivedImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.elementBoxDrawing.removeFrames(layer: imageViewLayer)
        
        // 메모리 해제
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        recognizedResultText = nil
        elementBoxInfoArray = []
        textLinkedList.removeAllNodes()
        
        floatingButtonsDown()
        hideDimView()
        rotateBackCrossButton()
    }
    
}



// MARK: - UI setting
extension RecognizeViewController {
    func setNavigationBar() {
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = blueBlackBackgroundColor
        self.navigationController?.navigationBar.backgroundColor = blueBlackBackgroundColor
        self.navigationController?.navigationBar.isTranslucent = false
        
        let settingButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(tapSettingButton))
        navigationItem.rightBarButtonItem = settingButton
    }
    
    
    func setUI() {
        safetyArea.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safetyArea)
        
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            safetyArea.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
            safetyArea.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
            safetyArea.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
            safetyArea.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
            
        } else {
            safetyArea.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor).isActive = true
            safetyArea.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor).isActive = true
            safetyArea.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            safetyArea.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }
        
        // safetyArea
        safetyArea.addSubview(topSuperView)
        safetyArea.addSubview(imageSuperScrollView)
        safetyArea.addSubview(bottomSuperView)
        
        // topSuperView
        topSuperView.addSubview(topTextView)
        
        // imageSuperScrollView
        imageSuperScrollView.addSubview(imageView)
        imageSuperScrollView.addSubview(floatingView)
        
        imageSuperScrollView.delegate = self
        imageSuperScrollView.zoomScale = 1.0
        imageSuperScrollView.minimumZoomScale = 1.0
        imageSuperScrollView.maximumZoomScale = 3.0
        
        imageView.layer.addSublayer(imageViewLayer)
        imageView.contentMode = .scaleAspectFit
        imageView.image = receivedImage
        imageView.addSubview(dimView)

        floatingView.addArrangedSubview(floatingLeftView)
        floatingView.addArrangedSubview(floatingMiddleView)
        floatingView.addArrangedSubview(floatingRightView)
        
        floatingLeftView.addSubview(selectAllButton)
        floatingMiddleView.addSubview(copyButton)
        floatingRightView.addSubview(shareButton)
        
        selectAllButton.setImage(selectAllImage, for: .normal)
        selectAll = true

        // bottomSuperView
        bottomSuperView.addSubview(bottomStackView)
        
        bottomStackView.addArrangedSubview(bottomLeftView)
        bottomStackView.addArrangedSubview(bottomMiddleView)
        bottomStackView.addArrangedSubview(bottomRightView)
        
        bottomLeftView.addSubview(galleryButton)
        bottomMiddleView.addSubview(crossButton)
        bottomRightView.addSubview(callButton)
        
        view.setNeedsUpdateConstraints()
    }
    
    
    override func updateViewConstraints() {
        topSuperView.snp.makeConstraints { (make) in
            make.top.equalTo(safetyArea.snp.top)
            make.height.equalTo(80)
            make.left.right.equalTo(safetyArea)
        }
        
        topTextView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        imageSuperScrollView.snp.makeConstraints { (make) in
            make.top.equalTo(topSuperView.snp.bottom)
            make.left.right.equalTo(safetyArea)
            make.bottom.equalTo(self.bottomStackView.snp.top)
        }
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        dimView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        floatingView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(imageSuperScrollView.frameLayoutGuide)
            make.height.equalTo(110)
        }
        
        floatingLeftView.snp.makeConstraints { make in
            make.width.equalTo(self.view).multipliedBy(0.30)
        }
        
        floatingMiddleView.snp.makeConstraints { make in
            make.width.equalTo(self.view).multipliedBy(0.30)
        }
        
        floatingRightView.snp.makeConstraints { make in
            make.width.equalTo(self.view).multipliedBy(0.30)
        }
        
        selectAllButton.snp.makeConstraints{ make in
            make.center.equalToSuperview()
        }
        
        copyButton.snp.makeConstraints{ make in
            make.center.equalToSuperview()
        }
        
        shareButton.snp.makeConstraints{ make in
            make.center.equalToSuperview()
        }
        
        bottomSuperView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(safetyArea)
            make.height.equalTo(100)
        }
        
        bottomStackView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        bottomLeftView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view).multipliedBy(0.30)
        }
        
        bottomMiddleView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view).multipliedBy(0.30)
        }
        
        bottomRightView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view).multipliedBy(0.30)
        }
        
        galleryButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        crossButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        callButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        super.updateViewConstraints()
    }
    
    
    func hideNavigationBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }

    
    func showNavigationBar() {
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
}



// MARK: - UIScrollViewDelegate
extension RecognizeViewController: UIScrollViewDelegate {

    // imageSuperScrollView zoom
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}



// MARK: - about recognize text
extension RecognizeViewController {
    // 넘겨받은 이미지 문자 인식하고, element frame box 그리는 함수
    func recognizeReceivedImage() {
        textRecognizeDispatchQueue.async {
            guard let receivedImage = self.receivedImage else {
                self.showUnknownErrorAlert()
                return
            }
            let vImage = VisionImage(image: receivedImage)
            vImage.orientation = receivedImage.imageOrientation
            self.textRecognize.recognizeText(uiImage: receivedImage) { [weak self] result in
                guard let result = result else { return }
                self?.recognizedResultText = result
                self?.mainDispatchQueue.async {
                    self?.drawAllElement(result: result)
                    
                    if result.text == "" {
                        self?.topTextView.text = self?.thereIsNoText
                    }
                    else {
                        self?.topTextView.text = self?.clickTheBoxes
                    }
                    self?.topTextView.textColor = .lightGray
                }
            }
        }
    }
    
    
    // element box 들을 그리면서 elementBoxesInfo 에 저장.
    func drawAllElement(result: Text?) {
        var cnt = 0
        guard let result = result else {
            showUnknownErrorAlert()
            return
        }
        guard let image = self.receivedImage else {
            showUnknownErrorAlert()
            return
        }
        for block in result.blocks {
            for line in block.lines {
                for element in line.elements {
                    let scaledElementBoxSize = elementBoxDrawing.scaleElementBoxSize(elementFrame: element.frame, imageSize: image.size, viewFrame: imageView.frame)
                    elementBoxDrawing.drawElementBox(scaledElementBoxSize, imageViewLayer, Constants.colorTypeArray[UserDefaults.standard.integer(forKey: "unselectBox_colorType_index")])
                    let elementBoxLayer = elementBoxDrawing.getElementBoxLayer()
                    let elementBoxInfo = ElementBoxInfo(idx: cnt, layer: elementBoxLayer, text: element.text)
                    elementBoxInfoArray.append(elementBoxInfo)
                    cnt += 1
                }
            }
        }
    }
}



// MARK: - about button tap @IBAction
extension RecognizeViewController {
    // 키보드가 올라올 때 footer view 도 같이 올라가도록
    @objc
    func keyboardWillShow(_ sender: Notification) {
        // share 에서 message 를 클릭했을 때 발견한 버그를 방지하는 코드
        if bottomSuperView.frame.origin.y != safetyArea.frame.height - 100 {
            bottomSuperView.frame.origin.y = safetyArea.frame.height - 100
            floatingView.frame.origin.y = imageSuperScrollView.frame.height - 110
        }
        
        if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keybaordRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keybaordRectangle.height
            
            if bottomSuperView.frame.origin.y == safetyArea.frame.height - 100 {
                print("view.safeAreaInsets.bottom", view.safeAreaInsets.bottom)
                bottomSuperView.frame.origin.y -= (keyboardHeight - safetyAreaBottomInsets)
                floatingView.frame.origin.y -= (keyboardHeight - safetyAreaBottomInsets)
            }
            
          }
        else { showUnknownErrorAlert() }
    }
    
    // 키보드가 내려갈 때 footer view 도 다시 같이 내려감
    @objc
    func keyboardWillHide(_ sender: Notification) {

        if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keybaordRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keybaordRectangle.height
            
            if bottomSuperView.frame.origin.y == safetyArea.frame.height - 100 - (keyboardHeight - view.safeAreaInsets.bottom) {
                bottomSuperView.frame.origin.y += (keyboardHeight - safetyAreaBottomInsets)
                floatingView.frame.origin.y += (keyboardHeight - safetyAreaBottomInsets)
            }
            
          }
        else { showUnknownErrorAlert() }
    }
    
    
    // 탭 했을때 호출되는 함수
    @objc
    func handleTap(gestureRecognizer: UITapGestureRecognizer){
        // bottomSuperView 를 클릭한건 무시
        let location = gestureRecognizer.location(in: gestureRecognizer.view)
        if location.y >= (self.safetyArea.frame.height - 100) {
            return
        }
        
        // 뷰를 탭하면 키보드가 내려감
        self.topTextView.resignFirstResponder()
        
        if gestureRecognizer.state == UIGestureRecognizer.State.recognized {
            // 플로딩 버튼이 띄워져 있다면 내림
            if areButtonsFloated && !areButtonsMoving {
                floatingButtonsDown()
                hideDimView()
                rotateBackCrossButton()
            }
            
            // 플로팅 버튼이 띄워져 있지 않다면 박스를 클릭 가능하게 함
            if !areButtonsFloated {
                // super view 에서의 좌표와 image view 에서의 좌표는 다르다. convert 해줘야 함.
                let imageViewLocation = self.view.convert(location, to: imageView)
                
                // 어느 박스가 클릭되었는지
                guard let tappedElementBox = getWhichElementBoxTapped(imageViewLocation) else { return }
                if !tappedElementBox.tapped {
                    selectElementBox(tappedElementBox)
                }
                else {
                    unselectElementBox(tappedElementBox)
                }
            }
        }
    }
    
    
    // 탭한 위치에 어떤 element box 가 있었는지
    func getWhichElementBoxTapped(_ tappedLocation: CGPoint) -> ElementBoxInfo? {
        var resultBox: ElementBoxInfo?
        for box in elementBoxInfoArray {
            if (box.layer.frame.minX <= tappedLocation.x && tappedLocation.x <= box.layer.frame.minX + box.layer.frame.width)
                &&
                (box.layer.frame.minY <= tappedLocation.y && tappedLocation.y <= box.layer.frame.minY + box.layer.frame.height) {
                resultBox = box
                break
            }
        }
        return resultBox
    }
    
    
    // 박스를 선택하는 함수
    func selectElementBox(_ tappedBox: ElementBoxInfo) {
        elementBoxDrawing.changeBoxColor_Select(tappedBox.layer, Constants.colorTypeArray[UserDefaults.standard.integer(forKey: "selectBox_colorType_index")])
        tappedBox.tapped = true
        textLinkedList.append(elementBoxInfo: tappedBox)
        self.topTextView.text = textLinkedList.getTextWithLinkedList()
        self.topTextView.textColor = .white
    }
    
    
    // 박스를 선택 해제하는 함수
    func unselectElementBox(_ tappedBox: ElementBoxInfo) {
        elementBoxDrawing.changeBoxColor_Unselect(tappedBox.layer, Constants.colorTypeArray[UserDefaults.standard.integer(forKey: "unselectBox_colorType_index")])
        tappedBox.tapped = false
        textLinkedList.remove(elementBoxInfo: tappedBox)
        self.topTextView.text = textLinkedList.getTextWithLinkedList()
    }
    
    
    func rotateCrossButton() {
        UIView.animate(withDuration: 0.2) {
            let rotate = CGAffineTransform(rotationAngle: .pi/4 * (-1))
            self.crossButton.transform = rotate
        }
    }
    
    func rotateBackCrossButton() {
        UIView.animate(withDuration: 0.2) {
            let rotate = CGAffineTransform(rotationAngle: 0)
            self.crossButton.transform = rotate
        }
    }
    
    
    // 십자 플로팅 버튼
    @IBAction func tapCrossButton(_ sender: UIButton) {
        // 버튼들이 플로팅 되지 않은 상태이고, 움직이고 있지 않다면
        if !areButtonsFloated && !areButtonsMoving {
            floatingButtonsUp()
            showDimView()
            rotateCrossButton()
        }
        
        // 버튼들이 플로팅 되어있고, 움직이고 있지 않다면
        else if areButtonsFloated && !areButtonsMoving {
            floatingButtonsDown()
            hideDimView()
            rotateBackCrossButton()
        }
    }
    
    
    // 플로팅 버튼 올리기
    func floatingButtonsUp() {
        let gap = self.floatingLeftView.frame.width
        areButtonsMoving = true
        
        // copyButton
        self.selectAllButton.alpha = 0
        self.selectAllButton.transform = CGAffineTransform(translationX: +gap, y: 0)
        UIView.animate(withDuration: 0.1) {
            self.selectAllButton.transform = CGAffineTransform(translationX: +(gap/2), y: 0)
        }
        UIView.animate(withDuration: 0.3) {
            self.selectAllButton.alpha = 1
            self.selectAllButton.transform = CGAffineTransform(translationX: 0, y: 0)
        }
        
        // wifiButton
        self.copyButton.alpha = 0
        self.copyButton.transform = CGAffineTransform(translationX: 0, y: +100)
        UIView.animate(withDuration: 0.3) {
            self.copyButton.alpha = 1
            self.copyButton.transform = CGAffineTransform(translationX: 0, y: 0)
        }
        
        // shareButton
        self.shareButton.alpha = 0
        self.shareButton.transform = CGAffineTransform(translationX: -gap, y: 0)
        UIView.animate(withDuration: 0.1) {
            self.shareButton.transform = CGAffineTransform(translationX: -(gap/2), y: 0)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.shareButton.alpha = 1
            self.shareButton.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: { finished in
            self.areButtonsFloated = true
            self.areButtonsMoving = false
        })
    }
    
    
    // 플로팅 버튼 내리기
    func floatingButtonsDown() {
        let gap = self.floatingLeftView.frame.width
        areButtonsMoving = true
        
        // searchButton
        UIView.animate(withDuration: 0.1) {
            self.selectAllButton.transform = CGAffineTransform(translationX: +(gap/2), y: 0)
        }
        UIView.animate(withDuration: 0.3) {
            self.selectAllButton.alpha = 0
            self.selectAllButton.transform = CGAffineTransform(translationX: +(gap), y: 0)
        }
        
        // copyButton
        UIView.animate(withDuration: 0.3) {
            self.copyButton.alpha = 0
            self.copyButton.transform = CGAffineTransform(translationX: 0, y: +100)
        }
        
        // shareButton
        UIView.animate(withDuration: 0.1) {
            self.shareButton.transform = CGAffineTransform(translationX: -(gap/2), y: 0)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.shareButton.alpha = 0
            self.shareButton.transform = CGAffineTransform(translationX: -(gap), y: 0)
        }, completion: { finished in
            self.areButtonsFloated = false
            self.areButtonsMoving = false
        })
    }
    
    
    // dimView 를 띄워서 이미지뷰를 어둡게 만듬
    func showDimView() {
        if self.dimView.isHidden {
            self.dimView.isHidden = false
        }
    }
    
    
    // dimView 를 숨겨서 이미지뷰를 다시 밝게 만듬
    func hideDimView() {
        self.dimView.isHidden = true
    }

    
    // 전화 버튼
    @IBAction func tapCallButton(_ sender: UIButton) {
        guard let resultText = self.recognizedResultText else {
            showThereIsNoPhoneNumberAlert()
            return
        }
        if let number = textRecognize.getPhoneNumber(resultText) {
            if let url = NSURL(string: "tel:\(number)"), UIApplication.shared.canOpenURL(url as URL) {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
            else { showUnknownErrorAlert() }
        }
        else { showThereIsNoPhoneNumberAlert() }
    }
    
    
    // 플로팅 버튼 눌렀을 때 위로 통 튀게 하는 메서드
    func bounceButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.2) {
            button.transform = CGAffineTransform(translationX: 0, y: +15)
        }
        UIView.animate(withDuration: 0.1) {
            button.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
    // 전체 선택 버튼
    @IBAction func tapSelectAllButton(_ sender: UIButton) {
        bounceButton(sender)
        
        if elementBoxInfoArray.count == 0 {
            showNoSelectToast()
        }
        else {
            if selectAll {
                showSelectAllToast()
                textLinkedList.removeAllNodes()
                for elementBoxInfo in elementBoxInfoArray {
                    selectElementBox(elementBoxInfo)
                }
                selectAllButton.setImage(unselectAllImage, for: .normal)
                selectAll = false
            }
            else {
                showUnSelectAllToast()
                for elementBoxInfo in elementBoxInfoArray {
                    if elementBoxInfo.tapped {
                        unselectElementBox(elementBoxInfo)
                    }
                }
                selectAllButton.setImage(selectAllImage, for: .normal)
                selectAll = true
            }
        }
    }
    
    
    // 복사 버튼
    @IBAction func tapCopyButton(_ sender: UIButton) {
        bounceButton(sender)
        
        if (topTextView.textColor == UIColor.lightGray) || (topTextView.text == "") {
            showNoCopyToast()
        }
        else {
            UIPasteboard.general.string = topTextView.text
            showCopyToast(copiedText: topTextView.text)
        }
    }
    
    
    // 공유 버튼
    @IBAction func tapShareButton(_ sender: UIButton) {
        bounceButton(sender)
        
        if (topTextView.textColor == UIColor.lightGray) || (topTextView.text == "") {
            showNoShareToast()
        }
        else {
            var shareObject = [Any]()
            shareObject.append(topTextView.text ?? "")
            
            let activityViewController = UIActivityViewController(activityItems: shareObject, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
 
    
    // 우측 상단 세팅 버튼
    @objc func tapSettingButton(_ sender: UIButton) {
        //
        let subSettingViewController = SubSettingViewController()
        self.navigationController?.pushViewController(subSettingViewController, animated: true)
    }
    
    
    // 갤러리 버튼
    @IBAction func tapGalleryButton(_ sender: UIButton) {
        self.picker.modalPresentationStyle = .fullScreen
        present(picker, animated: true, completion: nil)
        
    }
}



// MARK: - about topTextView placeholder
extension RecognizeViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            guard let resultText = self.recognizedResultText else {
                showUnknownErrorAlert()
                return
            }
            if resultText.text == "" {
                textView.text = thereIsNoText
            }
            else {
                textView.text = clickTheBoxes
            }
            textView.textColor = UIColor.lightGray
        }
    }
}



// MARK: - PHPickerViewControllerDelegate
extension RecognizeViewController: PHPickerViewControllerDelegate {
    func setPHPicker() {
        self.phPickerConfiguration.selectionLimit = 1
        self.phPickerConfiguration.filter = .images
        self.picker.delegate = self
    }
    
    // 갤러리에서 이미지 선택이 끝났을 때
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let itemProvider = results.first?.itemProvider
        // 이미지를 선택했을 때
        if let itemProvider = itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                self.mainDispatchQueue.async {
                    self.receivedImage = image as? UIImage
                    picker.dismiss(animated: true, completion: nil)
                }
            }
            
        }
        // 이미지를 선택하지 않았거나, 오류가 났을 때
        else {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

