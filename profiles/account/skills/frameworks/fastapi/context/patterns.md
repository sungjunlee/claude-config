# FastAPI Patterns

FastAPI 프로젝트의 핵심 패턴과 코드 예제입니다.

## Pydantic Schema Design

### Base/Create/Response Pattern
```python
from pydantic import BaseModel, Field, field_validator
from typing import Optional
from datetime import datetime

class UserBase(BaseModel):
    """Base schema with common fields"""
    email: str = Field(..., example="user@example.com")
    username: str = Field(..., min_length=3, max_length=50)

class UserCreate(UserBase):
    """Schema for creating new user"""
    password: str = Field(..., min_length=8)

    @field_validator('password')
    @classmethod
    def validate_password(cls, v: str) -> str:
        if not any(c.isdigit() for c in v):
            raise ValueError('Password must contain at least one digit')
        return v

class UserInDB(UserBase):
    """Schema with DB-specific fields"""
    id: int
    created_at: datetime
    hashed_password: str

    model_config = {"from_attributes": True}

class UserResponse(UserBase):
    """Schema for API responses"""
    id: int
    created_at: datetime
```

### Optional Fields Pattern
```python
class UserUpdate(BaseModel):
    """Partial update schema"""
    email: Optional[str] = None
    username: Optional[str] = None

    model_config = {"extra": "forbid"}
```

## Endpoint Patterns

### Basic CRUD
```python
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List

router = APIRouter(prefix="/users", tags=["users"])

@router.get("/", response_model=List[UserResponse])
async def get_users(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db)
):
    """Get list of users with pagination"""
    users = await crud.user.get_multi(db, skip=skip, limit=limit)
    return users

@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: int,
    db: AsyncSession = Depends(get_db)
):
    """Get single user by ID"""
    user = await crud.user.get(db, id=user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    user_in: UserCreate,
    db: AsyncSession = Depends(get_db)
):
    """Create new user"""
    existing = await crud.user.get_by_email(db, email=user_in.email)
    if existing:
        raise HTTPException(status_code=400, detail="Email already exists")
    return await crud.user.create(db, obj_in=user_in)

@router.put("/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: int,
    user_in: UserUpdate,
    db: AsyncSession = Depends(get_db)
):
    """Update user"""
    user = await crud.user.get(db, id=user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return await crud.user.update(db, db_obj=user, obj_in=user_in)

@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(
    user_id: int,
    db: AsyncSession = Depends(get_db)
):
    """Delete user"""
    user = await crud.user.get(db, id=user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    await crud.user.remove(db, id=user_id)
```

## Dependency Injection

### Database Session
```python
from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

async def get_db():
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
```

### Authentication
```python
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db)
) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: int = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    user = await crud.user.get(db, id=user_id)
    if user is None:
        raise credentials_exception
    return user

async def get_current_active_user(
    current_user: User = Depends(get_current_user)
) -> User:
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user
```

### Permission Check
```python
def require_role(required_role: str):
    async def role_checker(
        current_user: User = Depends(get_current_active_user)
    ):
        if current_user.role != required_role:
            raise HTTPException(
                status_code=403,
                detail="Insufficient permissions"
            )
        return current_user
    return role_checker

# Usage
@router.delete("/{user_id}")
async def delete_user(
    user_id: int,
    admin: User = Depends(require_role("admin"))
):
    ...
```

## Background Tasks

```python
from fastapi import BackgroundTasks
import asyncio

async def send_email_async(email: str, subject: str):
    await asyncio.sleep(1)  # Simulate async operation
    print(f"Email sent to {email}")

@router.post("/send-notification")
async def send_notification(
    email: str,
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_active_user)
):
    background_tasks.add_task(
        send_email_async,
        email,
        f"Notification for {current_user.username}"
    )
    return {"message": "Notification sent in background"}
```

## WebSocket Support

```python
from fastapi import WebSocket, WebSocketDisconnect
from typing import Dict

class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, WebSocket] = {}

    async def connect(self, websocket: WebSocket, client_id: str):
        await websocket.accept()
        self.active_connections[client_id] = websocket

    async def disconnect(self, client_id: str):
        del self.active_connections[client_id]

    async def broadcast(self, message: str):
        for connection in self.active_connections.values():
            await connection.send_text(message)

manager = ConnectionManager()

@app.websocket("/ws/{client_id}")
async def websocket_endpoint(websocket: WebSocket, client_id: str):
    await manager.connect(websocket, client_id)
    try:
        while True:
            data = await websocket.receive_text()
            await manager.broadcast(f"Client {client_id}: {data}")
    except WebSocketDisconnect:
        await manager.disconnect(client_id)
```

## Error Handling

### Custom Exception Handlers
```python
from fastapi import Request
from fastapi.responses import JSONResponse

class CustomException(Exception):
    def __init__(self, name: str, detail: str):
        self.name = name
        self.detail = detail

@app.exception_handler(CustomException)
async def custom_exception_handler(request: Request, exc: CustomException):
    return JSONResponse(
        status_code=400,
        content={"error": exc.name, "detail": exc.detail}
    )

@app.exception_handler(ValueError)
async def value_error_handler(request: Request, exc: ValueError):
    return JSONResponse(
        status_code=400,
        content={"detail": str(exc)}
    )
```

### Validation Error Customization
```python
from fastapi.exceptions import RequestValidationError

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    return JSONResponse(
        status_code=422,
        content={
            "detail": exc.errors(),
            "body": exc.body
        }
    )
```

## Testing Patterns

### Basic Async Test
```python
import pytest
from httpx import AsyncClient
from app.main import app

@pytest.mark.asyncio
async def test_create_user():
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.post(
            "/users/",
            json={"email": "test@example.com", "password": "secret123"}
        )
    assert response.status_code == 201
    assert response.json()["email"] == "test@example.com"
```

### Authenticated Test
```python
@pytest.fixture
async def auth_client():
    async with AsyncClient(app=app, base_url="http://test") as client:
        login_response = await client.post(
            "/token",
            data={"username": "test", "password": "test"}
        )
        token = login_response.json()["access_token"]
        client.headers["Authorization"] = f"Bearer {token}"
        yield client

@pytest.mark.asyncio
async def test_protected_endpoint(auth_client):
    response = await auth_client.get("/protected")
    assert response.status_code == 200
```

### Database Test Fixture
```python
@pytest.fixture
async def db_session():
    async with AsyncSessionLocal() as session:
        yield session
        await session.rollback()

@pytest.mark.asyncio
async def test_create_user_db(db_session):
    user = User(email="test@example.com")
    db_session.add(user)
    await db_session.commit()

    result = await db_session.execute(
        select(User).where(User.email == "test@example.com")
    )
    assert result.scalar_one_or_none() is not None
```

## Performance Patterns

### Response Caching
```python
from contextlib import asynccontextmanager
from fastapi_cache import FastAPICache
from fastapi_cache.decorator import cache
from fastapi_cache.backends.redis import RedisBackend
import redis.asyncio as aioredis

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    redis_client = aioredis.from_url("redis://localhost")
    FastAPICache.init(RedisBackend(redis_client), prefix="api-cache")
    yield
    # Shutdown
    await redis_client.close()

app = FastAPI(lifespan=lifespan)

@router.get("/expensive")
@cache(expire=60)
async def expensive_operation():
    await asyncio.sleep(5)  # Expensive computation
    return {"result": "computed"}
```

### Rate Limiting
```python
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter

@router.get("/limited")
@limiter.limit("5/minute")
async def limited_endpoint(request: Request):
    return {"message": "This endpoint is rate limited"}
```
