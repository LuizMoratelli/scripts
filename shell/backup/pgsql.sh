#!/bin/bash
show_help() {
cat << EOF
    Utilização: ${0##*/} [--clear] [--site=DIR]
    Realiza o backup do banco de dados POSTGRESQL configurado através do arquivo .env

        --clear     remove todos os backups anteriores desse site.
        --site=DIR  especifica o site que será feito o backup.
EOF
}

BACKUP_DIR="/var/www/public_html/database-backup"
NOW=$(date +"%Y_%m_%d")
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

if [ "$CLEAR" = true ]; then
    $(rm -f ${BACKUP_DIR}/${SITE_DIR}*.sql)
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

BACKUP_NAME="${BACKUP_DIR}/${SITE_DIR}_${NOW}.sql"

$(pg_dump -U${DB_USER} -w  ${DB_NAME} -h ${DB_HOST} -p${DB_PORT} > "${BACKUP_NAME}")
echo -e "\e[92mBackup do site ${SITE_DIR} criado com sucesso. Acesse: "${BACKUP_NAME}".\e[0m"