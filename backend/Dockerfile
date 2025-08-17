FROM python:3.11-slim

WORKDIR /app

# install system deps if scanners later need them
RUN apt-get update && apt-get install -y \
    curl wget git build-essential \
    && rm -rf /var/lib/apt/lists/*

# copy backend deps
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# copy backend source
COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
