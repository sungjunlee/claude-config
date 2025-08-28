# Command: /worktree

Git worktree를 활용한 병렬 Claude Code 개발 워크플로우

## 핵심 컨셉
여러 개의 Claude Code 인스턴스를 **동시에 병렬로** 실행하여 개발 속도를 극대화합니다.
각 worktree는 독립된 브랜치와 작업 디렉토리를 가지며, 별도의 Claude Code 세션이 실행됩니다.

## Usage

### 병렬 작업 시작
```bash
/worktree parallel feature-auth feature-payment feature-search
# → 3개의 worktree 생성
# → 3개의 터미널 창/탭 오픈
# → 각각에서 Claude Code 실행
# → 3개 작업이 동시에 진행됨
```

### 단일 worktree 생성
```bash
/worktree new feature-x "Implement user authentication"
# → 새 worktree 생성 + Claude Code 시작
```

### 현재 병렬 작업 상태 확인
```bash
/worktree status
# 실행 중: feature-auth (3분 경과)
# 실행 중: feature-payment (5분 경과)  
# 완료됨: feature-search
```

### 완료된 작업 병합
```bash
/worktree merge feature-auth
# → 메인 브랜치로 병합 후 worktree 정리
```

## 실제 동작 예시

사용자가 3개 기능을 동시 개발하려는 경우:

1. **명령 실행**
   ```
   /worktree parallel auth payment search
   ```

2. **자동으로 일어나는 일**
   - worktree 3개 생성 (../project-auth, ../project-payment, ../project-search)
   - 터미널 3개 오픈 (또는 탭 3개)
   - 각 터미널에서 claude 명령 자동 실행
   - 각 Claude에게 작업 지시 전달

3. **병렬 실행 결과**
   ```
   [Terminal 1] Claude: "auth 기능 구현 중..." 
   [Terminal 2] Claude: "payment 모듈 작성 중..."
   [Terminal 3] Claude: "search API 개발 중..."
   ```
   
   → 3개 작업이 **동시에** 진행되어 시간을 1/3로 단축

## 구현 상세

### 병렬 실행 스크립트
`scripts/worktree-parallel.sh`가 다음을 수행:
1. 여러 worktree를 순차적으로 생성
2. 각 worktree별로 터미널 창/탭 실행
3. 각 터미널에서 Claude Code 자동 시작
4. 작업 컨텍스트 파일 자동 생성

### 포트 충돌 방지
각 worktree는 자동으로 다른 포트를 할당받음:
- worktree-1: 포트 3001, DB 5433
- worktree-2: 포트 3002, DB 5434
- worktree-3: 포트 3003, DB 5435

### 세션 격리
각 Claude Code 인스턴스는:
- 독립된 대화 컨텍스트 유지
- 서로 간섭 없이 작업
- 자체 todo 리스트 관리
- 별도 git 브랜치에서 커밋

## 활용 시나리오

### 시나리오 1: 대규모 리팩토링
```bash
/worktree parallel refactor-auth refactor-db refactor-ui
```
3개 영역을 3명의 Claude가 동시에 리팩토링

### 시나리오 2: 여러 버그 동시 수정
```bash
/worktree parallel fix-login fix-payment fix-search
```
각 버그를 독립적으로 수정 후 개별 PR 생성

### 시나리오 3: A/B 구현 비교
```bash
/worktree parallel approach-a approach-b
```
같은 기능을 2가지 방법으로 동시 구현 후 비교

## 필수 설정

터미널 설정 (settings.json):
```json
{
  "worktree": {
    "terminal": "ghostty",  // 또는 "iterm", "wezterm", "terminal"
    "auto_start_claude": true,
    "parallel_limit": 5
  }
}
```

## 주의사항

- 동시 실행 인스턴스가 많을수록 시스템 리소스 사용량 증가
- 각 Claude Code 세션은 독립적인 API 사용량 계산
- 작업 완료 후 worktree 정리 필요 (`/worktree clean`)