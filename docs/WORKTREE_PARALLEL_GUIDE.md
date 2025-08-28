# Git Worktree 병렬 Claude Code 실행 가이드

## 🚀 핵심 개념: 병렬 AI 개발

**한 줄 요약**: 여러 개의 Claude Code를 동시에 실행해서 개발 속도를 N배로 높이는 방법

### 왜 병렬 실행인가?

기존 방식 (순차 실행):
```
Auth 구현 (30분) → Payment 구현 (30분) → Search 구현 (30분) = 총 90분
```

병렬 실행:
```
Auth 구현 (30분) ─┐
Payment 구현 (30분) ├─ 동시 실행 = 총 30분
Search 구현 (30분) ─┘
```

**3배 빠른 개발 속도!** 🎯

## 📦 설치 방법

1. **Claude Config 설치** (이미 설치된 경우 스킵)
```bash
cd claude-config
./install.sh
```

2. **Worktree 기능 활성화**
```bash
# settings.json에 추가
{
  "worktree": {
    "enabled": true,
    "terminal": "ghostty",  # 또는 iterm, wezterm, terminal
    "parallel_limit": 5
  }
}
```

## 🎮 사용 예시

### 예시 1: 3개 기능 동시 개발

**상황**: 로그인, 결제, 검색 기능을 구현해야 함

**명령**:
```bash
./scripts/worktree-parallel.sh parallel login payment search
```

**결과**:
- 3개의 터미널 창이 자동으로 열림
- 각 터미널에서 Claude Code가 자동 실행
- 각 Claude는 독립된 브랜치에서 작업

**화면 구성**:
```
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│ Terminal 1      │ │ Terminal 2      │ │ Terminal 3      │
│ Claude: login   │ │ Claude: payment │ │ Claude: search  │
│                 │ │                 │ │                 │
│ "로그인 기능    │ │ "결제 모듈      │ │ "검색 API       │
│  구현 중..."    │ │  작성 중..."    │ │  개발 중..."    │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

### 예시 2: A/B 테스트 구현

**상황**: 같은 기능을 2가지 방법으로 구현해서 비교하고 싶음

```bash
# React vs Vue로 같은 UI 구현
./scripts/worktree-parallel.sh parallel ui-react ui-vue

# 각 Claude에게 지시
# Terminal 1: "React로 대시보드 구현해줘"
# Terminal 2: "Vue로 대시보드 구현해줘"
```

### 예시 3: 대규모 리팩토링

```bash
# 인증, DB, UI를 동시에 리팩토링
./scripts/worktree-parallel.sh parallel refactor-auth refactor-db refactor-ui
```

## 🔧 상태 확인 및 관리

### 진행 상황 확인
```bash
./scripts/worktree-parallel.sh status
```

출력 예시:
```
Current Worktree Status:
───────────────────────
✓ login (completed)
⚡ payment (in progress)
⚡ search (in progress)

Port Allocations:
  login: dev=3045, db=5477
  payment: dev=3023, db=5455
  search: dev=3089, db=5521
```

### 완료된 작업 병합
```bash
# 개별 브랜치 병합
git checkout main
git merge login
git merge payment

# Worktree 정리
./scripts/worktree-parallel.sh clean login
```

## 🛠️ 고급 기능

### Hook 자동화

`settings.json`에 Hook 설정 추가:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{
          "type": "command",
          "command": "~/.claude/scripts/hooks/worktree-pre-edit.sh"
        }]
      }
    ]
  }
}
```

효과: 메인 브랜치에서 편집 시도하면 자동으로 worktree 생성 제안

### 포트 충돌 자동 해결

각 worktree는 자동으로 다른 포트를 할당받음:
```
login branch    → localhost:3045
payment branch  → localhost:3023  
search branch   → localhost:3089
```

Docker Compose 사용 시:
```bash
# 각 worktree의 .env.worktree 파일
COMPOSE_PROJECT_NAME=myapp_login  # 독립된 컨테이너 세트
DEV_PORT=3045
DB_PORT=5477
```

## 📊 실제 사용 사례

### 사례 1: 스타트업 MVP 개발
- 5개 핵심 기능을 5개 Claude가 동시 개발
- 개발 시간: 2주 → 3일로 단축
- 각 기능은 독립적으로 테스트 및 배포

### 사례 2: 버그 헌팅
- 10개의 버그 리포트
- 10개 worktree에서 동시 수정
- 각 버그는 별도 PR로 제출

### 사례 3: 마이그레이션
- React 16 → 18 마이그레이션
- 컴포넌트를 5개 그룹으로 나눔
- 5명의 Claude가 동시 작업

## ⚠️ 주의사항

1. **리소스 사용량**: 동시 실행 Claude 수만큼 RAM/CPU 사용
2. **API 사용량**: 각 Claude 세션은 독립적인 API 호출
3. **컨텍스트 격리**: Claude 간 정보 공유 없음 (의도적 설계)
4. **최대 권장**: 동시에 5개까지 (시스템 성능에 따라 조절)

## 💡 Pro Tips

### 1. 작업 분할 전략
```bash
# 나쁜 예: 의존성 있는 작업
parallel backend frontend  # frontend가 backend API 필요

# 좋은 예: 독립적인 작업  
parallel auth-ui payment-ui admin-ui  # UI 컴포넌트는 독립적
```

### 2. 터미널 멀티플렉서 활용
```bash
# tmux나 zellij로 세션 관리
tmux new-session -s claude-parallel
```

### 3. 일괄 커밋 스크립트
```bash
# 모든 worktree에서 커밋
for dir in ../myproject-worktrees/*; do
  (cd "$dir" && git add . && git commit -m "Complete feature")
done
```

## 🔄 워크플로우 예시

완전한 병렬 개발 사이클:

```bash
# 1. 계획 수립
echo "Features: auth, payment, search, admin, api" > plan.txt

# 2. 병렬 실행
./scripts/worktree-parallel.sh parallel auth payment search admin api

# 3. 각 터미널에서 Claude 작업 진행
# (5개 Claude가 동시에 작업)

# 4. 상태 모니터링
watch -n 10 "./scripts/worktree-parallel.sh status"

# 5. 완료된 것부터 순차 병합
git checkout main
for branch in auth payment search admin api; do
  git merge $branch && git push origin main
done

# 6. 정리
./scripts/worktree-parallel.sh clean
```

## 🎯 기대 효과

- **개발 속도**: 3-5배 향상 (병렬 실행 수에 비례)
- **컨텍스트 유지**: 각 작업이 독립적으로 진행되어 혼선 없음
- **리스크 감소**: 실패한 작업이 다른 작업에 영향 없음
- **실험 자유도**: 여러 접근법을 동시에 시도 가능

## 📚 추가 자료

- [Git Worktree 공식 문서](https://git-scm.com/docs/git-worktree)
- [Claude Code Hooks API](https://docs.anthropic.com/en/docs/claude-code/hooks)
- [병렬 개발 베스트 프랙티스](./PARALLEL_BEST_PRACTICES.md)

---

**질문이나 이슈**: GitHub Issues에 등록해주세요
**기여 환영**: PR은 언제나 환영합니다!