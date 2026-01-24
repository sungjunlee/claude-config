# Latest LLM Models Reference (2025-12)

최신 LLM 모델 정보 - API 사용 시 구형 모델 대신 아래 최신 모델을 사용하세요.
*마지막 업데이트: 2025년 12월 15일*

## 🔥 주요 플레이어 최신 모델

### OpenAI (2025년 12월 기준)

**최신 모델:**
- `gpt-5.2` / `gpt-5.2-pro` - 2025년 12월 11일 출시
  - **GPT-5.2 Instant** (`gpt-5.2-chat-latest`): 속도 최적화, 일상 작업용
  - **GPT-5.2 Thinking** (`gpt-5.2`): 복잡한 작업, 장기 실행 에이전트
  - **GPT-5.2 Pro** (`gpt-5.2-pro`): 최고 정확도, 어려운 질문
  - 400K 입력 토큰, 128K 출력 토큰
  - 지식 컷오프: 2025년 8월 31일
  - GPQA Diamond: Pro 93.2%, Thinking 92.4%
  - GDPval: 인간 전문가 수준 70.9% 도달
  - Thinking 응답 오류 38% 감소 (전작 대비)

- `gpt-5.1` / `gpt-5.1-codex-max` - 2025년 11월 12일, 19일 출시
  - **GPT-5.1 Instant**: 적응형 추론, 간단한 작업 시 빠른 응답
  - **GPT-5.1 Thinking**: 복잡한 추론 작업용
  - **GPT-5.1-Codex-Max**: 24시간+ 장기 실행 에이전틱 코딩 모델
  - 24시간 프롬프트 캐시 유지
  - GPT-4.1/GPT-5 대비 2-3배 빠른 속도
  - apply_patch, shell 도구 내장

- `gpt-5` / `gpt-5-mini` / `gpt-5-nano` - 2025년 8월 7일 출시
  - ⚠️ **중요**: temperature 파라미터 지원 안함
  - 새로운 파라미터: `verbosity`, `reasoning_effort`
  - 272K 입력 토큰, 128K 출력 토큰

- `gpt-4.1` / `gpt-4.1-mini` / `gpt-4.1-nano` - 2025년 4월 출시
  - 프로그래밍 특화, temperature 지원
  - 1M 토큰 컨텍스트
  - API 전용 (ChatGPT에서는 사용 불가)

**구형 모델 (사용 지양):**
- ❌ `gpt-5` 단독 (GPT-5.1/5.2로 대체)
- ❌ `gpt-4o`, `gpt-4o-mini` (GPT-4.1로 대체)
- ❌ `gpt-4-turbo-preview`, `gpt-3.5-turbo`

### Anthropic (2025년 12월 기준)

**최신 모델:**
- `claude-opus-4-5-20251101` - 2025년 11월 24일 출시
  - ⭐ **SWE-bench Verified 80.9%** (업계 최고!)
  - 200K 컨텍스트, 64K 출력
  - $5 입력 / $25 출력 (Opus 4.1 대비 66% 인하!)
  - `effort` 파라미터 지원 (토큰 효율 제어)
  - Medium effort: Sonnet 4.5 성능, 76% 적은 토큰
  - High effort: Sonnet 4.5+4.3% 성능, 48% 적은 토큰
  - 지식 컷오프: 2025년 3월

- `claude-sonnet-4-5-20250929` - 2025년 9월 29일 출시
  - SWE-bench Verified: 77.2% (병렬 82.0%)
  - OSWorld: 61.4% (실제 컴퓨터 작업)
  - Terminal-Bench: 50.0%
  - 200K 컨텍스트, 64K 출력
  - $3 입력 / $15 출력
  - 30시간 자율 실행 가능 (Opus 4의 7시간에서 대폭 증가)
  - computer use, context awareness 지원

- `claude-haiku-4-5-20251015` - 2025년 10월 15일 출시
  - SWE-bench Verified: 73.3%
  - 200K 컨텍스트, 64K 출력
  - $1 입력 / $5 출력
  - Sonnet 4 성능, 1/3 비용, 2배 이상 속도
  - extended thinking, computer use 지원
  - 지식 컷오프: 2025년 2월

**구형 모델 (사용 지양):**
- ❌ `claude-opus-4-1-20250805` (Opus 4.5로 대체)
- ❌ `claude-sonnet-4-20250522` (Sonnet 4.5로 대체)
- ❌ `claude-3-5-sonnet`, `claude-3-opus` (퇴역)
- ❌ `claude-2.1`

### Google (2025년 12월 기준)

**최신 모델:**
- `gemini-3-pro` - 2025년 11월 18일 출시
  - ⭐ **LMArena 1501 Elo** (최초 1500+ 돌파!)
  - SWE-bench Verified: 76.2%
  - Terminal-Bench 2.0: 54.2%
  - WebDev Arena: 1487 Elo
  - 1M 입력, 64K 출력
  - 10-15단계 논리적 추론 가능 (이전 모델 5-6단계)
  - 180+ 국가, 100+ 언어 지원

- **Gemini 3 Deep Think** - 2025년 12월 4일 출시
  - Humanity's Last Exam: 41.0% (GPT-5.1 대비 +11%)
  - ARC-AGI-2: 45.1% (업계 최초 45%+ 돌파)
  - GPQA Diamond: 93.8%
  - 병렬 가설 탐색 추론
  - AI Ultra 구독자 전용

- `gemini-2.5-pro` - 2025년 8월 안정화
  - Thinking 모델, 수학/과학 벤치마크 강점
  - 1M+ 컨텍스트

- `gemini-2.5-flash` / `gemini-2.5-flash-lite` - 2025년 11월 7일 업데이트
  - Flash-Lite: $0.10/$0.40 (최저 비용)
  - SWE-bench: 54%

**예정 모델:**
- `gemini-3-flash` - 2026년 1-2월 예상

**구형 모델 (사용 지양):**
- ❌ `gemini-2.0-flash`, `gemini-2.0-pro`
- ❌ `gemini-1.5-pro`, `gemini-1.5-flash`

## 💰 가격 정보 요약

### OpenAI API 가격 (per 1M tokens)
| 모델 | 입력 | 출력 | 캐시 할인 |
|------|------|------|----------|
| GPT-5.2 Thinking | $1.75 | $14 | 90% |
| GPT-5.2 Pro | $21 | $168 | 90% |
| GPT-5.1 | $1.25 | $10 | 90% |
| GPT-4.1 | $2 | $8 | - |

### Anthropic API 가격 (per 1M tokens)
| 모델 | 입력 | 출력 |
|------|------|------|
| Opus 4.5 | $5 | $25 |
| Sonnet 4.5 | $3 | $15 |
| Haiku 4.5 | $1 | $5 |

### Google API 가격 (per 1M tokens)
| 모델 | 입력 | 출력 | 비고 |
|------|------|------|------|
| Gemini 3 Pro | $2 | $12 | <200K |
| Gemini 3 Pro | $4 | $18 | >200K |
| Gemini 2.5 Pro | $1.25 | $10 | |
| Gemini 2.5 Flash | $0.30 | $2.50 | |
| Gemini 2.5 Flash-Lite | $0.10 | $0.40 | 최저가 |

## 💰 비용-성능 권장사항

### 코딩 작업
1. **최고 성능**: Claude Opus 4.5 (SWE-bench 80.9%) 🏆
2. **균형형**: Claude Sonnet 4.5 (77.2%), GPT-5.2 Thinking
3. **비용 효율**: Claude Haiku 4.5 ($1/$5, 73.3%)
4. **장기 실행 에이전트**: GPT-5.1-Codex-Max (24시간+)

### 장문 컨텍스트 (문서 분석)
1. **최고 성능**: Gemini 3 Pro (1M), Claude Sonnet 4.5 (1M 프리뷰)
2. **균형**: GPT-4.1 (1M 토큰)
3. **비용 효율**: Gemini 2.5 Flash-Lite ($0.10/$0.40)

### 추론/수학 문제
1. **최고 성능**: Gemini 3 Deep Think (HLE 41%, ARC-AGI-2 45.1%)
2. **정확도**: GPT-5.2 Pro (GPQA 93.2%)
3. **균형**: Claude Opus 4.5 (effort 조절 가능)

### 에이전트/멀티태스크
1. **최고 성능**: Claude Opus 4.5 (SWE-bench 80.9%, effort 파라미터)
2. **자율 실행**: Claude Sonnet 4.5 (30시간 자율)
3. **장기 코딩**: GPT-5.1-Codex-Max (24시간+)

## ⚡ API 사용 예시

### OpenAI GPT-5.2
```python
# GPT-5.2 Thinking (복잡한 작업)
response = client.chat.completions.create(
    model="gpt-5.2",  # ✅ 최신 Thinking
    messages=[...]
)

# GPT-5.2 Pro (최고 정확도)
response = client.chat.completions.create(
    model="gpt-5.2-pro",  # ✅ 최고 성능
    messages=[...]
)

# GPT-5.2 Instant (빠른 응답)
response = client.chat.completions.create(
    model="gpt-5.2-chat-latest",  # ✅ 속도 최적화
    messages=[...]
)

# GPT-5.1 with Codex-Max (장기 에이전트)
response = client.chat.completions.create(
    model="gpt-5.1-codex-max",  # ✅ 24시간+ 작업
    messages=[...]
)
```

### Anthropic Claude
```python
# Claude Opus 4.5 (최고 코딩 성능)
response = client.messages.create(
    model="claude-opus-4-5-20251101",  # ✅ SWE-bench 80.9%
    max_tokens=4096,
    messages=[...],
    # effort="medium"  # 선택: low/medium/high
)

# Claude Sonnet 4.5 (균형)
response = client.messages.create(
    model="claude-sonnet-4-5-20250929",  # ✅ 77.2%
    max_tokens=4096,
    messages=[...]
)

# Claude Haiku 4.5 (비용 효율)
response = client.messages.create(
    model="claude-haiku-4-5-20251015",  # ✅ $1/$5
    max_tokens=4096,
    messages=[...]
)

# Sonnet 4.5 with 1M 컨텍스트 (프리뷰)
response = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=4096,
    messages=[...],
    headers={"anthropic-beta": "context-1m-2025-10-01"}
)
```

### Google Gemini
```python
# Gemini 3 Pro (LMArena 1501 Elo)
model = genai.GenerativeModel(
    "gemini-3-pro",  # ✅ 최신
    generation_config={
        "temperature": 0.7,
    }
)

# Gemini 2.5 Flash-Lite (최저 비용)
model = genai.GenerativeModel(
    "gemini-2.5-flash-lite",  # ✅ $0.10/$0.40
    generation_config={
        "temperature": 0.7,
    }
)
```

## 🎯 상황별 모델 선택 가이드

### 프로덕션 코드 생성
- **추천**: Claude Opus 4.5 (SWE-bench 80.9%, 최고 성능)
- **대안**: Claude Sonnet 4.5 (77.2%, 더 저렴)
- **비용 중시**: Claude Haiku 4.5 (73.3%, $1/$5)

### 복잡한 추론/연구
- **추천**: Gemini 3 Deep Think (HLE 41%, ARC-AGI-2 45.1%)
- **대안**: GPT-5.2 Pro (GPQA 93.2%)

### 일상적인 코딩 작업
- **추천**: GPT-5.2 Thinking (빠르고 정확)
- **대안**: Claude Sonnet 4.5 (컴퓨터 사용 가능)

### 비용 민감한 프로젝트
- **최저가**: Gemini 2.5 Flash-Lite ($0.10/$0.40)
- **코딩 중시**: Claude Haiku 4.5 ($1/$5, 73.3%)

### 장기 실행 에이전트
- **추천**: GPT-5.1-Codex-Max (24시간+ 작업)
- **대안**: Claude Sonnet 4.5 (30시간 자율 실행)

### 멀티모달 (이미지/비전)
- **추천**: GPT-5.2, Gemini 3 Pro
- **대안**: Claude Sonnet 4.5

## ⚠️ 주의사항

1. **GPT-5/5.1/5.2 temperature 미지원**: verbosity/reasoning_effort 사용
2. **Claude Opus 4.5 effort 파라미터**: 토큰 사용량과 성능 트레이드오프 조절
3. **Gemini 3 Pro 가격**: 200K 토큰 경계에서 가격 변동
4. **Gemini 3 Flash 미출시**: 2026년 1-2월 예상
5. **Claude 모델명 형식**: 날짜 스냅샷 포함 (예: claude-opus-4-5-20251101)

## 📅 업데이트 로그
- 2025-12-11: GPT-5.2 출시 (Instant/Thinking/Pro)
- 2025-12-04: Gemini 3 Deep Think 출시
- 2025-11-24: Claude Opus 4.5 출시 (SWE-bench 80.9%)
- 2025-11-18: Gemini 3 Pro 출시 (LMArena 1501 Elo)
- 2025-11-12: GPT-5.1 출시 (적응형 추론)
- 2025-10-15: Claude Haiku 4.5 출시
- 2025-09-29: Claude Sonnet 4.5 출시 (77.2%)
- 2025-08-07: GPT-5 출시

## 🔗 공식 문서
- [OpenAI Models](https://platform.openai.com/docs/models)
- [Anthropic Models](https://docs.anthropic.com/en/docs/about-claude/models)
- [Google Gemini Models](https://ai.google.dev/gemini-api/docs/models)

## 📚 참고 출처
- [OpenAI GPT-5.2 공식 발표](https://openai.com/index/introducing-gpt-5-2/)
- [Anthropic Claude Opus 4.5 공식 발표](https://www.anthropic.com/news/claude-opus-4-5)
- [Google Gemini 3 공식 발표](https://blog.google/products/gemini/gemini-3/)
- [VentureBeat GPT-5.2 분석](https://venturebeat.com/ai/openais-gpt-5-2-is-here-what-enterprises-need-to-know)
- [Gemini 3 Deep Think 발표](https://blog.google/products/gemini/gemini-3-deep-think/)
