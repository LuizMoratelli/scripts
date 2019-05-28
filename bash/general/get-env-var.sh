#!/bin/bash
PUBLIC_DIR="/var/www/public_html"
ENV_DIR=$1
ENV_VAR=$2

if [[ -z "$ENV_DIR" ]]; then
    echo -e "\e[31mÉ obrigatório informar um diretório\e[0m"
fi

if [[ -z "$ENV_VAR" ]]; then
    echo -e "\e[31mÉ obrigatório informar uma variável\e[0m"
fi

echo $(grep ${ENV_VAR} "${PUBLIC_DIR}/${ENV_DIR}/.env" | xargs | cut -d'=' -f2)
