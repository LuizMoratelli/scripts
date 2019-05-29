#!/bin/bash
show_help() {
cat << EOF
    Utilização: ${0##*/} [--clear] [--site=DIR]
    Realiza o backup do banco de dados POSTGRESQL configurado através do arquivo .env

        --clear     remove todos os backups anteriores desse site.
        --site=DIR  especifica o site que será feito o backup.
EOF
}

log() {
    LOG_DIR="/var/www/public_html/database-backup"
    LOG_DATE=$(date +"%Y_%m_%d")
    MSG_INFO=$1
    MSG_DATE=$(date +"%c")

    echo "[${MSG_DATE}] ${MSG_INFO}" >> "${LOG_DIR}/error_${LOG_DATE}.log"
}

BACKUP_DIR="/var/www/public_html/database-backup"
NOW=$(date +"%Y_%m_%d")
DISK_AVAILABLE=$(df -B1 / | awk 'NR==2 {print $4}')
DISK_NEED_MOD=2
CLEAR=false

if [[ ! -d "$BACKUP_DIR" ]]; then
    $(mkdir -p $BACKUP_DIR)
fi

while :; do
    case $1 in
        -h|-\?|--help)
            show_help
            exit
            ;;
        --clear)
            CLEAR=true
            ;;
        --site=?*)
            SITE_DIR=${1#*=}
            ;;
        --site=)
            echo -e '\e[31mÉ obrigatório informar um site\e[0m'
            ;;
        --)
            shift
            break
            ;;
        -?*)
            echo -e '\e[31mOpção desconhecida ignorada\e[0m'
            ;;
        *)
            break
    esac

    shift
done

if [[ -z "$SITE_DIR" ]]; then
    echo -e "\e[31mÉ obrigatório informar um site\e[0m"
    exit 1
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

DISK_NEED=$(psql -U${DB_USER} -w  ${DB_NAME} -h ${DB_HOST} -p${DB_PORT} -t \
                                             -c "SELECT t1.datname, pg_database_size(t1.datname) AS db_size
                                                   FROM pg_database t1
                                                  WHERE t1.datname = '${DB_NAME}'
                                               ORDER BY pg_database_size(t1.datname) DESC;" | awk '{print $3}')
DISK_NEED_TOTAL=$((${DISK_NEED} * ${DISK_NEED_MOD}))

if [ "$DISK_NEED_TOTAL" -gt "$DISK_AVAILABLE" ]; then
    echo -e "\e[31mEspaço insuficiente para gerar backup\e[0m"
    log "Espaço insuficiente para gerar backup"
    exit 1
fi

if [ "$CLEAR" = true ]; then
    $(rm -f ${BACKUP_DIR}/${SITE_DIR}*.sql)
    echo -e "\e[92mBackups anteriores do site ${SITE_DIR} removidos com sucesso.\e[0m"
    log "Backups anteriores do site ${SITE_DIR} removidos com sucesso."
fi

BACKUP_NAME="${BACKUP_DIR}/${SITE_DIR}_${NOW}.sql"

$(pg_dump -U${DB_USER} -w  ${DB_NAME} -h ${DB_HOST} -p${DB_PORT} > "${BACKUP_NAME}")
echo -e "\e[92mBackup do site ${SITE_DIR} criado com sucesso. Acesse: ${BACKUP_NAME}.\e[0m"
log "Backup do site ${SITE_DIR} criado com sucesso. Acesse: ${BACKUP_NAME}"