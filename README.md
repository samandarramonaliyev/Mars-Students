# Mars Devs - Educational Platform

Full-stack web application for educational management with roles (admin, teacher, student), task system, shop, chess, and typing tests.

## Tech Stack

| Layer | Technology |
|-------|------------|
| **Backend** | Django 4.x + Django REST Framework + JWT |
| **Frontend** | React 18 + Vite + Tailwind CSS |
| **Database** | PostgreSQL (production) / SQLite (development) |
| **Server** | Gunicorn + WhiteNoise |
| **Proxy** | Nginx |
| **Container** | Docker + Docker Compose |

---

## Quick Start

### Local Development

```bash
# Backend
cd backend
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
cp .env.example .env
python manage.py migrate
python manage.py seed
python manage.py runserver

# Frontend (new terminal)
cd frontend
npm install
npm run dev
```

**Access:**
- Frontend: http://localhost:5173
- API: http://localhost:8000/api/
- Admin: http://localhost:8000/admin/

---

## Deployment Options

### Option 1: Docker Compose (Single Server / VPS)

Best for: VPS, DigitalOcean Droplet, AWS EC2, Linode

```bash
# 1. Configure environment
cp .env.example .env
nano .env  # Set SECRET_KEY, DB_PASSWORD, domain

# 2. Deploy
docker-compose -f docker-compose.prod.yml up --build -d

# 3. Initialize data
docker-compose -f docker-compose.prod.yml exec backend python manage.py seed

# 4. View logs
docker-compose -f docker-compose.prod.yml logs -f
```

**Architecture:**
```
                    ┌─────────────────────────────────────┐
                    │           Docker Network            │
                    │                                     │
  Port 80 ──────────►  ┌──────────┐    ┌──────────┐      │
                    │  │ Frontend │───►│ Backend  │      │
                    │  │ (Nginx)  │    │ (Django) │      │
                    │  └──────────┘    └────┬─────┘      │
                    │                       │            │
                    │                  ┌────▼─────┐      │
                    │                  │ Postgres │      │
                    │                  └──────────┘      │
                    └─────────────────────────────────────┘
```

---

### Option 2: Render.com (Recommended for beginners)

Best for: Easy deployment, free tier available

**Automatic Deployment:**
1. Push code to GitHub
2. Connect repo to Render
3. Render uses `render.yaml` automatically

**Manual Setup:**

1. **Create PostgreSQL Database**
   - Render Dashboard → New → PostgreSQL
   - Name: `marsdevs-db`

2. **Create Backend Web Service**
   - New → Web Service → Connect repo
   - Root Directory: `backend`
   - Runtime: Docker
   - Set environment variables:
     ```
     DEBUG=False
     USE_SQLITE=False
     SECRET_KEY=<generate-secure-key>
     ALLOWED_HOSTS=.onrender.com
     DATABASE_URL=<from-database>
     CORS_ALLOWED_ORIGINS=https://your-frontend.onrender.com
     CSRF_TRUSTED_ORIGINS=https://your-frontend.onrender.com
     ```

3. **Create Frontend Static Site**
   - New → Static Site → Connect repo
   - Root Directory: `frontend`
   - Build Command: `npm ci && npm run build`
   - Publish Directory: `dist`
   - Add rewrites in dashboard or use `render.yaml`

**Architecture:**
```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Frontend   │────►│   Backend    │────►│  PostgreSQL  │
│ (Static Site)│     │(Web Service) │     │  (Database)  │
└──────────────┘     └──────────────┘     └──────────────┘
    Render              Render               Render
```

---

### Option 3: Railway

Best for: Simple deployment, good free tier

1. Create new project in Railway
2. Add PostgreSQL plugin
3. Add service from GitHub
4. Set environment variables
5. Railway auto-detects `railway.json`

---

### Option 4: Vercel (Frontend) + Render (Backend)

Best for: Maximum performance for frontend

**Frontend on Vercel:**
```bash
cd frontend
vercel deploy
```
Update `vercel.json` with your backend URL.

**Backend on Render:**
Follow Render instructions above.

---

## Environment Variables

### Backend (.env)

| Variable | Description | Example |
|----------|-------------|---------|
| `SECRET_KEY` | Django secret key | `generate-secure-key` |
| `DEBUG` | Debug mode | `False` |
| `USE_SQLITE` | Use SQLite | `False` |
| `DATABASE_URL` | PostgreSQL URL | `postgres://...` |
| `ALLOWED_HOSTS` | Allowed domains | `yourdomain.com` |
| `CORS_ALLOWED_ORIGINS` | Frontend URLs | `https://yourdomain.com` |
| `CSRF_TRUSTED_ORIGINS` | Trusted origins | `https://yourdomain.com` |

### Frontend (.env)

| Variable | Description | Example |
|----------|-------------|---------|
| `VITE_API_URL` | API base URL | `/api` or `https://api.domain.com/api` |

---

## Default Accounts

After running `python manage.py seed`:

| Role | Username | Password |
|------|----------|----------|
| Admin | `admin` | `admin123` |
| Teacher | `teacher` | `teacher123` |

Students are created by teachers through the interface.

---

## API Endpoints

| Endpoint | Description |
|----------|-------------|
| `POST /api/auth/login/` | Login |
| `POST /api/auth/refresh/` | Refresh token |
| `GET /api/profile/` | Get profile |
| `GET /api/tasks/` | List tasks |
| `GET /api/shop/products/` | Shop products |
| `POST /api/chess/start/` | Start chess game |

Full API documentation available at `/admin/` after login.

---

## Project Structure

```
mars-dashboard/
├── backend/
│   ├── api/                 # Main Django app
│   ├── marsdevs/            # Django settings
│   ├── Dockerfile           # Backend Docker config
│   ├── requirements.txt     # Python dependencies
│   └── .env.example         # Environment template
├── frontend/
│   ├── src/                 # React source code
│   ├── Dockerfile.prod      # Frontend Docker config
│   ├── nginx.conf           # Nginx configuration
│   └── package.json         # Node dependencies
├── docker-compose.yml       # Development compose
├── docker-compose.prod.yml  # Production compose
├── render.yaml              # Render deployment
├── railway.json             # Railway deployment
├── .env.example             # Root env template
└── README.md
```

---

## CI/CD

GitHub Actions workflow included (`.github/workflows/deploy.yml`):
- Runs tests on every push
- Builds Docker images
- Pushes to GitHub Container Registry

---

## Commands

```bash
# Development
python manage.py runserver      # Start Django dev server
npm run dev                     # Start Vite dev server

# Production
python manage.py seed           # Create initial data
python manage.py migrate        # Run migrations
python manage.py collectstatic  # Collect static files

# Docker
docker-compose up --build                           # Development
docker-compose -f docker-compose.prod.yml up -d     # Production
docker-compose logs -f                              # View logs
```

---

## Troubleshooting

### "Connection refused" on Render
- Check DATABASE_URL is set correctly
- Ensure PostgreSQL addon is attached
- Check logs for migration errors

### CORS errors
- Verify CORS_ALLOWED_ORIGINS includes your frontend URL
- Include protocol (https://)

### Static files not loading
- Run `collectstatic` after deploy
- Check STATIC_URL and STATIC_ROOT settings

---

## License

MIT
