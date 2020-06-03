#!/usr/bin/env bash
#-----------------------------------------------------------+
#--[ Informações ]------------------------------------------+
#                                                           |
# Nome: Music Download                                      |
# Versão: 1.0.1                                             |
# Criador: Sávio Cavalcante                                 |
# Dependências: jq e youtube-dl                             |
# Data de Criação: 03/06/2020                               |
#                                                           |
#-----------------------------------------------------------+
#--[ Descrição ]--------------------------------------------+
#                                                           |
# O objetivo do aplicativo é: baixar músicas do Youtube.    |
#                                                           |
#-----------------------------------------------------------+

# Diretório do projeto -------------------------------------#
# ----------------------------------------------------------#
directory=$(cd `dirname $0` && pwd)

# Cor ------------------------------------------------------#
# ----------------------------------------------------------#
red='\e[1;31m'
default='\e[m'

# Função de uso do programa --------------------------------#
# ----------------------------------------------------------#
usage() {
  printf "Uso:\n $0 [Parâmetro] [URL]\n $0 [Parâmetro] [URL] [Parâmetro]\n\n"
  printf "Exemplo:\n $0 -u https://www.youtube.com/watch?v=exemplo\n $0 -t https://www.youtube.com/watch?v=exemplo\n $0 -t https://www.youtube.com/watch?v=exemplo --title\n\n"
  printf " %-20s: %s\n" "-t" "Tabela completa."
  printf "   %-18s: %s\n" "--title" "Título da mídia."
  printf "   %-18s: %s\n" "--upload_date" "Data de envio da mídia."
  printf "   %-18s: %s\n" "--view_count" "Número de visualizações."
  printf "   %-18s: %s\n" "--like_count" "Número de \"Gostei\"."
  printf "   %-18s: %s\n" "--dislike_count" "Número de \"Não Gostei\"."
  printf "   %-18s: %s\n" "--uploader" "Canal do autor da mídia."
  printf "   %-18s: %s\n" "--thumbnail" "Thumbnail da mídia."
  printf "   %-18s: %s\n" "--duration" "Duração da mídia."
  printf " %-20s: %s\n" "-u" "Fazer download da mídia."
  printf " %-20s: %s\n" "-h" "Mostrar esta ajuda."
}

# Tabela de informações da mídia ---------------------------#
# ----------------------------------------------------------#
table() {
  # Se o segundo argumento for nulo, mostre uma mensagem de erro -------------------------#
  # --------------------------------------------------------------------------------------#
  if [[ -z "$2" ]]; then
    echo -e "${red}Você precisa inserir uma URL para obter a tabela com as informações precisas.${default}"
    exit 1
  fi

  # Download das informações da mídia ----------------------------------------------------#
  # --------------------------------------------------------------------------------------#
  youtube-dl --skip-download --output 'data.%(ext)s' --write-info-json "$2" >/dev/null

  # Nome do arquivo que contém as informações --------------------------------------------#
  # --------------------------------------------------------------------------------------#
  local file="$directory/data.info.json"

  # Variáveis que extraem as informações -------------------------------------------------#
  # --------------------------------------------------------------------------------------#
  local title=$(jq -r '.fulltitle' "$file")
  local upload_date=$(date -d $(jq -r '.upload_date' "$file") '+%d/%m/%Y')
  local view_count=$(jq -r '.view_count' "$file")
  local like_count=$(jq -r '.like_count' "$file")
  local dislike_count=$(jq -r '.dislike_count' "$file")
  local uploader=$(jq -r '.uploader' "$file")
  local thumbnail=$(jq -r '.thumbnail' "$file")
  local duration=$(jq -r '.duration' "$file")

  # Extrair somente uma função da tabela ------------------------------------------------#
  # --------------------------------------------------------------------------------------#
  case "$3" in
    --title) printf "%-15s: %s\n" "title" "$title" && exit 0 ;;
    --upload_date) printf "%-15s: %s\n" "upload" "$upload_date" && exit 0 ;;
    --view_count) printf "%-15s: %s\n" "view" "$view_count" && exit 0 ;;
    --like_count) printf "%-15s: %s\n" "like" "$like_count" && exit 0 ;;
    --dislike_count) printf "%-15s: %s\n" "dislike" "$dislike_count" && exit 0 ;;
    --uploader) printf "%-15s: %s\n" "uploader" "$uploader" && exit 0 ;;
    --thumbnail) printf "%-15s: %s\n" "thumbnail" "$thumbnail" && exit 0 ;;
    --duration) printf "%-15s: %s\n" "duration" "$duration" && exit 0 ;;
  esac

  # Tabela com as informações ------------------------------------------------------------#
  # --------------------------------------------------------------------------------------#
  printf "%-15s: %s\n" "title" "$title"
  printf "%-15s: %s\n" "upload" "$upload_date"
  printf "%-15s: %s\n" "view" "$view_count"
  printf "%-15s: %s\n" "like" "$like_count"
  printf "%-15s: %s\n" "dislike" "$dislike_count"
  printf "%-15s: %s\n" "uploader" "$uploader"
  printf "%-15s: %s\n" "thumbnail" "$thumbnail"
  printf "%-15s: %s\n" "duration" "$duration"

  # Deletando o arquivo "data.info.json" -------------------------------------------------#
  # --------------------------------------------------------------------------------------#
  rm "$file"
}

main() {
  # Se o segundo argumento for nulo, mostre uma mensagem de erro -------------------------#
  # --------------------------------------------------------------------------------------#
  if [[ -z "$2" ]]; then
    echo -e "${red}Você precisa inserir uma URL para obter a tabela com as informações precisas.${default}"
    exit 1
  fi

  # Download da mídia --------------------------------------------------------------------#
  # --------------------------------------------------------------------------------------#
  youtube-dl --extract-audio --audio-format mp3 --output '%(title)s.%(ext)s' "$2"
}

# Se não há argumentos, retorne a função uso ---------------#
# ----------------------------------------------------------#
if [[ $# -eq 0 ]]; then
  usage
fi

# Parâmetros -----------------------------------------------#
# ----------------------------------------------------------#
while getopts 'h;t;u' parameter; do
  case "$parameter" in
    h) usage        ;;
    t) table "${@}" ;;
    u) main  "${@}" ;;
  esac
done

