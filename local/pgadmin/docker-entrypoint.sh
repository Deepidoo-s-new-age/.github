#!/bin/sh
# Build the saved server from the Compose Postgres settings, then start pgAdmin.
# Desktop mode reads PassFile as an absolute path. The file must be mode 0600.
set -eu

host="${POSTGRES_HOST:-postgres}"
port="${POSTGRES_PORT:-5432}"
user="${POSTGRES_USER:-newage}"
password="${POSTGRES_PASSWORD:-newage}"
db="${POSTGRES_DB:-new_age}"

umask 077
printf '%s\n' "${host}:${port}:*:${user}:${password}" > /var/lib/pgadmin/.pgpass

cat > /tmp/servers.json <<EOF
{
  "Servers": {
    "1": {
      "Name": "New Age (local)",
      "Group": "Servers",
      "Host": "${host}",
      "Port": ${port},
      "MaintenanceDB": "${db}",
      "Username": "${user}",
      "SSLMode": "prefer",
      "PassFile": "/var/lib/pgadmin/.pgpass"
    }
  }
}
EOF

export PGADMIN_SERVER_JSON_FILE=/tmp/servers.json
exec /entrypoint.sh
