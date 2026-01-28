#!/bin/bash
# =============================================================================
# DEPLOYMENT SCRIPT FOR VPS
# =============================================================================
# 
# Usage:
#   chmod +x scripts/deploy.sh
#   ./scripts/deploy.sh
#
# Requirements:
#   - Docker & Docker Compose installed
#   - .env file configured
#
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Mars Devs Deployment Script ===${NC}"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo "Please copy .env.production to .env and configure it."
    exit 1
fi

# Check if SECRET_KEY is set
if grep -q "CHANGE_ME" .env; then
    echo -e "${RED}Error: Please change default values in .env file!${NC}"
    exit 1
fi

echo -e "${YELLOW}Step 1: Pulling latest code...${NC}"
git pull origin main || true

echo -e "${YELLOW}Step 2: Building Docker images...${NC}"
docker-compose -f docker-compose.prod.yml build --no-cache

echo -e "${YELLOW}Step 3: Stopping existing containers...${NC}"
docker-compose -f docker-compose.prod.yml down || true

echo -e "${YELLOW}Step 4: Starting services...${NC}"
docker-compose -f docker-compose.prod.yml up -d

echo -e "${YELLOW}Step 5: Waiting for services to be healthy...${NC}"
sleep 30

echo -e "${YELLOW}Step 6: Running database migrations...${NC}"
docker-compose -f docker-compose.prod.yml exec -T backend python manage.py migrate --noinput

echo -e "${YELLOW}Step 7: Collecting static files...${NC}"
docker-compose -f docker-compose.prod.yml exec -T backend python manage.py collectstatic --noinput

# Check if seed data exists
echo -e "${YELLOW}Step 8: Checking seed data...${NC}"
docker-compose -f docker-compose.prod.yml exec -T backend python manage.py seed || true

echo -e "${YELLOW}Step 9: Cleaning up old images...${NC}"
docker image prune -f

echo ""
echo -e "${GREEN}=== Deployment Complete! ===${NC}"
echo ""
echo "Your application is now running at:"
echo "  - Frontend: http://localhost (or your domain)"
echo "  - Admin: http://localhost/admin/"
echo "  - API: http://localhost/api/"
echo ""
echo "Default accounts:"
echo "  - Admin: admin / admin123"
echo "  - Teacher: teacher / teacher123"
echo ""
echo "To view logs:"
echo "  docker-compose -f docker-compose.prod.yml logs -f"
echo ""
