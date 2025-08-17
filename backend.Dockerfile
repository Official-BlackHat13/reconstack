FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system deps
RUN apt-get update && apt-get install -y \
    git curl bash && \
    rm -rf /var/lib/apt/lists/*

# Install Python deps
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app
COPY backend/ .

# Expose backend port
EXPOSE 5000

# Run API
CMD ["python", "app.py"]
