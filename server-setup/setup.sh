#!/bin/bash
# =============================================================================
# Server Setup Script - Shared Caddy + Calculator App
# =============================================================================
# Run this on your DigitalOcean droplet as the deploy user
# =============================================================================

set -e

echo "=========================================="
echo "Step 1: Stop the existing nginx container"
echo "=========================================="
echo "Run: cd /opt/newsdigest && docker compose stop nginx"
echo "Or if using a different compose file:"
echo "     docker stop news-digest-nginx"
echo ""
read -p "Press Enter after you've stopped nginx..."

echo ""
echo "=========================================="
echo "Step 2: Create shared Caddy directory"
echo "=========================================="
sudo mkdir -p /opt/caddy
sudo chown deploy:deploy /opt/caddy

echo ""
echo "=========================================="
echo "Step 3: Create the shared Docker network"
echo "=========================================="
docker network create caddy-net 2>/dev/null || echo "Network caddy-net already exists"

echo ""
echo "=========================================="
echo "Step 4: Update NewsDigest to use caddy-net"
echo "=========================================="
echo "You need to update /opt/newsdigest docker-compose to:"
echo "  1. Remove the nginx service (or set it to not start)"
echo "  2. Add 'caddy-net' as an external network"
echo "  3. Connect the api and frontend services to caddy-net"
echo ""
echo "Example network config to add:"
echo "  networks:"
echo "    caddy-net:"
echo "      external: true"
echo ""
read -p "Press Enter after you've updated NewsDigest compose..."

echo ""
echo "=========================================="
echo "Step 5: Create Calculator app directory"
echo "=========================================="
sudo mkdir -p /opt/calculator
sudo chown deploy:deploy /opt/calculator

echo ""
echo "=========================================="
echo "Step 6: Clone Calculator repository"
echo "=========================================="
echo "Run: git clone https://github.com/samgonzalez27/Project3_IS218.git /opt/calculator"
echo ""
read -p "Press Enter after cloning..."

echo ""
echo "=========================================="
echo "Step 7: Create Calculator .env file"
echo "=========================================="
cd /opt/calculator
if [ ! -f .env.production ]; then
    cp .env.production.example .env.production
    echo "Created .env.production - EDIT IT with real values!"
    echo ""
    echo "Generate secrets with:"
    echo "  openssl rand -hex 32   # for JWT_SECRET_KEY"
    echo "  openssl rand -hex 32   # for JWT_REFRESH_SECRET_KEY"
    echo "  openssl rand -base64 24  # for POSTGRES_PASSWORD"
fi
ln -sf .env.production .env
echo ""
read -p "Press Enter after editing .env.production..."

echo ""
echo "=========================================="
echo "Step 8: Copy Caddyfile to /opt/caddy"
echo "=========================================="
echo "Copy the Caddyfile from server-setup/caddy/Caddyfile"
echo "And UPDATE the NewsDigest domain placeholder!"
echo ""
read -p "Press Enter after copying Caddyfile..."

echo ""
echo "=========================================="
echo "Step 9: Start shared Caddy"
echo "=========================================="
cd /opt/caddy
docker compose up -d
docker compose logs -f

echo ""
echo "=========================================="
echo "Step 10: Start Calculator app"
echo "=========================================="
cd /opt/calculator
docker compose -f docker-compose.production.yml up -d
docker compose -f docker-compose.production.yml logs -f

echo ""
echo "=========================================="
echo "Step 11: Restart NewsDigest with new network"
echo "=========================================="
cd /opt/newsdigest
docker compose down
docker compose up -d

echo ""
echo "Done! Check https://samgonzalezalberto.me"
