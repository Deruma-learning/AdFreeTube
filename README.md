# AdFreeTube

개인용 iOS 유튜브 앱 (광고 제거 · 백그라운드 재생 · PIP). 본인 기기에서만 사용하세요.

## 동작 방식
1. **네트워크 차단**: 광고 서버(doubleclick, pagead 등) 요청을 WebKit 규칙으로 차단
2. **광고 데이터 제거**: 영상 정보(JSON)에서 `adPlacements`, `playerAds` 등을 삭제
3. **자동 건너뛰기**: 그래도 광고가 나오면 음소거 + 끝으로 이동 + 건너뛰기 버튼 클릭
4. **백그라운드 재생**: 화면을 꺼도 재생 유지

## 빌드 (Mac 없이)
`main` 브랜치에 push하면 GitHub Actions가 자동으로 `AdFreeTube.ipa`를 만듭니다.
GitHub 저장소 → **Actions** → 최근 실행 → 하단 **Artifacts**에서 `AdFreeTube-ipa` 다운로드 (zip 압축 풀기).

## 아이폰에 설치 (Windows)
1. Apple 웹사이트에서 **iTunes**, **iCloud** 설치 (Microsoft Store 버전 X)
2. **Sideloadly** 설치: https://sideloadly.io
3. 아이폰을 USB로 연결 → "이 컴퓨터를 신뢰" 선택
4. Sideloadly에 `AdFreeTube.ipa`를 끌어다 놓고 Apple ID 입력 → **Start**
5. 아이폰: 설정 → 일반 → VPN 및 기기 관리 → 내 Apple ID 신뢰
6. 아이폰: 설정 → 개인정보 보호 및 보안 → **개발자 모드** 켜기 (재시동)

> 무료 Apple ID는 7일마다 만료됩니다. Sideloadly로 다시 설치하면 됩니다(데이터 유지).

## 광고가 다시 나오면
유튜브가 방식을 바꾼 경우입니다. `Sources/AdBlock.swift`의 규칙/스크립트를 수정해서 push하세요.
