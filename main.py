#!/usr/bin/env python
"""
Start application in uvicorn.
"""
import sys
import click
import uvicorn
from app.main import app


@click.command()
@click.option(
    "--host",
    type=str,
    default="127.0.0.1",
    help="Bind socket to this IP address.",
    show_default=True,
)
@click.option(
    "--port",
    type=int,
    default=8000,
    help="Bind socket to this port.",
    show_default=True,
)
def main(host: str, port: int):
    "Run main app."
    return uvicorn.run(app, host=host, port=port)


if __name__ == "__main__":
    sys.exit(main())
