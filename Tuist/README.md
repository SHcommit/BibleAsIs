#  꿀팁

- $(SRCROOT) 
경로 쓸때 이거는 해당 pbxproj가 있는 경로가 됨

환경변수는 두개 지정해둠.
1. TUIST_BUILD_TARGET
2. PROJECT_ROOTDIR

$(SRCROOT)부터 경로 접근이 아니라 아닌 xcworkspace가 있는 루트 프로젝트 디렉터리로부터 경로 찾아야하는겨 경우를 위함!
