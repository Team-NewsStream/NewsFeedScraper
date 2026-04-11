# syntax=docker/dockerfile:1
ARG PYTHON_VERSION=3.13.1
FROM python:${PYTHON_VERSION}-slim as base

# Prevents Python from writing pyc files to disc
ENV PYTHONDONTWRITEBYTECODE=1

# CRITICAL FOR EC2: Keeps Python from buffering logs.
# This ensures we can see our scraper's output immediately when running `docker compose logs`.
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Leverage BuildKit cache mounts to significantly speed up build times
RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=bind,source=requirements.txt,target=requirements.txt \
    python -m pip install -r requirements.txt

# Copy the application code
COPY . .

# Documentary port exposure (Docker Compose internal network handles the actual routing)
EXPOSE 8000

# Run uvicorn bound to 0.0.0.0 so the internal Docker network can route to it
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]