# Skills 기반 아키텍처 전환 제안서

> **문서 상태**: Draft (검토 및 토론 필요)
> **작성일**: 2025-12-15
> **최종 수정**: 2025-12-15
> **목적**: 현재 commands/agents 구조를 Claude Code Skills 체계로 전환하기 위한 분석 및 제안

---

## 1. 배경

### 1.1 Claude Code Skills 소개

2025년 10월 16일, Anthropic은 **Agent Skills**를 공식 출시했습니다. Skills는 Claude Code, Claude.ai, Claude API 세 플랫폼에서 동시에 지원됩니다.

**Skills란?**
- 지시사항, 스크립트, 리소스를 포함하는 폴더 구조
- Claude가 작업 컨텍스트에 따라 **자동으로 로드**
- 기존 commands(user-invoked)와 달리 **model-invoked** 방식

### 1.2 Skills vs Commands vs Agents 비교

| 구분 | 호출 방식 | 위치 | 역할 |
|------|----------|------|------|
| **Skills** | Model-invoked (자동) | `~/.claude/skills/` | 도메인 컨테이너 |
| **Commands** | User-invoked (`/cmd`) | Skills 내 `workflows/` | 도메인 내 작업 |
| **Agents** | Task tool 호출 | `~/.claude/agents/` | 독립 병렬 워커 |

**핵심 변화**: Commands는 폐기되지 않고, Skills 내부 `workflows/` 디렉토리로 **중첩**되는 구조로 전환

### 1.3 참고 자료

- [Anthropic Agent Skills 공식 발표](https://claude.com/blog/skills)
- [anthropics/skills GitHub Repository](https://github.com/anthropics/skills)
- [Skills vs Commands vs Agents 분석](https://danielmiessler.com/blog/when-to-use-skills-vs-commands-vs-agents)
- [Claude Code Skills 구조 Deep Dive](https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/)
- [Anthropic Engineering Blog - Agent Skills 설계](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)

---

## 2. 현재 구조 분석

### 2.1 현재 디렉토리 구조

```
profiles/
├── account/
│   ├── agents/                    # 7개 독립 agents
│   │   ├── code-reviewer.md
│   │   ├── debugger.md
│   │   ├── plan-agent.md
│   │   ├── reflection-agent.md
│   │   ├── test-runner.md
│   │   ├── time-aware.md
│   │   └── worktree-coordinator.md
│   │
│   ├── commands/                  # 16+ commands (도메인별 분리)
│   │   ├── dev/                   # 8개: commit, debug, epct, explain,
│   │   │                          #       optimize, refactor, review, test
│   │   ├── flow/                  # 6개: fix-errors, handoff, plan,
│   │   │                          #       reflection, resume, scaffold
│   │   ├── gh/                    # 2개: pr, docs
│   │   └── worktree/              # 4개: distribute, plan, status, sync
│   │
│   ├── scripts/                   # 지원 스크립트
│   ├── CLAUDE.md                  # 글로벌 설정
│   └── llm-models-latest.md       # LLM 모델 참조
│
└── projects/
    ├── _base/                     # 베이스 프로필 (smart-* commands)
    ├── python/                    # Python 전용
    │   └── .claude/
    │       ├── agents/            # 5개: data-science, fastapi-expert,
    │       │                      #      python-async, python-tdd, python-test-runner
    │       └── commands/          # dev/, test/
    ├── javascript/                # JS 전용 (commands만)
    └── rust/                      # Rust 전용 (commands만)
```

### 2.2 프로필별 현황 분석

| 프로필 | Agents | Commands | 특징 |
|--------|--------|----------|------|
| **Account** | 7개 | 16개 | 범용, 풍부함 |
| **Python** | 5개 | 7개 | 매우 상세 (fastapi-expert: 386줄) |
| **JavaScript** | 0개 | 3개 | 빈약, 간략함 (bundle: 61줄) |
| **Rust** | 0개 | 3개 | 최소화 |
| **_base** | 0개 | 3개 | auto-detect (smart-*) |

### 2.3 현재 구조의 문제점

| 문제 | 상세 | 예시 |
|------|------|------|
| **관련 기능 분산** | Agent와 관련 commands가 별도 위치 | `worktree-coordinator` agent와 `worktree/*` commands |
| **수동 자동호출 설정** | CLAUDE.md에 auto-invoke 규칙 직접 정의 | `Test failures → test-runner` |
| **Context 공유 없음** | 각 command가 독립적으로 동작 | handoff/resume 간 공통 템플릿 부재 |
| **배포 복잡성** | 기능 공유 시 여러 디렉토리 복사 필요 | agents/ + commands/ + scripts/ |
| **도메인 경계 모호** | dev/debug.md vs debugger.md 역할 구분 | 어떤 것을 사용해야 하는지 혼란 |
| **프로필 불균형** | Python은 풍부, JS/Rust는 빈약 | 유지보수 일관성 저하 |
| **중복** | account/dev/test와 python/test/test 유사 역할 | 어떤 걸 써야 하는지 혼란 |

### 2.4 도메인별 현황

#### Development 도메인
- **Agent**: `code-reviewer.md`
- **Commands**: `dev/commit`, `dev/debug`, `dev/review`, `dev/refactor`, `dev/optimize`, `dev/explain`, `dev/test`, `dev/epct`
- **이슈**: code-reviewer agent와 dev/review command 역할 중복

#### Workflow 도메인
- **Agents**: `plan-agent.md`, `reflection-agent.md`
- **Commands**: `flow/handoff`, `flow/resume`, `flow/plan`, `flow/scaffold`, `flow/fix-errors`, `flow/reflection`
- **이슈**: plan-agent와 flow/plan 관계 불명확

#### Testing 도메인
- **Agents**: `test-runner.md`, `debugger.md`
- **Commands**: `dev/test`, `dev/debug`
- **이슈**: agent vs command 선택 기준 불명확

#### Worktree 도메인
- **Agent**: `worktree-coordinator.md`
- **Commands**: `worktree/distribute`, `worktree/plan`, `worktree/status`, `worktree/sync`
- **이슈**: 가장 응집도 높음, Skill 전환 최적 후보

#### GitHub 도메인
- **Commands**: `gh/pr`, `gh/docs`
- **이슈**: 단순하여 그대로 유지 가능

---

## 3. 계정/프로젝트 분리 폐지 분석

### 3.1 현재 분리 구조의 문제점

```
현재: profiles/account/ + profiles/projects/{lang}/
     ↓
문제: 중복, 불균형, 발견성 저하, 유지보수 분산
```

| 문제 | 상세 |
|------|------|
| **불균형** | Python은 5개 agents + 7개 commands, JS/Rust는 각 3개 commands만 |
| **중복** | `account/dev/test` vs `python/test/test` 역할 유사 |
| **발견성 저하** | 어떤 command가 어디에 있는지 찾기 어려움 |
| **유지보수 분산** | 유사 내용이 여러 위치에서 관리됨 |

### 3.2 Skills 체계에서 분리가 불필요한 이유

1. **Description 기반 자동 활성화**
   - Skills는 `description` 필드로 자동 호출 판단
   - "Python 프로젝트" 컨텍스트 → python 관련 context 자동 로드
   - 별도 프로젝트 프로필 불필요

2. **Context 파일로 언어별 지식 분리**
   ```
   skills/testing/
   └── context/
       ├── python.md     # pytest 가이드
       ├── javascript.md # jest/vitest 가이드
       └── rust.md       # cargo test 가이드
   ```

3. **_base/smart-* 역할 흡수**
   - `testing/SKILL.md`가 언어 감지 + 적절한 context 로드
   - 별도 smart-test, smart-lint 불필요

### 3.3 제안: 단일 계층 Skills 구조

**계정/프로젝트 분리 제거**, 모든 Skills를 한 곳에서 관리:

```
~/.claude/
├── skills/                        # 모든 Skills (단일 계층)
│   ├── development/               # 범용 개발 워크플로우
│   ├── workflow/                  # 세션/플래닝 관리
│   ├── github/                    # GitHub 연동
│   ├── worktree/                  # Git worktree 관리
│   ├── testing/                   # 통합 테스트 (auto-detect)
│   ├── linting/                   # 통합 린팅 (auto-detect)
│   └── frameworks/                # 프레임워크 전문가
│       └── fastapi/
│
├── agents/                        # 유틸리티 에이전트만
│   └── time-aware.md
│
└── CLAUDE.md                      # 단순화된 글로벌 설정
```

---

## 4. 제안 구조 상세

### 4.1 통합 Skills 아키텍처

```
~/.claude/skills/
│
├── development/                   # 개발 도메인 Skill
│   ├── SKILL.md                   # 라우팅 로직 + code-reviewer 통합
│   ├── workflows/
│   │   ├── commit.md
│   │   ├── review.md
│   │   ├── refactor.md
│   │   ├── optimize.md
│   │   └── explain.md
│   └── context/
│       └── code-standards.md
│
├── workflow/                      # 워크플로우 도메인 Skill
│   ├── SKILL.md                   # plan-agent + reflection 통합
│   ├── workflows/
│   │   ├── handoff.md
│   │   ├── resume.md
│   │   ├── plan.md
│   │   ├── scaffold.md
│   │   └── fix-errors.md
│   └── context/
│       ├── handoff-template.md
│       └── planning-guide.md
│
├── testing/                       # 통합 테스트 Skill (언어 auto-detect)
│   ├── SKILL.md                   # test-runner + debugger + 언어 감지
│   ├── workflows/
│   │   ├── test.md                # 범용 진입점
│   │   └── debug.md
│   └── context/
│       ├── python.md              # pytest 상세 가이드
│       ├── javascript.md          # jest/vitest 가이드
│       └── rust.md                # cargo test 가이드
│
├── linting/                       # 통합 린팅 Skill (언어 auto-detect)
│   ├── SKILL.md                   # 언어 감지 + 라우팅
│   ├── workflows/
│   │   └── lint.md
│   └── context/
│       ├── python.md              # ruff 상세 가이드 (현재 186줄 내용)
│       ├── javascript.md          # eslint 가이드
│       └── rust.md                # clippy 가이드
│
├── github/                        # GitHub 도메인 Skill
│   ├── SKILL.md
│   └── workflows/
│       ├── pr.md
│       └── docs.md
│
├── worktree/                      # Worktree 도메인 Skill
│   ├── SKILL.md                   # worktree-coordinator 통합
│   ├── workflows/
│   │   ├── distribute.md
│   │   ├── plan.md
│   │   ├── status.md
│   │   └── sync.md
│   └── context/
│       └── worktree-guide.md
│
└── frameworks/                    # 프레임워크 전문가 (선택적)
    └── fastapi/
        ├── SKILL.md               # FastAPI expert 통합
        └── context/
            ├── patterns.md
            └── async-sqlalchemy.md
```

### 4.2 SKILL.md 스펙

#### 필수 Frontmatter

```yaml
---
name: skill-name              # 고유 식별자 (소문자, 하이픈)
description: |                # 스킬 설명 (Claude가 자동 호출 판단에 사용)
  When to use this skill and what it does.
  Be specific about triggers and capabilities.
---
```

#### 선택 Frontmatter

```yaml
---
name: development
description: Code development tasks
allowed-tools: Read, Grep, Glob, Bash, Edit, Write
model: sonnet                 # 기본 모델 (sonnet/opus/haiku)
---
```

#### SKILL.md 본문 구조

```markdown
# Skill Name

## Overview
[스킬의 목적과 범위]

## Capabilities
[이 스킬이 할 수 있는 것들]

## Routing Logic
[어떤 요청이 어떤 workflow로 라우팅되는지]

## Language Detection (for testing/linting)
[언어 감지 로직 - 해당 시]

## Guidelines
[스킬 실행 시 따라야 할 가이드라인]

## Integration
[다른 스킬이나 도구와의 연동 방법]
```

### 4.3 예시: Testing Skill (통합)

```yaml
---
name: testing
description: |
  Unified testing skill with automatic language detection.
  Use when: running tests, debugging test failures, improving coverage,
  or setting up test infrastructure.
  Supports: Python (pytest), JavaScript (jest/vitest/mocha), Rust (cargo test)
allowed-tools: Read, Grep, Glob, Bash, Edit, Write
---

# Testing Skill

## Overview

통합 테스트 스킬입니다. 프로젝트 언어를 자동 감지하고 적절한 테스트 도구를 실행합니다.

## Language Detection

1. **Python**: `pyproject.toml`, `setup.py`, `requirements.txt`, `*.py`
   → Load `context/python.md`, use pytest

2. **JavaScript/TypeScript**: `package.json`, `*.js`, `*.ts`
   → Load `context/javascript.md`, detect jest/vitest/mocha

3. **Rust**: `Cargo.toml`
   → Load `context/rust.md`, use cargo test

## Capabilities

- **Test Discovery**: 테스트 파일 자동 발견
- **Test Execution**: 적절한 도구로 테스트 실행
- **Failure Analysis**: 실패 분석 및 수정 제안
- **Coverage**: 커버리지 리포트 및 개선 제안
- **Debug**: 테스트 디버깅 지원

## Routing Logic

| 요청 패턴 | Workflow | Context |
|----------|----------|---------|
| "테스트 실행", "run tests" | `workflows/test.md` | 언어별 context |
| "테스트 디버그", "test failure" | `workflows/debug.md` | 언어별 context |

## Guidelines

1. 언어 감지 후 해당 context 파일 참조
2. 프로젝트 설정 파일 (pyproject.toml 등) 우선 확인
3. 실패 시 상세 분석 및 수정 코드 제안
```

### 4.4 예시: Worktree Skill

```yaml
---
name: worktree
description: |
  Git worktree management for parallel task execution.
  Use when: distributing tasks across worktrees, checking worktree status,
  synchronizing environments, or planning parallel work.
allowed-tools: Read, Grep, Glob, Bash, Edit, Write
---

# Worktree Management Skill

## Overview

병렬 작업 실행을 위한 Git worktree 관리 스킬입니다.
독립적인 작업 단위를 여러 worktree에 분산하여 동시 진행할 수 있습니다.

## Capabilities

- **Plan**: plan-agent를 활용한 병렬 작업 계획 수립
- **Distribute**: PLAN.md 기반 worktree 생성 및 작업 분배
- **Status**: 모든 worktree 진행 상황 모니터링
- **Sync**: 환경 파일 및 공유 컨텍스트 동기화

## Routing Logic

| 요청 패턴 | Workflow |
|----------|----------|
| "worktree 계획", "병렬 작업 분석" | `workflows/plan.md` |
| "worktree 분배", "작업 시작" | `workflows/distribute.md` |
| "worktree 상태", "진행 확인" | `workflows/status.md` |
| "worktree 동기화", "환경 맞추기" | `workflows/sync.md` |

## Workflow Sequence

```
/worktree:plan → PLAN.md 생성 → /worktree:distribute → 병렬 실행 → /worktree:status
```

## Integration

- **plan-agent**: 복잡한 작업 분석 시 활용
- **workflow skill**: handoff와 연계하여 세션 관리
```

---

## 5. time-aware Agent 유지 필요성

### 5.1 현재 상황 조사 결과

**Claude Code에는 아직 built-in 날짜/시간 기능이 없습니다.**

| 항목 | 상태 |
|------|------|
| Built-in 날짜 기능 | ❌ 없음 |
| Feature Request | [#2618](https://github.com/anthropics/claude-code/issues/2618), [#7537](https://github.com/anthropics/claude-code/issues/7537) - OPEN |
| 최근 버그 리포트 | [#11728](https://github.com/anthropics/claude-code/issues/11728) (2025-11-16) - OPEN |
| Claude.ai | ✅ 시스템 프롬프트에 날짜 자동 주입 |
| Claude Code | ❌ 자동 주입 없음, hook/MCP 필요 |

### 5.2 문제 상세

2025년 11월에도 여전히 발생하는 문제 ([Issue #11728](https://github.com/anthropics/claude-code/issues/11728)):
> "Claude가 2025-11-15에 문서를 생성하면서 **30개 이상의 날짜를 2025-01-16**으로 기록"

**원인**:
1. 지식 컷오프 날짜 (January 2025)가 "현재"로 앵커링
2. 환경 블록 정보를 충분히 활용하지 않음
3. 인지적 편향 (인간이 1월에 작년 날짜 쓰는 것과 유사)

### 5.3 결론: time-aware 유지

```
~/.claude/
├── skills/          # Skills 기반 구조
└── agents/
    └── time-aware.md   # ✅ 유지 (유틸리티)
```

**이유**:
- Claude Code에 built-in 기능이 추가될 때까지 필요
- hook으로 날짜 주입하는 현재 방식 유지
- Skill로 전환 불필요 (도메인 캡슐화 해당 없음)

---

## 6. 마이그레이션 전략

### 6.1 개요

| Phase | 기간 | 목표 |
|-------|------|------|
| 1 | 1-2주 | Worktree skill 전환 (검증) |
| 2 | 1-2주 | Testing skill 통합 (언어별 통합) |
| 3 | 1-2주 | Linting skill 통합 |
| 4 | 2-3주 | Development/Workflow/GitHub skills |
| 5 | 1주 | Frameworks skill (FastAPI) |
| 6 | 1주 | 정리 및 프로젝트 프로필 제거 |

**총 예상 기간**: 7-11주

### 6.2 Phase 1: Worktree Skill (1-2주)

**목표**: Skills 체계 검증

```
profiles/account/
├── skills/
│   └── worktree/        # NEW
├── commands/            # KEEP (하위 호환)
└── agents/              # KEEP
```

**작업 내용**:
1. `skills/worktree/` 디렉토리 생성
2. `worktree-coordinator.md` → `SKILL.md` 통합
3. `worktree/*` commands → `workflows/` 복사
4. 테스트 및 검증

**성공 기준**:
- 기존 `/worktree:*` 명령어 정상 작동
- Skills 자동 호출 테스트 통과
- 하위 호환성 유지

### 6.3 Phase 2: Testing Skill 통합 (1-2주)

**목표**: 언어별 테스트 기능 통합

**통합 대상**:
- `account/agents/test-runner.md`
- `account/agents/debugger.md`
- `account/commands/dev/test.md`
- `account/commands/dev/debug.md`
- `projects/_base/commands/test/smart-test.md`
- `projects/python/commands/test/test.md`
- `projects/python/agents/python-test-runner.md`
- `projects/javascript/commands/test/test.md`
- `projects/rust/commands/test/test.md`

**결과**:
```
skills/testing/
├── SKILL.md           # 통합 + 언어 감지
├── workflows/
│   ├── test.md
│   └── debug.md
└── context/
    ├── python.md      # pytest 상세 가이드
    ├── javascript.md  # jest/vitest 가이드
    └── rust.md        # cargo test 가이드
```

### 6.4 Phase 3: Linting Skill 통합 (1-2주)

**통합 대상**:
- `projects/_base/commands/dev/smart-lint.md`
- `projects/python/commands/dev/lint.md` (186줄 상세 내용)
- `projects/javascript/commands/dev/lint.md`
- `projects/rust/commands/dev/clippy.md`

**결과**:
```
skills/linting/
├── SKILL.md
├── workflows/
│   └── lint.md
└── context/
    ├── python.md      # ruff 상세 가이드
    ├── javascript.md  # eslint 가이드
    └── rust.md        # clippy 가이드
```

### 6.5 Phase 4: Development/Workflow/GitHub Skills (2-3주)

**Development**:
- `code-reviewer.md` → SKILL.md 통합
- `dev/*` commands → workflows/

**Workflow**:
- `plan-agent.md`, `reflection-agent.md` → SKILL.md 통합
- `flow/*` commands → workflows/

**GitHub**:
- `gh/*` commands → workflows/

### 6.6 Phase 5: Frameworks Skill (1주)

**목표**: 고품질 프레임워크 전문가 지식 유지

```
skills/frameworks/
└── fastapi/
    ├── SKILL.md       # fastapi-expert.md 통합
    └── context/
        ├── patterns.md
        └── async-sqlalchemy.md
```

**나머지 Python agents 정리**:
- `python-async.md` → `testing/context/python.md`에 통합
- `python-tdd.md` → `testing/context/python.md`에 통합
- `data-science.md` → 필요시 별도 skill 또는 제거 검토

### 6.7 Phase 6: 정리 및 문서화 (1주)

**작업 내용**:
1. `profiles/projects/` 디렉토리 제거 또는 deprecated 표시
2. `profiles/account/commands/` deprecated 표시
3. `profiles/account/agents/` 정리 (time-aware만 유지)
4. `ccfg init` 로직 변경 (프로젝트 프로필 대신 skills 안내)
5. README.md, MIGRATION.md 업데이트
6. install.sh 업데이트

---

## 7. 기술적 고려사항

### 7.1 SKILL.md Frontmatter 호환성

현재 agents의 frontmatter:
```yaml
---
name: code-reviewer
description: Comprehensive code review...
tools: Read, Grep, Glob
model: sonnet
---
```

Skills의 frontmatter:
```yaml
---
name: code-reviewer
description: Comprehensive code review...
allowed-tools: Read, Grep, Glob  # 'tools' → 'allowed-tools'
---
```

**호환성**: 기존 agent frontmatter와 유사하여 전환 용이

### 7.2 자동 호출 메커니즘

**현재 (CLAUDE.md에 수동 정의)**:
```markdown
## Auto-invoke
- Test failures → test-runner
- PR creation → code-reviewer
```

**Skills (description 기반 자동)**:
```yaml
description: |
  Use when: test failures occur, code review needed, PR creation...
```

**장점**: CLAUDE.md 단순화, 자동 호출 로직이 스킬에 캡슐화

### 7.3 Workflows 명명 규칙

기존 `/worktree:plan` → Skills 전환 후에도 동일하게 사용 가능

```
skills/worktree/workflows/plan.md
→ /worktree:plan 명령어로 호출 가능
```

### 7.4 Context 파일을 통한 언어별 분기

```
skills/testing/
├── SKILL.md           # 언어 감지 로직
└── context/
    ├── python.md      # Python 감지 시 로드
    ├── javascript.md  # JS 감지 시 로드
    └── rust.md        # Rust 감지 시 로드
```

SKILL.md에서 참조:
```markdown
## Language Detection

Based on project files, load appropriate context:
- Python detected → Reference `context/python.md`
- JavaScript detected → Reference `context/javascript.md`
- Rust detected → Reference `context/rust.md`
```

---

## 8. 리스크 및 완화 방안

### 8.1 하위 호환성 리스크

| 리스크 | 완화 방안 |
|--------|----------|
| 기존 `/command` 동작 안함 | Phase 1에서 commands/ 유지, 점진적 전환 |
| 기존 설치 사용자 영향 | install.sh에서 skills/ 자동 생성, 기존 구조 유지 |
| Agent Task tool 호출 실패 | agents/time-aware.md 유지 |
| 프로젝트 프로필 사용자 | ccfg init 변경 시 마이그레이션 가이드 제공 |

### 8.2 Skills 베타 상태 리스크

**현재 상태**: `skills-2025-10-02` 베타

| 리스크 | 완화 방안 |
|--------|----------|
| API 변경 가능성 | 공식 스펙 모니터링, 최소 필수 필드만 사용 |
| 기능 불안정 | Phase 1에서 충분한 테스트 후 확대 |

### 8.3 마이그레이션 복잡성 리스크

| 리스크 | 완화 방안 |
|--------|----------|
| 전환 중 기능 손실 | 복사 후 검증, 이동은 검증 후 진행 |
| 사용자 혼란 | 명확한 마이그레이션 가이드 제공 |
| 언어별 context 누락 | Python 우선 (가장 상세), JS/Rust는 점진적 |

---

## 9. 이점 vs 비용 분석

### 9.1 이점

| 항목 | 상세 |
|------|------|
| **구조 단순화** | 계정/프로젝트 분리 제거 → 한 곳에서 관리 |
| **자동 호출** | Claude가 컨텍스트 기반으로 적절한 skill 자동 활성화 |
| **캡슐화** | 관련 기능(agent + commands + context)이 한 곳에 |
| **공유 용이** | skill 폴더 하나로 기능 배포 가능 |
| **마켓플레이스 호환** | anthropics/skills 레포지토리와 호환 |
| **Progressive Disclosure** | 필요한 시점에만 최소 정보 로드 |
| **CLAUDE.md 단순화** | auto-invoke 규칙을 skill로 이동 |
| **언어별 불균형 해소** | 통합 skill + context로 일관성 확보 |

### 9.2 비용

| 항목 | 상세 |
|------|------|
| **마이그레이션 작업** | 구조 변경, 테스트, 문서화 필요 (약 7-11주) |
| **학습 곡선** | Skills 체계 이해 필요 |
| **잠재적 버그** | 자동 호출 의도치 않은 동작 가능성 |
| **베타 리스크** | Skills API 변경 가능성 |
| **ccfg 도구 변경** | 프로젝트 초기화 로직 수정 필요 |

### 9.3 ROI 평가

**단기 (1-3개월)**: 비용 > 이점 (전환 작업 집중)
**중기 (3-6개월)**: 이점 ≈ 비용 (안정화)
**장기 (6개월+)**: 이점 > 비용 (유지보수 용이, 확장성)

---

## 10. 결정 필요 사항

### 10.1 구조 관련

- [x] ~~time-aware agent를 skill로 전환할지~~ → **Agent로 유지** (built-in 기능 부재)
- [x] ~~계정/프로젝트 분리 유지 여부~~ → **폐지** (Skills로 통합)
- [ ] dev/debug vs debugger 통합 방식 (testing skill에 통합?)
- [ ] GitHub skill 필요성 (단순 workflows로 충분한지?)
- [ ] data-science.md 처리 (별도 skill vs 제거)

### 10.2 마이그레이션 관련

- [ ] Phase 1 시작 시점
- [ ] 기존 commands/ 완전 제거 시점 (또는 영구 유지)
- [ ] ccfg init 변경 범위

### 10.3 배포 관련

- [ ] Plugin 형태로 마켓플레이스 배포 여부
- [ ] 설치 스크립트 업데이트 범위

---

## 11. 다음 단계

1. **이 문서 최종 검토**
2. **결정 필요 사항 (섹션 10) 논의**
3. **Phase 1 상세 계획 수립**
4. **Worktree skill 프로토타입 구현**
5. **테스트 및 검증**
6. **점진적 확대**

---

## Appendix A: 참고 링크

### Skills 관련
- [Anthropic Agent Skills 공식](https://claude.com/blog/skills)
- [Skills 생성 가이드](https://claude.com/blog/how-to-create-skills-key-steps-limitations-and-examples)
- [anthropics/skills GitHub](https://github.com/anthropics/skills)
- [Skills vs Commands 분석](https://danielmiessler.com/blog/when-to-use-skills-vs-commands-vs-agents)
- [Agent Skills Deep Dive](https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/)
- [Claude Code Skills 구조](https://mikhail.io/2025/10/claude-code-skills/)
- [Anthropic Engineering - Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)

### 날짜/시간 관련
- [Issue #11728 - Claude defaults to knowledge cutoff date](https://github.com/anthropics/claude-code/issues/11728)
- [Issue #2618 - A date tool should be included by default](https://github.com/anthropics/claude-code/issues/2618)
- [Issue #7537 - Add Current Date Awareness](https://github.com/anthropics/claude-code/issues/7537)
- [Claude Code Date Bug Fix](https://www.nathanonn.com/the-claude-code-date-bug-thats-sabotaging-your-web-searches-and-the-3-minute-fix/)

## Appendix B: 용어 정의

| 용어 | 정의 |
|------|------|
| **Skill** | 지시사항, 스크립트, 리소스를 포함하는 폴더로, Claude가 자동으로 로드 |
| **SKILL.md** | Skill의 메인 설정 파일, frontmatter와 지시사항 포함 |
| **Workflow** | Skill 내부의 개별 작업 단위 (기존 command에 해당) |
| **Context** | Skill 내 공유되는 참조 문서 (언어별 가이드 등) |
| **Model-invoked** | Claude가 컨텍스트 기반으로 자동 호출하는 방식 |
| **User-invoked** | 사용자가 `/command`로 직접 호출하는 방식 |
| **Progressive Disclosure** | 필요한 시점에만 최소 정보를 로드하는 설계 원칙 |

## Appendix C: 현재 기능 목록

### Account-level Agents (7개)
1. `code-reviewer.md` - 코드 리뷰 → development skill로 통합
2. `debugger.md` - 디버깅 → testing skill로 통합
3. `plan-agent.md` - 전략적 계획 → workflow skill로 통합
4. `reflection-agent.md` - 자기 분석 → workflow skill로 통합
5. `test-runner.md` - 테스트 실행 → testing skill로 통합
6. `time-aware.md` - 시간 정보 → **Agent 유지**
7. `worktree-coordinator.md` - Worktree 관리 → worktree skill로 통합

### Account-level Commands (16개)
**dev/** (8개): commit, debug, epct, explain, optimize, refactor, review, test
**flow/** (6개): fix-errors, handoff, plan, reflection, resume, scaffold
**gh/** (2개): docs, pr
**worktree/** (4개): distribute, plan, status, sync

### Python Profile Agents (5개)
1. `data-science.md` → 검토 필요 (별도 skill vs 제거)
2. `fastapi-expert.md` → frameworks/fastapi skill
3. `python-async.md` → testing/context/python.md 통합
4. `python-tdd.md` → testing/context/python.md 통합
5. `python-test-runner.md` → testing skill 통합

### Project Commands (통합 대상)
- `_base/smart-*` → 각 skill에 auto-detect 로직으로 통합
- `python/*` → context/python.md로 통합
- `javascript/*` → context/javascript.md로 통합
- `rust/*` → context/rust.md로 통합

## Appendix D: 전환 전후 비교

### Before (현재)
```
profiles/
├── account/
│   ├── agents/        (7개)
│   └── commands/      (16개)
└── projects/
    ├── _base/         (3개 smart-* commands)
    ├── python/        (5 agents + 7 commands)
    ├── javascript/    (3 commands)
    └── rust/          (3 commands)

총: 7 agents + 32 commands = 39개 파일
```

### After (제안)
```
~/.claude/
├── skills/
│   ├── development/   (1 SKILL.md + 5 workflows + 1 context)
│   ├── workflow/      (1 SKILL.md + 5 workflows + 2 contexts)
│   ├── testing/       (1 SKILL.md + 2 workflows + 3 contexts)
│   ├── linting/       (1 SKILL.md + 1 workflow + 3 contexts)
│   ├── github/        (1 SKILL.md + 2 workflows)
│   ├── worktree/      (1 SKILL.md + 4 workflows + 1 context)
│   └── frameworks/
│       └── fastapi/   (1 SKILL.md + 2 contexts)
└── agents/
    └── time-aware.md  (1개)

총: 7 skills + 1 agent = 8개 도메인 단위 관리
```

**개선 효과**:
- 분산된 39개 파일 → 8개 도메인 단위로 응집
- 계정/프로젝트 분리 제거 → 단일 계층
- 언어별 분리 제거 → context 파일로 통합
