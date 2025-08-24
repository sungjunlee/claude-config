# Latest LLM Models Reference (2025-08)

최신 LLM 모델 정보 - API 사용 시 구형 모델 대신 아래 최신 모델을 사용하세요.
*마지막 업데이트: 2025년 8월 24일*

## 🔥 주요 플레이어 최신 모델

### OpenAI (2025년 8월 기준)

**최신 모델:**
- `gpt-5` / `gpt-5-mini` / `gpt-5-nano` - 2025년 8월 7일 출시
  - ⚠️ **중요**: temperature 파라미터 지원 안함 (기본값 1만 사용)
  - 새로운 파라미터: `verbosity` (low/medium/high), `reasoning_effort` (minimal/low/medium/high)
  - 272K 입력 토큰, 128K 출력 토큰
  - 코딩 벤치마크: SWE-bench 74.9%, Aider 88%
  
- `gpt-4.1` / `gpt-4.1-mini` / `gpt-4.1-nano` - 2025년 4월 출시, 프로그래밍 특화
  - 1M 토큰 컨텍스트, 2024년 6월까지 학습
  - SWE-bench 52-54.6% (GPT-4o 대비 21.4% 개선)
  - temperature 파라미터 정상 지원

**구형 모델 (사용 지양):**
- ❌ `gpt-4o`, `gpt-4o-mini` (GPT-4.1로 대체)
- ❌ `gpt-4-turbo-preview`
- ❌ `gpt-3.5-turbo`

### Anthropic (2025년 8월 기준)

**최신 모델:**
- `claude-opus-4-1-20250805` - 2025년 8월 5일 출시
  - SWE-bench 74.5%, 에이전틱 태스크 최적화
  - 멀티파일 코드 리팩토링 특화
  - Opus 4 대비 1 표준편차 성능 향상
  
- `claude-sonnet-4-20250522` - 2025년 5월 출시
  - SWE-bench 72.7%, 코딩 최고 성능
  - 1M 토큰 컨텍스트 (베타 헤더 필요)
  - 하이브리드 모델: 즉시 응답 / 딥 추론 모드
  
- `claude-opus-4-20250522` - 2025년 5월 출시
  - 복잡한 장기 실행 작업 최적화
  - Terminal-bench 43.2%

**구형 모델 (사용 지양):**
- ❌ `claude-3-5-sonnet` (Sonnet 4로 대체)
- ❌ `claude-3-opus` (2026년 1월 퇴역 예정)
- ❌ `claude-2.1`

### Google (2025년 8월 기준)

**최신 모델:**
- `gemini-2.5-pro` - 2025년 8월 안정화 버전
  - Thinking 모델, 수학/과학 벤치마크 선도
  - GPQA/AIME 2025 최고 점수
  - thinking_budget 제어 가능
  
- `gemini-2.5-flash` - 2025년 8월 출시
  - 가격-성능 균형, thinking 기능 포함
  - 적응형 추론 지원
  
- `gemini-2.5-flash-lite` - 2025년 8월 15일 안정화
  - 최저 비용: $0.10/1M 입력, $0.40/1M 출력
  - 가장 빠른 응답 속도

**구형 모델 (사용 지양):**
- ❌ `gemini-2.0-flash`, `gemini-2.0-pro`
- ❌ `gemini-1.5-pro`, `gemini-1.5-flash`

## 💰 비용-성능 권장사항

### 코딩 작업
1. **최고 성능**: GPT-5 (SWE-bench 74.9%), Claude Opus 4.1 (74.5%)
2. **프로그래밍 특화**: GPT-4.1 (안정성 + temperature 지원)
3. **비용 효율**: GPT-4.1-mini, Claude Sonnet 4

### 장문 컨텍스트 (문서 분석)
1. **최고 성능**: Claude Sonnet 4 (1M 토큰)
2. **균형**: GPT-4.1 (1M 토큰)
3. **비용 효율**: Gemini 2.5 Flash-Lite

### 추론/수학 문제
1. **최고 성능**: Gemini 2.5 Pro (AIME 2025 최고)
2. **빠른 추론**: GPT-5 reasoning_effort="minimal"
3. **균형**: Claude Opus 4.1

## ⚡ API 사용 예시

### OpenAI GPT-5 (temperature 없음!)
```python
# GPT-5는 temperature 지원 안함
response = client.chat.completions.create(
    model="gpt-5",  # ✅ 최신
    # temperature=0.7,  # ❌ 에러 발생!
    verbosity="medium",  # 새로운 파라미터
    reasoning_effort="high",  # 새로운 파라미터
    messages=[...]
)

# GPT-4.1은 기존 방식 지원
response = client.chat.completions.create(
    model="gpt-4.1",  # ✅ 프로그래밍 특화
    temperature=0.7,  # ✅ 정상 작동
    messages=[...]
)
```

### Anthropic Claude
```python
# Claude Opus 4.1 (최신)
response = client.messages.create(
    model="claude-opus-4-1-20250805",  # ✅ 최신
    # model="claude-3-5-sonnet",  # ❌ 구형
    max_tokens=4096,
    messages=[...]
)

# Claude Sonnet 4 (1M 컨텍스트)
response = client.messages.create(
    model="claude-sonnet-4-20250522",
    max_tokens=4096,
    messages=[...],
    headers={"context-1m-2025-08-07": "true"}  # 1M 토큰 활성화
)
```

### Google Gemini
```python
# Gemini 2.5 (Thinking 모델)
model = genai.GenerativeModel(
    "gemini-2.5-pro",  # ✅ 최신
    # "gemini-2.0-flash",  # ❌ 구형
    generation_config={
        "thinking_budget": "high",  # Thinking 제어
        "temperature": 0.7,
    }
)
```

## 🎯 상황별 모델 선택 가이드

### 프로덕션 코드 생성
- **추천**: GPT-4.1 (안정성, temperature 지원, 프로그래밍 특화)
- **대안**: Claude Opus 4.1 (멀티파일 리팩토링 강점)

### 실험적/최신 기능
- **추천**: GPT-5 (최신 기능, verbosity/reasoning_effort)
- **주의**: API 호환성 변경 가능성

### 비용 민감한 프로젝트
- **추천**: Gemini 2.5 Flash-Lite ($0.10/1M)
- **대안**: GPT-4.1-nano, GPT-5-nano

### 장기 실행 에이전트
- **추천**: Claude Opus 4 (장기 작업 최적화)
- **대안**: GPT-5 reasoning_effort="high"

## ⚠️ 주의사항

1. **GPT-5 temperature 미지원**: 기존 코드 마이그레이션 시 주의
2. **Claude 모델명 형식**: 날짜 스냅샷 포함 (예: -20250805)
3. **Gemini thinking_budget**: 응답 시간과 품질 트레이드오프

## 📅 업데이트 로그
- 2025-08-07: GPT-5 출시, temperature 파라미터 제거
- 2025-08-05: Claude Opus 4.1 출시
- 2025-08-15: Gemini 2.5 Flash-Lite 안정화
- 2025-04-14: GPT-4.1 프로그래밍 특화 모델 출시

## 🔗 공식 문서
- [OpenAI Models](https://platform.openai.com/docs/models)
- [Anthropic Models](https://docs.anthropic.com/en/docs/about-claude/models)
- [Google Gemini Models](https://ai.google.dev/gemini-api/docs/models)