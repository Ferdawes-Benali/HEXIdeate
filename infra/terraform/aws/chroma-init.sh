#!/bin/bash
set -e

# Update system
apt-get update
apt-get upgrade -y

# Install Docker
apt-get install -y docker.io

# Start Docker
systemctl start docker
systemctl enable docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Pull and run Chroma Docker image
docker pull ghcr.io/chroma-core/chroma:${chroma_version}
docker run -d \
  --name chroma \
  -p 8000:8000 \
  -e CHROMA_DB_IMPL=duckdb+parquet \
  -v /data/chroma:/chroma/chroma_data \
  ghcr.io/chroma-core/chroma:${chroma_version}

# Create health check script
cat > /usr/local/bin/chroma-health-check.sh << 'EOF'
#!/bin/bash
curl -f http://localhost:8000/api/v1/heartbeat || exit 1
EOF

chmod +x /usr/local/bin/chroma-health-check.sh

# Setup CloudWatch agent (optional)
# wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
# dpkg -i amazon-cloudwatch-agent.deb

echo "Chroma setup complete"
