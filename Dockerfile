# Use Python 3.11 slim base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies (git for GitPython)
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend code
COPY backend.py ./backend.py

# Copy frontend assets
COPY templates ./templates
COPY static ./static

# Copy any other necessary project files
COPY . .

# Expose Flask/Gunicorn port
EXPOSE 5000

# Start Gunicorn, pointing to `app` inside backend.py
CMD ["gunicorn", "-b", "0.0.0.0:5000", "backend:app"]
