#!/bin/bash
BACKUP_DIR="/var/www/public_html/database-backup/"
SITE_DIR=$1

if [[ ! -d "$BACKUP_DIR" ]]; then
    $(mkdir -p $BACKUP_DIR)
fi

if [[ -z "$SITE_DIR" ]]; then
    echo -e "\e[31mÉ obrigatório informar um site\e[0m"
    exit 1
fi

if [ "$2" = true ]; then
    $(rm -f "${BACKUP_DIR}/${SITE_DIR}*.sql")
    echo -e "\e[92mBackups anteriores do site ${SITE_DIR} removidos com sucesso.\e[0m"
fi

DB_USER=$(get-env-var ${SITE_DIR} DB_USERNAME)
DB_PASS=$(get-env-var ${SITE_DIR} DB_PASSWORD)
DB_NAME=$(get-env-var ${SITE_DIR} DB_DATABASE)
DB_HOST=$(get-env-var ${SITE_DIR} DB_HOST)
DB_PORT=$(get-env-var ${SITE_DIR} DB_PORT)
DB_CONF="${DB_HOST}:${DB_PORT}:${DB_NAME}:${DB_USER}:${DB_PASS}"

if ! grep -q ${DB_CONF} "/root/.pgpass"; then
    echo "${DB_HOST}:${DB_PORT}:${DB_NAME}:${DB_USER}:${DB_PASS}" >> "/root/.pgpass"
    chmod 600 "/root/.pgpass"
fi

$(pg_dump -U${DB_USER} -w  ${DB_NAME} -h ${DB_HOST} -p${DB_PORT} > "${BACKUP_DIR}/${SITE_DIR}_teste2.sql")
echo -e "\e[92mBackup do site ${SITE_DIR} criado com sucesso. Acesse: ${BACKUP_DIR}/${SITE_DIR}.\e[0m"
