#!/bin/bash
# Constantes
SSL_DIR="/etc/apache2/certificates-enabled"
DOMAIN=$1
ORGANIZATION=$2

# Validação
if [[ -z "$DOMAIN" ]]; then
    echo -e "\e[31mÉ obrigatório informar um domínio\e[0m"
    exit 1
fi
if [[ -z "$ORGANIZATION" ]]; then
    echo -e "\e[31mÉ obrigatório o nome da organização\e[0m"
    exit 1
fi

# Criar o CSR e Key para solicitação do certificado SSL/TLS
$(openssl req -out ${SSL_DIR}/${DOMAIN}.csr -new -newkey rsa:2048 -nodes -keyout ${SSL_DIR}/${DOMAIN}.key \
    -subj "/C=BR/ST=Santa Catarina/L=Rio do Sul/O=${ORGANIZATION}/OU=IT/CN=${DOMAIN}" 2>/dev/null)
echo -e "\e[92mCSR e Key criadas com sucesso. Acesse: ${SSL_DIR}\e[0m"

# Criar os arquivos base do certificado para quando tiver sido emitido
echo "" > ${SSL_DIR}/${DOMAIN}.crt
echo "" > ${SSL_DIR}/${DOMAIN}.bundle

# Alterar as permissões de todos os arquivos de certificado desse site
$(chown -Rf www-data. ${SSL_DIR})
$(chmod 644 -f ${SSL_DIR}/${DOMAIN}.*)
echo -e "\e[92mPermissões alteradas com sucesso.\e[0m"

# Exibir CSR
echo ""
cat ${SSL_DIR}/${DOMAIN}.csr
