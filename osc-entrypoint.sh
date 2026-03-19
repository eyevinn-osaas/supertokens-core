#!/bin/bash
set -eo pipefail

PORT=${PORT:-8080}
TEMP_DIR=/tmp/supertokens-config-$$
mkdir -p "$TEMP_DIR"
chmod 755 "$TEMP_DIR"

CONFIG_HASH=$(head -n 1 /CONFIG_HASH 2>/dev/null || echo "")
ORIGINAL_CONFIG=/usr/lib/supertokens/config.yaml
CONFIG_FILE="${TEMP_DIR}/config.yaml"

# Copy base config
cat "$ORIGINAL_CONFIG" > "$CONFIG_FILE"

# Required for JNA
export _JAVA_OPTIONS="-Djava.io.tmpdir=${TEMP_DIR}"

# Apply OSC platform settings
{
    echo ""
    echo "host: 0.0.0.0"
    echo "port: ${PORT}"
    echo "postgresql_config_version: 0"
} >> "$CONFIG_FILE"

# DATABASE_URL parsing: postgresql://user:pass@host:5432/dbname
if [ -n "$DATABASE_URL" ]; then
    # Extract components from DATABASE_URL
    DB_URL_STRIPPED="${DATABASE_URL#postgresql://}"
    DB_URL_STRIPPED="${DB_URL_STRIPPED#postgres://}"
    USERPASS="${DB_URL_STRIPPED%%@*}"
    HOSTDBPART="${DB_URL_STRIPPED#*@}"
    PG_USER="${USERPASS%%:*}"
    PG_PASS="${USERPASS#*:}"
    HOSTPORT="${HOSTDBPART%%/*}"
    PG_DB="${HOSTDBPART#*/}"
    PG_HOST="${HOSTPORT%%:*}"
    PG_PORT="${HOSTPORT##*:}"
    if [ "$PG_PORT" = "$PG_HOST" ]; then
        PG_PORT="5432"
    fi

    echo "postgresql_connection_uri: ${DATABASE_URL}" >> "$CONFIG_FILE"
fi

# Override with individual vars if set
[ -n "$POSTGRESQL_CONNECTION_URI" ] && echo "postgresql_connection_uri: $POSTGRESQL_CONNECTION_URI" >> "$CONFIG_FILE"
[ -n "$POSTGRESQL_HOST" ] && echo "postgresql_host: $POSTGRESQL_HOST" >> "$CONFIG_FILE"
[ -n "$POSTGRESQL_PORT" ] && echo "postgresql_port: $POSTGRESQL_PORT" >> "$CONFIG_FILE"
[ -n "$POSTGRESQL_USER" ] && echo "postgresql_user: $POSTGRESQL_USER" >> "$CONFIG_FILE"
[ -n "$POSTGRESQL_PASSWORD" ] && echo "postgresql_password: $POSTGRESQL_PASSWORD" >> "$CONFIG_FILE"
[ -n "$POSTGRESQL_DATABASE_NAME" ] && echo "postgresql_database_name: $POSTGRESQL_DATABASE_NAME" >> "$CONFIG_FILE"

# API keys
[ -n "$API_KEYS" ] && echo "api_keys: $API_KEYS" >> "$CONFIG_FILE"

# Disable telemetry by default on OSC
echo "disable_telemetry: true" >> "$CONFIG_FILE"
echo "info_log_path: null" >> "$CONFIG_FILE"
echo "error_log_path: null" >> "$CONFIG_FILE"

# Optional config
[ -n "$ACCESS_TOKEN_VALIDITY" ] && echo "access_token_validity: $ACCESS_TOKEN_VALIDITY" >> "$CONFIG_FILE"
[ -n "$REFRESH_TOKEN_VALIDITY" ] && echo "refresh_token_validity: $REFRESH_TOKEN_VALIDITY" >> "$CONFIG_FILE"
[ -n "$PASSWORD_HASHING_ALG" ] && echo "password_hashing_alg: $PASSWORD_HASHING_ALG" >> "$CONFIG_FILE"
[ -n "$LOG_LEVEL" ] && echo "log_level: $LOG_LEVEL" >> "$CONFIG_FILE"
[ -n "$IP_ALLOW_REGEX" ] && echo "ip_allow_regex: $IP_ALLOW_REGEX" >> "$CONFIG_FILE"
[ -n "$OAUTH_CLIENT_SECRET_ENCRYPTION_KEY" ] && echo "oauth_client_secret_encryption_key: $OAUTH_CLIENT_SECRET_ENCRYPTION_KEY" >> "$CONFIG_FILE"

# Start supertokens (as supertokens user if running as root)
if [ "$(id -u)" = "0" ]; then
    chown -R supertokens:supertokens "$TEMP_DIR" 2>/dev/null || true
    exec gosu supertokens supertokens start --with-config="$CONFIG_FILE" --with-temp-dir="$TEMP_DIR" --foreground
else
    exec supertokens start --with-config="$CONFIG_FILE" --with-temp-dir="$TEMP_DIR" --foreground
fi
