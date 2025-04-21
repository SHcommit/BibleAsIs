## Fastlane

예전 방식:
1. Apple Developer 가서 로그인
2. 인증서 다운로드
3. 프로파일 다운로드
4. Keychain에 설치
5. 파일 복사

(Fastlane 도입 후):
1. fastlane setup_dev → 알아서 인증서 + 프로파일 + Signing 디렉터리 생성
2. tuist generate → Signing 경로 참고해서 Xcode 빌드 완성
