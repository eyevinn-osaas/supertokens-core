#!/bin/bash
set -eo pipefail

PORT=${PORT:-8080}
TEMP_DIR=/tmp/supertokens-$$
mkdir -p "$TEMP_DIR"

CONFIG_FILE="${TEMP_DIR}/config.yaml"

# Start from the shipped config.yaml (provides core_config_version and defaults)
cp /opt/supertokens/config.yaml "$CONFIG_FILE"

# Override/append OSC platform settings
{
    echo "host: 0.0.0.0"
    echo "port: ${PORT}"

    if [ -n "$DATABASE_URL" ]; then
        echo "postgresql_connection_uri: ${DATABASE_URL}"
    fi

    [ -n "$POSTGRESQL_CONNECTION_URI" ] && echo "postgresql_connection_uri: $POSTGRESQL_CONNECTION_URI"
    [ -n "$POSTGRESQL_HOST" ]           && echo "postgresql_host: $POSTGRESQL_HOST"
    [ -n "$POSTGRESQL_PORT" ]           && echo "postgresql_port: $POSTGRESQL_PORT"
    [ -n "$POSTGRESQL_USER" ]           && echo "postgresql_user: $POSTGRESQL_USER"
    [ -n "$POSTGRESQL_PASSWORD" ]       && echo "postgresql_password: $POSTGRESQL_PASSWORD"
    [ -n "$POSTGRESQL_DATABASE_NAME" ]  && echo "postgresql_database_name: $POSTGRESQL_DATABASE_NAME"

    [ -n "$API_KEYS" ]                           && echo "api_keys: $API_KEYS"
    [ -n "$OAUTH_CLIENT_SECRET_ENCRYPTION_KEY" ] && echo "oauth_client_secret_encryption_key: $OAUTH_CLIENT_SECRET_ENCRYPTION_KEY"
    [ -n "$ACCESS_TOKEN_VALIDITY" ]              && echo "access_token_validity: $ACCESS_TOKEN_VALIDITY"
    [ -n "$REFRESH_TOKEN_VALIDITY" ]             && echo "refresh_token_validity: $REFRESH_TOKEN_VALIDITY"
    [ -n "$PASSWORD_HASHING_ALG" ]               && echo "password_hashing_alg: $PASSWORD_HASHING_ALG"
    [ -n "$LOG_LEVEL" ]                          && echo "log_level: $LOG_LEVEL"
    [ -n "$IP_ALLOW_REGEX" ]                     && echo "ip_allow_regex: $IP_ALLOW_REGEX"

    echo "disable_telemetry: true"
    echo "info_log_path: null"
    echo "error_log_path: null"
} >> "$CONFIG_FILE"

chown -R supertokens:supertokens "$TEMP_DIR" 2>/dev/null || true

exec gosu supertokens /opt/supertokens/jre/bin/java \
    -classpath "/opt/supertokens/core/*:/opt/supertokens/plugin-interface/*:/opt/supertokens/ee/*" \
    io.supertokens.Main \
    /opt/supertokens \
    DEV \
    "configFile=${CONFIG_FILE}" \
    "tempDirLocation=${TEMP_DIR}"
