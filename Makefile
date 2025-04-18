.PHONY: clean
clean:
	@echo "🧹 Cleaning project files..."
	@find . -name "*.xcworkspace" -type d -exec rm -rf {} +
	@find . -name "*.xcodeproj" -type d -exec rm -rf {} +
	@find . -name "Derived" -type d -exec rm -rf {} +
	@rm -rf ~/Library/Developer/Xcode/DerivedData
	@rm -rf Tuist/.build
	@rm -rf Tuist/.package.resolved
	@echo "✅ Project cleanup complete!"
	@echo "🧼 Tuist clean..."
	@tuist clean
	@echo "✨ All clean done!"

.PHONY: install
install:
	@tuist install
	@echo "의존성 설치 완료!"

.PHONY: setup_codesign_dev
setup_codesign_dev:
	@echo "Fastlane: setting up development codesigning..."
	@cd fastlane && bundle exec fastlane setup_dev

.PHONY: generateDEV
generateDEV:
	@echo "만들어볼까나. tuist install한거 맞지?. Now Tuist generating ..."
	@TUIST_BUILD_TARGET=DEV tuist generate
	@echo "✅ tuist 생성 완료 (DEV)!"

.PHONY: generatePRD
generatePRD:
	@echo "만들어볼까나. tuist install 한거 맞지? Now Tuist generating ..."
	@TUIST_BUILD_TARGET=PRD tuist generate
	@echo "✅ tuist 생성 완료 (PRD)!"
