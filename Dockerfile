FROM python:3.9-bullseye as base

WORKDIR /code

COPY ./pyproject.toml ./poetry.lock* /code/

RUN pip install --no-cache-dir poetry \
    && poetry export --output requirements.txt --without-hashes

FROM python:3.9-bullseye

COPY --from=base /code/requirements.txt /app/requirements.txt

COPY main.py /app/
COPY ./app /app/app

RUN pip install --no-cache-dir --upgrade -r /app/requirements.txt \
    && python3 -m compileall /app

WORKDIR /app

ENTRYPOINT ["/app/main.py"]
CMD ["--host", "0.0.0.0", "--port", "80"]
