# Copilot Instructions for Python Docker Images

## Project Overview
This is a research/demonstration project comparing container image size reduction techniques for a FastAPI Python application. It builds the same simple REST API using multiple containerization approaches (Docker/Podman compatible), measuring the trade-offs between image size, build complexity, and functionality.

## Architecture & Variants
The project tests 5+ image building strategies:

1. **Regular** (`Dockerfile`) - Full Python 3.9-bullseye base (914MB)
2. **Slim** (`Dockerfile.slim`) - Python 3.9-slim-bullseye base (125MB)
3. **Nuitka** (`Dockerfile.nuitka`) - Python compiler to C code approach
4. **cx_Freeze** (`Dockerfile.freeze`) - Python bytecode + dependency bundling
5. **PyInstaller** (`Dockerfile.pyinstaller`) - Most aggressive: standalone binary (40.5MB final)
6. **BuildPacks** (`Dockerfile` + `pack` CLI) - Cloud-native approach via Paketo

Each Dockerfile uses a **multi-stage build pattern**:
- Stage 1: Install **uv**, sync dependencies (dependency isolation)
- Stage 2+: Build application artifacts (compile, strip binaries, copy libs)
- Final: Minimal distroless or slim base with only runtime artifacts

## Key Development Workflows

### Build and Test Images
All builds use `mise` (task runner defined in `mise.toml`). For each variant, there are three tasks:
```
mise run <variant>-image    # Build the container image (podman/docker compatible)
mise run <variant>-shell    # Start container with bash shell for debugging
mise run <variant>-dev      # Start container running the server (port 80)
mise run all                # Build all 5+ variants
mise run clean              # Remove __pycache__ before builds (auto-run as dependency)
mise tasks                  # List all available tasks
```

**Examples:**
```bash
mise run image             # Build regular image
mise run image-slim        # Build slim image
mise run pyinstaller-image # Build PyInstaller variant
mise run nuitka-shell      # Debug Nuitka build interactively
```

### Important: Auto-Clean on Build
The `clean` task is automatically executed as a dependency before each image build task (via `depends = ["clean"]` in `mise.toml`). This removes `__pycache__` directories to ensure fresh `.pyc` bytecode compilation in Dockerfiles.

## Application Code Structure

- **Entry point**: `main.py` - Uvicorn wrapper with Click CLI for --host/--port config
- **FastAPI app**: `app/main.py` - Simple 3-endpoint REST API:
  - `GET /` - Returns `{"Hello": "World"}`
  - `GET /items/{item_id}?q=...` - Returns item with query param
  - `PUT /items/{item_id}` - Updates item (requires JSON body with `Item` model)
- **Models**: Pydantic `BaseModel` subclass for type validation
- **Dependencies**: FastAPI, uvicorn, click (defined in `pyproject.toml`)

## Build Patterns & Conventions

### Dependency Management
- **pyproject.toml** defines minimal deps: `fastapi`, `uvicorn`, `click`
- **uv** syncs dependencies from `uv.lock` in build stage for reproducible installs
- Lock file (`uv.lock`) is required and tracked alongside pyproject
- Dev dependencies are excluded from the sync command
- Environment variable `IMAGE` is defined in `mise.toml` for all tasks

### Multi-Stage Build Strategy
1. **Dependency Stage**: Install uv, sync locked dependencies, discard uv binary
2. **Compilation Stage** (variant-specific): Apply tool (PyInstaller, Nuitka, etc.)
3. **Final Stage**: Minimal base image + only essential artifacts

Key optimization techniques across variants:
- `--strip` flag (removes debug symbols)
- `patchelf` (fixes shared library paths for PyInstaller)
- Remove duplicate system libs already in base image
- Bytecode compilation with `python3 -m compileall`
- Google distroless base (20.3MB) vs Debian slim (80.4MB)

### Image Size Targets
Reference final sizes from README (target for comparisons):
- PyInstaller: 40.5MB (smallest)
- cx_Freeze: 43.1MB
- Nuitka: 54.3MB
- Slim: 179MB
- Regular: 968MB
- BuildPacks: 382MB

## Common Modifications

When adding features or adjusting Dockerfiles:
- **Add dependencies**: Update `pyproject.toml` dependencies list
- **Modify app**: Edit `app/main.py` (FastAPI handlers) or `main.py` (CLI config)
- **Test specific variant**: Use `make <variant>-shell` before committing
- **Check image size**: After building, compare with `docker images` output
- **Port mappings**: Server runs on port 80 inside containers (maps via `-p 80:80`)
- **Entrypoint**: Most variants use `/app/main.py` with `--host 0.0.0.0 --port 80`

## Testing & Debugging
- **Interactive debugging**: `mise run <variant>-shell` starts bash inside built image
- **Live server**: `mise run <variant>-dev` runs FastAPI on localhost:80
- **API testing**: curl to `http://localhost/items/42?q=test` after starting server
- **Python version**: Project currently targets Python 3.12 in `pyproject.toml` but Dockerfiles still use 3.9 (intentional legacy test)

## External Dependencies
- **Podman/Docker** - Required for all builds (commands in `mise.toml` use podman by default)
- **uv** - Declared via `uv.lock` for dependency management
- **Paketo BuildPacks** - For BuildPacks variant (auto-downloads via `./pack`)
- **PyInstaller/Nuitka/cx_Freeze** - Installed in respective Dockerfile stages
- **UPX** - Optional compression utility (referenced in TODO, not yet implemented)

## Project TODOs
Referenced in README—inform implementation decisions:
- Compile Python to bytecode and remove `.py` source files
- Test Cython compilation
- Test PyOxydizer (Rust-based alternative)
- Experiment with Python `-O` and `-OO` flags
- Add UPX compression everywhere

## Notes for Contributors
- This is a research/comparison project—focus on **size reduction** and **build technique clarity**
- Each Dockerfile is intentionally different to demonstrate variant approaches
- Maintain the three-tier testing model: build → shell (debug) → serve (run)
- Keep the demo app simple—complexity testing belongs in separate projects
