# Async SQLAlchemy Guide

FastAPI와 함께 사용하는 Async SQLAlchemy 가이드입니다.

## Database Setup

### Engine Configuration
```python
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from sqlalchemy.orm import DeclarativeBase

DATABASE_URL = "postgresql+asyncpg://user:pass@localhost/db"

engine = create_async_engine(
    DATABASE_URL,
    echo=True,           # SQL logging
    pool_pre_ping=True,  # Connection health check
    pool_size=10,        # Connection pool size
    max_overflow=20      # Extra connections when pool full
)

AsyncSessionLocal = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False
)

class Base(DeclarativeBase):
    pass
```

### Session Dependency
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

## Model Definition

### Basic Model
```python
from sqlalchemy import String, Text, ForeignKey, Table, Column, Integer
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.sql import func
from datetime import datetime
from typing import Optional

class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    username: Mapped[str] = mapped_column(String(50), unique=True, index=True)
    hashed_password: Mapped[str] = mapped_column(String(255))
    is_active: Mapped[bool] = mapped_column(default=True)
    created_at: Mapped[datetime] = mapped_column(server_default=func.now())
    updated_at: Mapped[Optional[datetime]] = mapped_column(onupdate=func.now())

    # Relationships
    posts: Mapped[list["Post"]] = relationship(back_populates="author", lazy="selectin")
```

### Relationship Pattern
```python
class Post(Base):
    __tablename__ = "posts"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    title: Mapped[str] = mapped_column(String(255))
    content: Mapped[Optional[str]] = mapped_column(Text)
    author_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    created_at: Mapped[datetime] = mapped_column(server_default=func.now())

    # Relationship
    author: Mapped["User"] = relationship(back_populates="posts")
    tags: Mapped[list["Tag"]] = relationship(secondary="post_tags", back_populates="posts")

# Many-to-Many junction table
post_tags = Table(
    "post_tags",
    Base.metadata,
    Column("post_id", Integer, ForeignKey("posts.id"), primary_key=True),
    Column("tag_id", Integer, ForeignKey("tags.id"), primary_key=True)
)

class Tag(Base):
    __tablename__ = "tags"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String(50), unique=True)

    posts: Mapped[list["Post"]] = relationship(secondary="post_tags", back_populates="tags")
```

## CRUD Operations

### Generic CRUD Base
```python
from typing import TypeVar, Generic, Type, Optional, List
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel

ModelType = TypeVar("ModelType", bound=Base)
CreateSchemaType = TypeVar("CreateSchemaType", bound=BaseModel)
UpdateSchemaType = TypeVar("UpdateSchemaType", bound=BaseModel)

class CRUDBase(Generic[ModelType, CreateSchemaType, UpdateSchemaType]):
    def __init__(self, model: Type[ModelType]):
        self.model = model

    async def get(self, db: AsyncSession, id: int) -> Optional[ModelType]:
        result = await db.execute(
            select(self.model).where(self.model.id == id)
        )
        return result.scalar_one_or_none()

    async def get_multi(
        self, db: AsyncSession, *, skip: int = 0, limit: int = 100
    ) -> List[ModelType]:
        result = await db.execute(
            select(self.model).offset(skip).limit(limit)
        )
        return result.scalars().all()

    async def create(
        self, db: AsyncSession, *, obj_in: CreateSchemaType
    ) -> ModelType:
        db_obj = self.model(**obj_in.model_dump())
        db.add(db_obj)
        await db.commit()
        await db.refresh(db_obj)
        return db_obj

    async def update(
        self, db: AsyncSession, *, db_obj: ModelType, obj_in: UpdateSchemaType
    ) -> ModelType:
        update_data = obj_in.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_obj, field, value)
        db.add(db_obj)
        await db.commit()
        await db.refresh(db_obj)
        return db_obj

    async def remove(self, db: AsyncSession, *, id: int) -> ModelType:
        obj = await self.get(db, id=id)
        await db.delete(obj)
        await db.commit()
        return obj
```

### Specialized CRUD
```python
class CRUDUser(CRUDBase[User, UserCreate, UserUpdate]):
    async def get_by_email(
        self, db: AsyncSession, *, email: str
    ) -> Optional[User]:
        result = await db.execute(
            select(User).where(User.email == email)
        )
        return result.scalar_one_or_none()

    async def create(
        self, db: AsyncSession, *, obj_in: UserCreate
    ) -> User:
        db_obj = User(
            email=obj_in.email,
            username=obj_in.username,
            hashed_password=get_password_hash(obj_in.password)
        )
        db.add(db_obj)
        await db.commit()
        await db.refresh(db_obj)
        return db_obj

    async def authenticate(
        self, db: AsyncSession, *, email: str, password: str
    ) -> Optional[User]:
        user = await self.get_by_email(db, email=email)
        if not user:
            return None
        if not verify_password(password, user.hashed_password):
            return None
        return user

user = CRUDUser(User)
```

## Query Patterns

### Basic Queries
```python
from sqlalchemy import select, and_, or_, desc

# Simple select
result = await db.execute(select(User))
users = result.scalars().all()

# With conditions
result = await db.execute(
    select(User).where(User.is_active == True)
)

# Multiple conditions
result = await db.execute(
    select(User).where(
        and_(
            User.is_active == True,
            User.created_at >= datetime(2024, 1, 1)
        )
    )
)

# Ordering
result = await db.execute(
    select(User).order_by(desc(User.created_at))
)

# Pagination
result = await db.execute(
    select(User).offset(10).limit(20)
)
```

### Relationship Loading
```python
from sqlalchemy.orm import selectinload, joinedload

# Eager loading with selectinload (preferred for collections)
result = await db.execute(
    select(User).options(selectinload(User.posts))
)
users = result.scalars().unique().all()

# Eager loading with joinedload (preferred for single items)
result = await db.execute(
    select(Post).options(joinedload(Post.author))
)
posts = result.scalars().unique().all()

# Nested loading
result = await db.execute(
    select(User).options(
        selectinload(User.posts).selectinload(Post.tags)
    )
)
```

### Aggregation
```python
from sqlalchemy import func

# Count
result = await db.execute(
    select(func.count(User.id))
)
count = result.scalar()

# Group by
result = await db.execute(
    select(User.role, func.count(User.id))
    .group_by(User.role)
)
role_counts = result.all()
```

## Transaction Patterns

### Explicit Transaction
```python
async def transfer_funds(
    db: AsyncSession,
    from_id: int,
    to_id: int,
    amount: float
):
    async with db.begin():
        from_account = await db.get(Account, from_id)
        to_account = await db.get(Account, to_id)

        if from_account.balance < amount:
            raise ValueError("Insufficient funds")

        from_account.balance -= amount
        to_account.balance += amount
        # Commit happens automatically on context exit
```

### Savepoints
```python
async def complex_operation(db: AsyncSession):
    async with db.begin_nested() as savepoint:
        try:
            # Do something
            await create_user(db, user_data)
        except Exception:
            await savepoint.rollback()
            # Handle error
```

## Migration with Alembic

### alembic.ini (async)
```ini
[alembic]
script_location = alembic
sqlalchemy.url = postgresql+asyncpg://user:pass@localhost/db
```

### env.py (async)
```python
import asyncio
from sqlalchemy.ext.asyncio import create_async_engine

def run_migrations_offline():
    context.configure(
        url=config.get_main_option("sqlalchemy.url"),
        target_metadata=target_metadata,
        literal_binds=True,
    )
    with context.begin_transaction():
        context.run_migrations()

def do_run_migrations(connection):
    context.configure(connection=connection, target_metadata=target_metadata)
    with context.begin_transaction():
        context.run_migrations()

async def run_migrations_online():
    connectable = create_async_engine(
        config.get_main_option("sqlalchemy.url")
    )
    async with connectable.connect() as connection:
        await connection.run_sync(do_run_migrations)
    await connectable.dispose()

if context.is_offline_mode():
    run_migrations_offline()
else:
    asyncio.run(run_migrations_online())
```

### Migration Commands
```bash
# Create migration
alembic revision --autogenerate -m "Add user table"

# Apply migrations
alembic upgrade head

# Rollback
alembic downgrade -1
```

## Performance Tips

### Connection Pool Tuning
```python
engine = create_async_engine(
    DATABASE_URL,
    pool_size=20,           # Base pool size
    max_overflow=10,        # Extra connections
    pool_timeout=30,        # Wait time for connection
    pool_recycle=1800,      # Recycle connections after 30 min
    pool_pre_ping=True      # Check connection health
)
```

### Bulk Operations
```python
# Bulk insert
from sqlalchemy import insert

async def bulk_create_users(db: AsyncSession, users: List[UserCreate]):
    await db.execute(
        insert(User),
        [user.model_dump() for user in users]
    )
    await db.commit()

# Bulk update
from sqlalchemy import update

async def deactivate_old_users(db: AsyncSession, days: int):
    cutoff = datetime.utcnow() - timedelta(days=days)
    await db.execute(
        update(User)
        .where(User.last_login < cutoff)
        .values(is_active=False)
    )
    await db.commit()
```

### Indexing
```python
from sqlalchemy import Index

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    email = Column(String(255), unique=True, index=True)
    username = Column(String(50), index=True)
    created_at = Column(DateTime)

    __table_args__ = (
        Index('idx_user_created', 'created_at', postgresql_using='btree'),
        Index('idx_user_email_username', 'email', 'username'),
    )
```

## Testing

### Test Database Setup
```python
import pytest
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker

TEST_DATABASE_URL = "postgresql+asyncpg://user:pass@localhost/test_db"

@pytest.fixture
async def test_engine():
    engine = create_async_engine(TEST_DATABASE_URL, echo=True)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield engine
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

@pytest.fixture
async def db_session(test_engine):
    async_session = sessionmaker(
        test_engine, class_=AsyncSession, expire_on_commit=False
    )
    async with async_session() as session:
        yield session
        await session.rollback()
```

### Test Example
```python
@pytest.mark.asyncio
async def test_create_user(db_session):
    user_crud = CRUDUser(User)
    user_in = UserCreate(
        email="test@example.com",
        username="testuser",
        password="password123"
    )

    user = await user_crud.create(db_session, obj_in=user_in)

    assert user.email == "test@example.com"
    assert user.id is not None
```
