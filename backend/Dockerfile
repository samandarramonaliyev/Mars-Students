# Dockerfile для Django backend
FROM python:3.11-slim

# Установка переменных окружения
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Установка рабочей директории
WORKDIR /app

# Установка зависимостей системы
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Копирование и установка Python зависимостей
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копирование исходного кода
COPY . .

# Создание директории для медиа файлов
RUN mkdir -p /app/media /app/staticfiles

# Открытие порта
EXPOSE 8000

# Команда запуска
CMD ["sh", "-c", "python manage.py migrate && python manage.py collectstatic --noinput && gunicorn marsdevs.wsgi:application --bind 0.0.0.0:8000"]
