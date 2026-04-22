FROM python:3.12-bullseye as base

# use uv to manage dependencies rather than poetry
WORKDIR /app

# copy project metadata and lockfile
COPY ./pyproject.toml ./uv.lock* ./

RUN pip install --no-cache-dir uv \
    && uv sync --locked --no-install-project --no-dev

# application sources
COPY main.py ./
COPY ./app ./app

# compile bytecode inside uv environment
RUN uv run python3 -m compileall /app

FROM python:3.12-bullseye

# bring over the prepared app tree (including .venv)
COPY --from=base /app /app

WORKDIR /app

ENTRYPOINT ["/app/main.py"]
CMD ["--host", "0.0.0.0", "--port", "80"]
