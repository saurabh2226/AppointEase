#!/bin/bash
set -euxo pipefail
exec > /var/log/userdata.log 2>&1

echo "=== AppointEase setup: $(date) ==="

# System update and dependencies
dnf update -y
dnf install -y python3.11 python3.11-pip git postgresql15 amazon-ssm-agent

systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Clone repository
git clone ${repo_url} /app
chown -R ec2-user:ec2-user /app
cd /app/backend

# Install Python dependencies
python3.11 -m pip install --upgrade pip
python3.11 -m pip install -r requirements.txt

# Create .env file
cat > /app/backend/.env << ENVEOF
APP_NAME=AppointEase
APP_VERSION=1.0.0
DEBUG=false

DATABASE_URL=${database_url}
REDIS_URL=${redis_url}

SECRET_KEY=${secret_key}
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7

CORS_ORIGINS=["${frontend_url}"]
FRONTEND_URL=${frontend_url}
BACKEND_URL=${backend_url}

SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=${smtp_user}
SMTP_PASS=${smtp_pass}
EMAIL_FROM=AppointEase <no-reply@appointease.local>

RAZORPAY_KEY_ID=${razorpay_key_id}
RAZORPAY_KEY_SECRET=${razorpay_key_secret}
RAZORPAY_WEBHOOK_SECRET=

RATE_LIMIT_PER_MINUTE=60
RATE_LIMIT_AUTH_PER_MINUTE=10
ENVEOF

chown ec2-user:ec2-user /app/backend/.env
chmod 600 /app/backend/.env

# Run database migrations
cd /app/backend
python3.11 -m alembic upgrade head

# Create systemd service
cat > /etc/systemd/system/appointease.service << SVCEOF
[Unit]
Description=AppointEase API
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/app/backend
ExecStart=/usr/local/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 2
Restart=always
RestartSec=5
EnvironmentFile=/app/backend/.env
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SVCEOF

systemctl daemon-reload
systemctl enable appointease
systemctl start appointease

# Verify
sleep 20
if curl -sf http://localhost:8000/health; then
  echo "=== SUCCESS: $(date) ==="
else
  echo "=== FAILED: $(date) ==="
  journalctl -u appointease --no-pager -n 50
  exit 1
fi
