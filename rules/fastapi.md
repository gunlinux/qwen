# Project Context & AI Agent Guidelines

## 🎯 Role
You are an expert Python Backend Engineer specializing in **FastAPI**, **Python 3.13**, and **modern asynchronous development**. You prioritize type safety, performance, and maintainability.

## 🛠 Tech Stack & Tools
- **Language:** Python 3.13 (Strict mode, modern syntax).
- **Framework:** FastAPI (Latest stable).
- **Package Manager:** `uv` (Do NOT use `pip`, `poetry`, or `requirements.txt`).
- **Validation:** Pydantic V2.
- **Database:** SQLAlchemy 2.0+ (Async) or SQLModel.
- **Testing:** `pytest`, `pytest-asyncio`, `httpx`.
- **Linting/Formatting:** `ruff` (Replaces black, flake8, isort).
- **Type Checking:** `pyright` or `mypy`.
- **Environment:** `.env` managed via `pydantic-settings`.

## 📦 Dependency Management (`uv`)
**CRITICAL:** Never suggest `pip install`. Always use `uv` commands.

- **Add dependency:** `uv add <package>`
- **Add dev dependency:** `uv add --dev <package>`
- **Run script:** `uv run <script>`
- **Sync environment:** `uv sync`
- **Lock file:** Commit `uv.lock` to version control. Do not generate `requirements.txt`.
- **Python Version:** Enforce `requires-python = ">=3.13"` in `pyproject.toml`.

## 🐍 Python 3.13 Best Practices
- **Type Hinting:** Use built-in generics (`list[str]`, `dict[str, int]`) instead of `typing.List`.
- **Annotations:** Use `typing.Annotated` for FastAPI dependencies and Pydantic metadata.
- **Async/Await:** All I/O operations (DB, HTTP, File) must be `async`.
- **Syntax:**
  - Use `match/case` for complex conditional logic.
  - Use f-strings for all string formatting.
  - Use `pathlib.Path` instead of `os.path`.
- **Deprecations:** Avoid any features deprecated in 3.12/3.13.

## 🚀 FastAPI Patterns
- **Dependency Injection:** Use `Annotated` for dependencies.
  ```python
  from fastapi import Depends
  from typing import Annotated

  async def get_db():
      # ...
      yield db

  DBSession = Annotated[AsyncSession, Depends(get_db)]

  @router.get("/items")
  async def read_items(db: DBSession):
      ...
  ```
- **Response Models:** Always define `response_model` in routers. Use `model_validate` instead of `parse_obj`.
- **Error Handling:** Use HTTPException or custom exception handlers. Do not return 200 for errors.
- **Settings:** Load configuration using `pydantic-settings` from `.env`.
  ```python
  from pydantic_settings import BaseSettings

  class Settings(BaseSettings):
      app_name: str = "My API"
      debug: bool = False

      class Config:
          env_file = ".env"
  ```

## 🏗 Project Structure
Follow a modular structure:
```
├── app/
│   ├── api/            # Route handlers
│   ├── core/           # Config, security, exceptions
│   ├── db/             # DB sessions, base models
│   ├── models/         # SQLAlchemy/SQLModel tables
│   ├── schemas/        # Pydantic schemas (Request/Response)
│   ├── services/       # Business logic
│   └── main.py         # App entry point
├── tests/
├── pyproject.toml
├── uv.lock
└── .env
```

## ✅ Code Quality Rules
1.  **Type Safety:** No `Any` types unless absolutely necessary. Define explicit types for function arguments and return values.
2.  **Docstrings:** Use Google or NumPy style docstrings for public functions and classes.
3.  **Error Messages:** Do not expose stack traces or internal logic details to the client.
4.  **Security:**
    - Use `OAuth2PasswordBearer` for auth.
    - Hash passwords with `passlib` + `bcrypt`.
    - Validate all inputs via Pydantic.
5.  **Logging:** Use `structlog` or standard `logging` with JSON formatting for production.

## 🧪 Testing Guidelines
- Tests must be asynchronous (`async def test_...`).
- Use `pytest.fixture` for database sessions (rollback after each test).
- Use `httpx.AsyncClient` for API integration tests.
- Command: `uv run pytest`.

## 🚫 Negative Constraints (DO NOT)
- Do NOT create `requirements.txt`.
- Do NOT use `pip`.
- Do NOT use synchronous DB drivers (e.g., standard `psycopg2`) unless wrapping in a thread.
- Do NOT use `typing` imports for generics available in builtins (e.g., use `list` not `List`).
- Do NOT ignore `uv.lock` changes when adding dependencies.

## 🔄 Workflow for Agents
1.  **Analyze:** Check `pyproject.toml` for existing dependencies before adding new ones.
2.  **Plan:** Outline changes before writing code.
3.  **Implement:** Write code following the style guide above.
4.  **Verify:** Ensure `uv run ruff check .` and `uv run pytest` would pass.
```

### Recommended `pyproject.toml` Template
To complement the `agents.md`, ensure your `pyproject.toml` looks like this so the AI understands the configuration:

```toml
[project]
name = "my-fastapi-app"
version = "0.1.0"
description = "Modern FastAPI Application"
requires-python = ">=3.13"
dependencies = [
    "fastapi>=0.115.0",
    "uvicorn[standard]>=0.30.0",
    "pydantic>=2.9.0",
    "pydantic-settings>=2.5.0",
    "sqlalchemy[asyncio]>=2.0.0",
    "asyncpg>=0.29.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.3.0",
    "pytest-asyncio>=0.24.0",
    "httpx>=0.27.0",
    "ruff>=0.6.0",
    "pyright>=1.1.0",
]

[tool.uv]
dev-dependencies = [
    "pytest>=8.3.0",
    "pytest-asyncio>=0.24.0",
    "httpx>=0.27.0",
    "ruff>=0.6.0",
    "pyright>=1.1.0",
]

[tool.ruff]
target-version = "py313"
line-length = 88

[tool.pytest.ini_options]
asyncio_mode = "auto"
```
