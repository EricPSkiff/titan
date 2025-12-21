#!/bin/bash
# PROTOCOL: COLD STORAGE V3 (DISTRIBUTED)
TIMESTAMP=$(date +%F_%H-%M)
BACKUP_DIR="/mnt/backups"
ARCHIVE_NAME="titan_distributed_state_${TIMESTAMP}.tar.gz"
VOL_BACKUP_DIR="${BACKUP_DIR}/volumes_temp"

STACK_PATHS=(
    "/opt/titan-stack/proxy"
    "/opt/titan-stack/observability"
    "/opt/titan-media"
    "/opt/wazuh-docker/single-node"
)

echo ":: TITAN PROTOCOL INITIATED ::"
mkdir -p "${VOL_BACKUP_DIR}"

for path in "${STACK_PATHS[@]}"; do
    if [ -d "$path" ]; then
        cd "$path" && docker compose down
    fi
done

docker run --rm -v minecraft_bedrock_data:/data -v "${VOL_BACKUP_DIR}":/backup alpine tar -czf /backup/minecraft_world.tar.gz -C /data .
docker run --rm -v observability_prometheus_data:/data -v "${VOL_BACKUP_DIR}":/backup alpine tar -czf /backup/prometheus_metrics.tar.gz -C /data .

sudo tar -czf "${BACKUP_DIR}/${ARCHIVE_NAME}" /opt/titan-stack /opt/titan-media /opt/wazuh-docker "${VOL_BACKUP_DIR}"

for path in "${STACK_PATHS[@]}"; do
    if [ -d "$path" ]; then
        cd "$path" && docker compose up -d
    fi
done
rm -rf "${VOL_BACKUP_DIR}"
