# 1. 잘못 올라간 파일 Git에서 삭제
git rm ESS_ERP_WEB/src/test/java/com/example/demo/README.md

# 2. 올바른 경로의 파일 추가 (ESS_DATA 폴더에 파일을 옮긴 후)
git add ESS_DATA/README.md

# 3. 변경사항 커밋 및 푸시
git commit -m "fix: README 파일 경로를 ESS_DATA 폴더로 올바르게 수정"
git push
