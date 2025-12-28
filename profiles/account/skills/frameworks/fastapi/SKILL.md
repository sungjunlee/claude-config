---
name: fastapi
description: |
  FastAPI framework expert for building modern async Python APIs.
  Use when: working on FastAPI projects, designing API endpoints,
  implementing async patterns, or integrating with SQLAlchemy.
  Triggers: "fastapi", "async api", "pydantic", "sqlalchemy async"
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
---

# FastAPI Expert Skill

FastAPI 기반 고성능 비동기 API 개발을 위한 전문 스킬입니다.

## Overview

FastAPI 프로젝트의 설계, 구현, 테스트, 최적화를 지원합니다.

## Capabilities

### 1. API Design
- RESTful 엔드포인트 설계
- OpenAPI 문서 자동 생성
- 버전 관리 전략 (v1, v2)

### 2. Async Optimization
- 동시성 최대화
- Connection pooling
- Background tasks

### 3. Data Validation
- Pydantic 모델 설계
- Request/Response 스키마
- Field validators

### 4. Testing Strategy
- Async testing with httpx
- pytest-asyncio 통합
- 인증 테스트 패턴

## Project Detection

| 파일 | 감지 조건 |
|------|-----------|
| `main.py` + `from fastapi` | FastAPI 프로젝트 |
| `requirements.txt` + `fastapi` | FastAPI 의존성 |
| `pyproject.toml` + `fastapi` | FastAPI 의존성 |

## Recommended Structure

```
app/
├── main.py           # FastAPI app instance
├── api/
│   ├── deps.py       # Dependencies
│   └── v1/
│       └── endpoints/
├── core/
│   ├── config.py     # Settings
│   ├── security.py   # Auth
│   └── database.py   # DB setup
├── models/           # SQLAlchemy models
├── schemas/          # Pydantic schemas
├── crud/             # CRUD operations
└── tests/
```

## Context Files

| 파일 | 용도 |
|------|------|
| `context/patterns.md` | FastAPI 패턴 및 코드 예제 |
| `context/async-sqlalchemy.md` | Async SQLAlchemy 가이드 |

## Primary Patterns

### Pydantic Schema Design
```python
from pydantic import BaseModel, Field, field_validator

class UserBase(BaseModel):
    email: str = Field(..., example="user@example.com")
    username: str = Field(..., min_length=3, max_length=50)

class UserCreate(UserBase):
    password: str = Field(..., min_length=8)

class UserResponse(UserBase):
    id: int
    created_at: datetime

    model_config = {"from_attributes": True}
```

### Dependency Injection
```python
from fastapi import Depends
from fastapi.security import OAuth2PasswordBearer

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db)
) -> User:
    # Token validation logic
    ...
```

### Async Endpoints
```python
@router.get("/", response_model=List[UserResponse])
async def get_users(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db)
):
    return await crud.user.get_multi(db, skip=skip, limit=limit)
```

## Best Practices

### Production Checklist
1. Environment variables for configuration
2. Rate limiting with slowapi
3. CORS middleware for browser requests
4. Alembic for database migrations
5. Health checks endpoint
6. Request ID for tracing
7. Structured logging with loguru
8. Prometheus metrics

### Performance Tips
- Connection pooling (SQLAlchemy, Redis)
- Response caching with fastapi-cache
- Background tasks for async operations
- Proper exception handling

## Error Handling

```python
from fastapi import Request
from fastapi.responses import JSONResponse

@app.exception_handler(ValueError)
async def value_error_handler(request: Request, exc: ValueError):
    return JSONResponse(
        status_code=400,
        content={"detail": str(exc)}
    )
```

## Testing Approach

```python
import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_create_user():
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.post(
            "/users/",
            json={"email": "test@example.com", "password": "secret123"}
        )
    assert response.status_code == 201
```

## Integration

### With Testing Skill
- `testing` skill의 `context/python.md`와 연동
- pytest-asyncio 설정 공유

### With Linting Skill
- ruff 설정 적용
- FastAPI import 순서 권장

## Output Format

FastAPI 코드 분석 시:
1. API 설계 및 구조 검토
2. Async 작업 최적화
3. Pydantic 스키마 개선
4. 에러 핸들링 강화
5. 테스트 전략 제안
6. 성능 개선 권장
