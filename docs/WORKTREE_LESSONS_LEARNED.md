# Git Worktree와 Claude Code 통합: 조사 결과 및 교훈

## 📚 조사 요약

### 발견된 주요 패턴들

1. **병렬 AI 개발이 대세**
   - 여러 Claude Code 인스턴스를 동시 실행하는 것이 트렌드
   - Git worktree가 이를 위한 핵심 도구로 부상
   - Ghostty + Git Worktree + Claude Code 조합이 인기

2. **2025년 Claude Code의 새로운 기능들**
   - **Hooks API**: PreToolUse, PostToolUse 등 라이프사이클 이벤트
   - **Headless Mode**: `claude -p`로 프로그래매틱 통합 가능
   - **Custom Commands**: `.claude/commands/` 디렉토리 활용

3. **커뮤니티 도구들**
   - **CCManager**: Claude Code 세션 관리 CLI
   - **GitButler**: Hook을 활용한 자동 브랜치 격리
   - **Sprout**: Docker Compose + Worktree 자동화

## 💡 핵심 인사이트

### 좋았던 점
- Git worktree로 진짜 병렬 개발이 가능함
- 각 Claude 세션의 컨텍스트가 완전히 격리됨
- 포트/DB 충돌 자동 해결 방법들이 존재

### 문제점
- **과도한 복잡성**: 설정과 스크립트가 너무 많아짐
- **터미널 관리 부담**: 여러 터미널 창 관리가 번거로움
- **학습 곡선**: 팀원들이 배워야 할 것이 너무 많음

## 🎯 더 나은 접근법

### 1. Simple is Better
```bash
# 복잡한 자동화보다 간단한 함수가 더 실용적
function cw() {
    git worktree add "../${PWD##*/}-$1" -b "$1"
    cd "../${PWD##*/}-$1"
    claude
}
```

### 2. Hook은 선택적으로
- 모든 것을 자동화하려 하지 말 것
- 정말 필요한 Hook만 최소한으로 사용

### 3. 실제 필요할 때만 병렬 실행
- 대부분의 작업은 순차 실행으로 충분
- 정말 독립적인 작업만 병렬로

## 📝 다음 세션을 위한 메모

### 실용적인 구현 방향
1. **최소 기능부터 시작**
   - 간단한 worktree 생성/제거 명령어만
   - 복잡한 오케스트레이션은 나중에

2. **사용자가 직접 제어**
   - 자동화보다는 도구 제공
   - 명확하고 예측 가능한 동작

3. **점진적 도입**
   - 먼저 수동으로 사용해보기
   - 패턴이 보이면 그때 자동화

### 참고할 만한 구현
```bash
# GitButler의 세션별 격리 아이디어는 좋음
# 하지만 Hook 대신 명시적 명령으로

# CCManager의 세션 관리도 참고할 만함
# 하지만 더 가볍게 구현 가능
```

## 🔗 유용한 링크들 (나중에 참고)

- [Claude Code Hooks API 문서](https://docs.anthropic.com/en/docs/claude-code/hooks)
- [Git Worktree 베스트 프랙티스](https://matklad.github.io/2024/07/25/git-worktrees.html)
- [CCManager GitHub](https://github.com/kbwo/ccmanager)

---

**결론**: Git worktree와 Claude Code 통합은 강력하지만, 과도한 자동화보다는 심플하고 명확한 도구가 더 실용적이다.