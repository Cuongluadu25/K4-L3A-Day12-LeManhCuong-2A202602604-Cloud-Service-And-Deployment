# CP2 — Containerization (production-ready)

# Stage 1: builder — cài dependency
FROM python:3.11-slim AS builder

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2: runtime — image nhỏ gọn
FROM python:3.11-slim AS runtime

WORKDIR /app

# Copy dependency đã cài từ builder
COPY --from=builder /install /usr/local

# Tạo user thường, không chạy root
RUN useradd --create-home --uid 10001 appuser

# Copy source code
COPY app ./app
COPY utils ./utils

# Chuyển sang user thường
USER appuser

# Expose cổng mặc định
EXPOSE 8000

# Health check gọi /health
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health').read()" || exit 1

# Đọc PORT từ biến môi trường, mặc định 8000
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
