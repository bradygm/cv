FROM python:3.12-slim

# (optional) make builds reproducible & smaller
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# Install deps
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Default command (override as needed)
CMD ["python3", "generate.py", "cv.yaml"]