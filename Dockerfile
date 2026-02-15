FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Prevent Python from writing .pyc files & enable unbuffered logs
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Environment variables for Flask (optional but useful)
ENV FLASK_ENV=production \
    PYTHONPATH=/app

# Install minimal build tools (for dependencies needing compilation)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency list first (better Docker layer caching)
COPY requirements.txt .

# Install dependencies (ensure gunicorn is included)
RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir gunicorn

# Copy application source code
COPY . .

# Create non-root user for security
RUN useradd -m appuser
USER appuser

# Expose Flask port
EXPOSE 8000

# Run using Gunicorn (production WSGI server)
# Replace "app:app" if your Flask file/app name is different
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]
