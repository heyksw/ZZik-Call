<img width="515" alt="앱 아이콘이랑 이름" src="https://user-images.githubusercontent.com/61315014/155673238-7e328891-866a-4fb6-8aa6-5ff992e56e0b.png">

<img width="1306" alt="앱 스크린샷 정렬된거" src="https://user-images.githubusercontent.com/61315014/155672842-71c0023d-8b97-4d5d-a1e5-75eee1bae163.png">

 


## 개발 정보   
- **앱 이름** : 찍콜 - AI 글자인식 카메라 앱   
- **앱스토어 링크** : https://apps.apple.com/kr/app/찍콜-ai-글자인식-카메라-앱/id1609551668   
- **데모 동영상 링크** : https://www.youtube.com/watch?v=XvUyOoAYM2A   
- **개발 인원** : 1인 개발  
- **개발 기간** : 2022.01.03 ~ 2022.02.25 (앱 배포)   2개월간 600시간 투자 
- **주요 기술** :   
  - AVFoundation - 카메라에 실시간으로 문자 감지 박스 시각화   
  - Google MLkit - 문자 인식   
  - Snapkit - 코드기반 AutoLayout 구성   
  - Google AdMob - 배너 광고  
  - Unit Test Code 작성   
  - Architecture - MVC 
  

## 앱 기능 및 UI   
### 1. 온보딩 화면   
<img src ="https://user-images.githubusercontent.com/61315014/155839877-2d8c320c-1dcf-4560-a8fa-a6fa705ad605.gif" width="20%" />

- OnboardingViewController.swift    

- 앱을 다운로드 받고 첫 실행했을 때만 띄워주는 화면입니다.  
   
### 2. 메인 화면   
<img src ="https://user-images.githubusercontent.com/61315014/155840408-73721286-3f3d-4ccb-b325-45909e335e46.gif" width="20%" />  <img src ="https://user-images.githubusercontent.com/61315014/155842860-33dd2c2b-97cd-4965-9249-ae8e2b6e6bec.gif" width="20%" /> 

- MainViewController.swift   

- 카메라에서 실시간으로 문자 감지 박스를 시각화합니다.   

- 전화모드 : 촬영한 사진안에서 전화번호를 인식했을 경우, 바로 전화 연결을 시도합니다. 그 뒤 인식화면으로 이동합니다.  

- 기본모드 : 촬영 후 바로 전화를 연결하지 않습니다. 인식화면으로 이동합니다.   
   
### 3. 인식 화면
<img src ="https://user-images.githubusercontent.com/61315014/155842359-63eacc7d-f0ed-4ca8-bf54-9bf17f7b68fd.gif" width="20%" />   
   
- RecognizeViewController.swift   
   
- 찍은 사진이나, 앨범에서 가져온 사진에서 문자를 인식합니다.  
    
- 문자 박스를 선택하면 상단의 Text View 에 표시됩니다.   
   
- 선택한 텍스트를 복사 / 공유 할 수 있습니다.   
   
### 4. 그 외 설정, 정보 화면
<img src ="https://user-images.githubusercontent.com/61315014/156487261-1d050061-d489-4eb2-be26-cf79c7164574.PNG" width="20%" /> <img src ="https://user-images.githubusercontent.com/61315014/156487343-d01e8880-3fe6-4f41-a91a-2bf26099414b.PNG" width="20%" /> <img src="https://user-images.githubusercontent.com/61315014/156487926-1cd80c01-2c78-4bc0-8712-2e17f1824c56.PNG" width="20%" /> <img src="https://user-images.githubusercontent.com/61315014/156487999-ec6a58c9-d20e-4d94-993f-52895ac852a6.PNG" width="20%" />

- MainSettingViewController.swift   
   
- SubSettingViewController.swift   
   
- InfoViewController.swift   
   
- HelpInfoViewController.swift
   
- 여러가지 설정을 할 수 있습니다.   
   
- 앱에 관한 정보를 표시합니다.
   
- Google AdMob 배너 광고를 표시합니다.
   
