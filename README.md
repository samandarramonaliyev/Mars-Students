# Mars Devs - Образовательная платформа

Веб-приложение для управления образовательным процессом с поддержкой ролей (администратор, учитель, студент), системой заданий, монет и тестом скорости печати.

## Технологии

- **Backend**: Django 4.x + Django REST Framework + SimpleJWT
- **Frontend**: React + Vite + Tailwind CSS
- **База данных**: PostgreSQL (Docker) / SQLite (локально)
- **Аутентификация**: JWT токены

## Структура проекта

```
mars-dashboard/
├── backend/
│   ├── marsdevs/           # Настройки Django проекта
│   │   ├── settings.py
│   │   ├── urls.py
│   │   └── ...
│   ├── api/                # Основное приложение
│   │   ├── models.py       # Модели БД
│   │   ├── serializers.py  # DRF сериализаторы
│   │   ├── views.py        # API endpoints
│   │   ├── urls.py         # Маршруты API
│   │   ├── admin.py        # Админ-панель
│   │   ├── permissions.py  # Права доступа
│   │   └── management/     # Management команды
│   ├── manage.py
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .env.example
├── frontend/
│   ├── src/
│   │   ├── components/     # React компоненты
│   │   ├── pages/          # Страницы
│   │   ├── context/        # Контексты (Auth)
│   │   ├── api/            # API клиент
│   │   ├── App.jsx
│   │   └── main.jsx
│   ├── package.json
│   ├── vite.config.js
│   ├── tailwind.config.js
│   └── Dockerfile
├── docker-compose.yml
└── README.md
```

## Быстрый старт

### Вариант 1: Локальная разработка (рекомендуется)

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

# 6. Создать начальные данные (admin, teacher, курсы, задания)
python manage.py seed_data

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

Приложение будет доступно:
- Frontend: http://localhost:5173
- Backend API: http://localhost:8000/api/
- Django Admin: http://localhost:8000/admin/

### Вариант 2: Docker Compose

```bash
# Запустить все сервисы
docker-compose up --build

# В отдельном терминале создать начальные данные
docker-compose exec web python manage.py seed_data
```

## Учётные записи по умолчанию

После выполнения `python manage.py seed_data`:

| Роль | Логин | Пароль |
|------|-------|--------|
| Администратор | admin | admin123 |
| Учитель | teacher | teacher123 |

Студенты создаются учителем через интерфейс.

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
| PATCH | `/api/profile/` | Обновить профиль (nickname, avatar, phone) |

### Студенты (для учителей)

| Метод | URL | Описание |
|-------|-----|----------|
| GET | `/api/students/` | Список студентов |
| POST | `/api/students/` | Создать студента |
| GET | `/api/students/{id}/` | Информация о студенте |
| PATCH | `/api/students/{id}/` | Обновить студента |
| GET | `/api/students/{id}/coins/` | История монет студента |
| POST | `/api/students/{id}/coins/` | Начислить/списать монеты |

### Задания

| Метод | URL | Описание |
|-------|-----|----------|
| GET | `/api/tasks/` | Список заданий |
| POST | `/api/tasks/{id}/submit/` | Отправить задание (студент) |
| GET | `/api/submissions/` | Список отправок (учитель) |
| POST | `/api/submissions/{id}/review/` | Проверить задание (учитель) |
| GET | `/api/my-submissions/` | Мои отправки (студент) |

### Монеты и история

| Метод | URL | Описание |
|-------|-----|----------|
| GET | `/api/my-coins/` | Мои транзакции монет |

### Typing (тест печати)

| Метод | URL | Описание |
|-------|-----|----------|
| GET | `/api/typing-results/` | Мои результаты |
| POST | `/api/typing-results/` | Сохранить результат |

### Шахматы (ручная запись учителем)

| Метод | URL | Описание |
|-------|-----|----------|
| GET | `/api/chess-history/` | История игр (ручная) |
| POST | `/api/chess-history/` | Добавить игру (учитель) |

### Шахматы (реальная игра)

| Метод | URL | Описание |
|-------|-----|----------|
| POST | `/api/chess/start/` | Начать игру |
| POST | `/api/chess/finish/` | Завершить игру |
| GET | `/api/chess/my-games/` | Мои игры и статистика |
| GET | `/api/chess/online-students/` | Список студентов для PvP |
| POST | `/api/chess/invite/` | Отправить приглашение |
| GET | `/api/chess/my-invites/` | Мои приглашения |
| POST | `/api/chess/respond-invite/` | Ответить на приглашение |
| POST | `/api/chess/cancel-invite/` | Отменить приглашение |
| GET | `/api/chess/game/{id}/` | Состояние игры (PvP) |
| POST | `/api/chess/game/{id}/` | Сделать ход (PvP) |

### Статистика учителя

| Метод | URL | Описание |
|-------|-----|----------|
| GET | `/api/teacher/stats/` | Статистика учителя |

## Пример запроса авторизации

```bash
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username": "teacher", "password": "teacher123", "expected_role": "TEACHER"}'
```

Ответ:
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": {
    "id": 2,
    "username": "teacher",
    "role": "TEACHER",
    ...
  }
}
```

## Безопасность

### Текущая реализация (для разработки)

JWT токены хранятся в `localStorage`. Это упрощает разработку, но делает приложение уязвимым к XSS атакам.

### Рекомендации для продакшена

Для безопасного хранения токенов в продакшене:

1. **Настроить httpOnly cookies на backend:**

```python
# settings.py
SIMPLE_JWT = {
    ...
    'AUTH_COOKIE': 'access_token',
    'AUTH_COOKIE_SECURE': True,  # Только HTTPS
    'AUTH_COOKIE_HTTP_ONLY': True,
    'AUTH_COOKIE_SAMESITE': 'Lax',
}
```

2. **Изменить view для установки cookie:**

```python
from rest_framework_simplejwt.tokens import RefreshToken

def login_view(request):
    ...
    response = Response({"user": user_data})
    response.set_cookie(
        'access_token',
        str(refresh.access_token),
        httponly=True,
        secure=True,
        samesite='Lax',
        max_age=3600
    )
    return response
```

3. **Настроить CORS:**

```python
# settings.py
CORS_ALLOW_CREDENTIALS = True
CORS_ALLOWED_ORIGINS = ['https://your-frontend-domain.com']
```

4. **Включить CSRF защиту для API:**

```python
CSRF_COOKIE_HTTPONLY = True
CSRF_TRUSTED_ORIGINS = ['https://your-frontend-domain.com']
```

## Тестирование

### Backend тесты

```bash
cd backend
python manage.py test
```

### Запуск конкретных тестов

```bash
python manage.py test api.tests.AuthenticationTests
python manage.py test api.tests.CoinTransactionTests
```

## Модели данных

### User (Пользователь)
- `username`, `password`, `email`, `first_name`, `last_name`
- `role`: ADMIN / TEACHER / STUDENT
- `phone`, `avatar`, `nickname`
- `student_group`: FRONTEND / BACKEND / NONE
- `balance` (монеты)
- `parent_info` (для студентов)
- `assigned_courses` (для учителей)
- `created_by` (кто создал студента)

### Course (Курс)
- `name`, `time`, `day_of_week`, `description`

### Task (Задание)
- `title`, `description`
- `target_group`: FRONTEND / BACKEND / ALL
- `reward_coins`, `deadline`, `is_active`

### TaskSubmission (Отправка задания)
- `task`, `student`
- `text_answer`, `file_answer`
- `status`: PENDING / APPROVED / REJECTED
- `grade`, `teacher_comment`, `coins_awarded`

### CoinTransaction (Транзакция монет)
- `user`, `amount`, `reason`
- `source`: TASK / TEACHER / ADMIN / CHESS / OTHER
- `balance_after`, `created_by`

### TypingResult (Результат печати)
- `user`, `wpm`, `accuracy`
- `characters_typed`, `errors`, `duration_seconds`

### ChessGameHistory (История шахмат - ручная запись)
- `user`, `opponent_name`
- `result`: WIN / LOSS / DRAW
- `notes`, `played_at`

### ChessGame (Шахматная партия - реальная игра)
- `player` - игрок
- `opponent_type`: BOT / STUDENT
- `bot_level`: easy / medium / hard (для игры с ботом)
- `opponent` - противник (для PvP)
- `status`: IN_PROGRESS / FINISHED / ABANDONED
- `result`: WIN / LOSE / DRAW
- `coins_earned` - заработанные монеты
- `fen_position` - позиция на доске
- `white_player` - кто играет белыми
- `started_at`, `finished_at`

### ChessInvite (Приглашение в шахматы)
- `from_player`, `to_player`
- `status`: PENDING / ACCEPTED / DECLINED / EXPIRED
- `game` - созданная игра

## Переменные окружения

```env
# Django
SECRET_KEY=your-secret-key
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1

# База данных
USE_SQLITE=True  # False для PostgreSQL
DATABASE_URL=postgres://user:pass@host:5432/dbname

# CORS
CORS_ALLOWED_ORIGINS=http://localhost:5173
```

## Шахматы (Chess Arena)

### Описание

Студенты могут играть в шахматы и зарабатывать монеты. Доступно два режима:

1. **Игра с ботом** - три уровня сложности
2. **Игра со студентом** (PvP) - приглашения через polling

### Как играть

1. Откройте страницу шахмат (`/chess`) или нажмите кнопку ♟️ в навигации
2. Выберите режим игры:
   - **🤖 Играть с ботом** - выберите уровень сложности
   - **👤 Играть со студентом** - отправьте приглашение другому студенту
3. Играйте, делая ходы на доске
4. После завершения партии получите награду

### Уровни бота

| Уровень | Поведение | Награда за победу |
|---------|-----------|-------------------|
| **Легкий (Easy)** | Случайные допустимые ходы | 45 монет |
| **Средний (Medium)** | Приоритет взятий | 75 монет |
| **Сложный (Hard)** | Minimax алгоритм (глубина 2-3) | 100 монет |

### Награды

#### Игра с ботом
| Результат | Easy | Medium | Hard |
|-----------|------|--------|------|
| Победа | 45 | 75 | 100 |
| Ничья | 10 | 20 | 30 |
| Поражение | 0 | 0 | 0 |

#### Игра со студентом (PvP)
| Результат | Монеты |
|-----------|--------|
| Победа | 50 |
| Ничья | 20 |
| Поражение | 0 |

### Технические детали

- **Шахматная логика**: `chess.js` - проверка валидности ходов, определение мата/пата
- **Отображение доски**: `react-chessboard` - интерактивная доска
- **PvP синхронизация**: HTTP polling каждые 3 секунды
- **Хранение позиции**: FEN-нотация в базе данных

### API примеры

#### Начать игру с ботом

```bash
curl -X POST http://localhost:8000/api/chess/start/ \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"opponent_type": "BOT", "bot_level": "medium"}'
```

#### Завершить игру

```bash
curl -X POST http://localhost:8000/api/chess/finish/ \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"game_id": 1, "result": "WIN"}'
```

#### Отправить приглашение

```bash
curl -X POST http://localhost:8000/api/chess/invite/ \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"to_player_id": 5}'
```

### Просмотр истории

История всех сыгранных партий доступна:
- На странице профиля (вкладка "Шахматы")
- Через API: `GET /api/chess/my-games/`

Статистика включает:
- Общее количество игр
- Победы / поражения / ничьи
- Всего заработано монет
- Игры с ботом / PvP

## Лицензия

MIT
