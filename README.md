# Mars Devs - Образовательная платформа

Веб-приложение для управления образовательным процессом с поддержкой ролей (администратор, учитель, студент), системой заданий, магазином, шахматами и тестом скорости печати.

## Технологии

- **Backend**: Django 4.x + Django REST Framework + SimpleJWT
- **Frontend**: React + Vite + Tailwind CSS
- **База данных**: PostgreSQL (Docker/Production) / SQLite (локально)
- **Аутентификация**: JWT токены
- **Production**: Gunicorn + WhiteNoise + Nginx

## Структура проекта

```
mars-dashboard/
├── backend/
│   ├── marsdevs/           # Настройки Django проекта
│   ├── api/                # Основное приложение
│   │   ├── models.py       # Модели БД
│   │   ├── serializers.py  # DRF сериализаторы
│   │   ├── views.py        # API endpoints
│   │   ├── urls.py         # Маршруты API
│   │   ├── admin.py        # Админ-панель
│   │   └── management/     # Management команды (seed)
│   ├── manage.py
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .env.example
├── frontend/
│   ├── src/
│   │   ├── components/     # React компоненты
│   │   ├── pages/          # Страницы
│   │   ├── context/        # Контексты (Auth)
│   │   └── api/            # API клиент (axios)
│   ├── package.json
│   ├── vite.config.js
│   ├── Dockerfile          # Development
│   ├── Dockerfile.prod     # Production (nginx)
│   └── nginx.conf
├── docker-compose.yml      # Development
├── docker-compose.prod.yml # Production
├── .env.example
└── README.md
```

---

## Быстрый старт

### Вариант 1: Локальная разработка (рекомендуется для dev)

#### Backend

```bash
# 1. Перейти в директорию backend
cd backend

# 2. Создать виртуальное окружение
python -m venv venv

# Windows
venv\Scripts\activate
# Linux/Mac
source venv/bin/activate

# 3. Установить зависимости
pip install -r requirements.txt

# 4. Создать файл .env (скопировать из .env.example)
cp .env.example .env

# 5. Применить миграции
python manage.py migrate

# 6. Создать начальные данные (admin, teacher, курсы, задания, товары)
python manage.py seed

# 7. Запустить сервер
python manage.py runserver
```

#### Frontend

```bash
# 1. Перейти в директорию frontend
cd frontend

# 2. Установить зависимости
npm install

# 3. Запустить dev-сервер
npm run dev
```

**Приложение будет доступно:**
- Frontend: http://localhost:5173
- Backend API: http://localhost:8000/api/
- Django Admin: http://localhost:8000/admin/

---

### Вариант 2: Docker Compose (Development)

```bash
# Запустить все сервисы
docker-compose up --build

# В отдельном терминале создать начальные данные
docker-compose exec web python manage.py seed
```

---

### Вариант 3: Docker Compose (Production)

```bash
# 1. Скопировать и настроить .env файл
cp .env.example .env
# Отредактировать .env - обязательно изменить SECRET_KEY!

# 2. Запустить production сборку
docker-compose -f docker-compose.prod.yml up --build -d

# 3. Применить миграции и создать данные
docker-compose -f docker-compose.prod.yml exec backend python manage.py migrate
docker-compose -f docker-compose.prod.yml exec backend python manage.py seed

# 4. Проверить логи
docker-compose -f docker-compose.prod.yml logs -f
```

**Production приложение:**
- Frontend + API: http://localhost (порт 80)
- Django Admin: http://localhost/admin/

---

## Учётные записи по умолчанию

После выполнения `python manage.py seed`:

| Роль | Логин | Пароль |
|------|-------|--------|
| Администратор | admin | admin123 |
| Учитель | teacher | teacher123 |

**Студенты создаются учителем через интерфейс.**

---

## Переменные окружения

### Backend (.env)

```env
# Django
SECRET_KEY=your-super-secret-key          # ОБЯЗАТЕЛЬНО изменить!
DEBUG=False                                # False для production
ALLOWED_HOSTS=localhost,your-domain.com

# База данных
USE_SQLITE=True                            # False для PostgreSQL
DATABASE_URL=postgres://user:pass@host:5432/dbname

# CORS и CSRF
CORS_ALLOWED_ORIGINS=http://localhost:5173,https://your-domain.com
CSRF_TRUSTED_ORIGINS=http://localhost:5173,https://your-domain.com

# JWT
JWT_ACCESS_TOKEN_LIFETIME_MINUTES=60
JWT_REFRESH_TOKEN_LIFETIME_DAYS=7

# Security (для HTTPS)
SECURE_SSL_REDIRECT=False                  # True если есть SSL
```

### Frontend (.env)

```env
VITE_API_URL=/api
```

### Docker Compose (.env в корне)

```env
SECRET_KEY=your-super-secret-key
DB_NAME=marsdevs_db
DB_USER=marsdevs
DB_PASSWORD=secure-password
ALLOWED_HOSTS=localhost,your-domain.com
CORS_ALLOWED_ORIGINS=http://localhost,https://your-domain.com
CSRF_TRUSTED_ORIGINS=http://localhost,https://your-domain.com
FRONTEND_PORT=80
```

---

## Деплой

### VPS (Ubuntu/Debian)

```bash
# 1. Установить Docker и Docker Compose
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# 2. Клонировать репозиторий
git clone <repository-url>
cd mars-dashboard

# 3. Настроить окружение
cp .env.example .env
nano .env  # Изменить SECRET_KEY и другие настройки

# 4. Запустить
docker-compose -f docker-compose.prod.yml up --build -d

# 5. Инициализировать данные
docker-compose -f docker-compose.prod.yml exec backend python manage.py migrate
docker-compose -f docker-compose.prod.yml exec backend python manage.py seed

# 6. (Опционально) Настроить SSL с Certbot
# Добавить reverse proxy (nginx/traefik) перед контейнерами
```

### Railway

1. Создать новый проект в Railway
2. Добавить PostgreSQL сервис
3. Добавить сервис из GitHub репозитория
4. Настроить переменные окружения:
   - `SECRET_KEY`
   - `DEBUG=False`
   - `USE_SQLITE=False`
   - `DATABASE_URL` (автоматически из PostgreSQL)
   - `ALLOWED_HOSTS=*.railway.app`
   - `CORS_ALLOWED_ORIGINS=https://your-app.railway.app`
5. Настроить Start Command: `gunicorn marsdevs.wsgi:application --bind 0.0.0.0:$PORT`

### Render

1. Создать Web Service из GitHub
2. Выбрать Docker environment
3. Добавить PostgreSQL database
4. Настроить Environment Variables
5. Build Command: автоматически из Dockerfile
6. Start Command: `gunicorn marsdevs.wsgi:application --bind 0.0.0.0:$PORT`

---

## API Endpoints

### Аутентификация

| Метод | URL | Описание |
|-------|-----|----------|
| POST | `/api/auth/login/` | Получить JWT токены |
| POST | `/api/auth/refresh/` | Обновить access токен |

### Профиль

| Метод | URL | Описание |
|-------|-----|----------|
| GET | `/api/profile/` | Получить профиль |
| PATCH | `/api/profile/` | Обновить профиль |

### Студенты (для учителей)

| Метод | URL | Описание |
|-------|-----|----------|
| GET | `/api/students/` | Список студентов |
| POST | `/api/students/` | Создать студента |
| GET | `/api/students/{id}/` | Информация о студенте |
| PATCH | `/api/students/{id}/` | Обновить студента |
| GET | `/api/students/{id}/coins/` | История монет |
| POST | `/api/students/{id}/coins/` | Начислить/списать монеты |

### Задания

| Метод | URL | Описание |
|-------|-----|----------|
| GET | `/api/tasks/` | Список заданий |
| POST | `/api/tasks/{id}/submit/` | Отправить задание |
| GET | `/api/submissions/` | Список отправок (учитель) |
| POST | `/api/submissions/{id}/review/` | Проверить задание |
| GET | `/api/my-submissions/` | Мои отправки (студент) |

### Магазин

| Метод | URL | Описание |
|-------|-----|----------|
| GET | `/api/shop/products/` | Список товаров |
| POST | `/api/shop/buy/` | Купить товар |
| GET | `/api/shop/purchases/` | История покупок |

### Шахматы

| Метод | URL | Описание |
|-------|-----|----------|
| POST | `/api/chess/start/` | Начать игру |
| POST | `/api/chess/finish/` | Завершить игру |
| GET | `/api/chess/my-games/` | Мои игры и статистика |
| POST | `/api/chess/invite/` | Отправить приглашение PvP |
| GET | `/api/chess/my-invites/` | Мои приглашения |
| POST | `/api/chess/respond-invite/` | Ответить на приглашение |
| GET | `/api/chess/game/{id}/` | Состояние игры |
| POST | `/api/chess/game/{id}/` | Сделать ход |

---

## Команды управления

```bash
# Создание начальных данных
python manage.py seed

# Или полная версия
python manage.py seed_data --admin-password=secret --teacher-password=secret

# Миграции
python manage.py migrate

# Сбор статики (для production)
python manage.py collectstatic --noinput

# Создание суперпользователя
python manage.py createsuperuser
```

---

## Разработка

### Сборка frontend для production

```bash
cd frontend
npm run build
# Файлы будут в папке dist/
```

### Проверка линтером

```bash
cd frontend
npm run lint
```

### Тестирование backend

```bash
cd backend
python manage.py test
```

---

## Безопасность (Production)

- Всегда используйте уникальный `SECRET_KEY`
- Установите `DEBUG=False`
- Настройте HTTPS (SSL сертификат)
- Используйте сильные пароли для базы данных
- Регулярно обновляйте зависимости

---

## Лицензия

MIT
