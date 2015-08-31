#!/usr/bin/env bash
###########################################################################
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
# http://www.gnu.org/copyleft/gpl.html
#
# Descrição: Script para a criação de diretórios contendo os arquivos 
# "contents" e "dublin_core.xml" a partir de arquivos PDF coletados para 
# inclusão no DSpace. 
# Os nomes dos arquivos PDF devem estar de acordo com o metadado ecolhido
# ("dc.identifier.file" por padrão), presentes nos itens do DSpace.
#
# Uso: "./generateSafPackageFromPdf.sh pdfs out", onde "pdfs" é o diretório 
# que contém os arquivos PDF coletados e "out" é o diretório de saída.
#
# Author: vitorsilverio
# Author: jaideraf
#
# Last update: 2015-08-31
###########################################################################

function checkMetadataToUse {
        if [ -z "$1" ]
        then
                metadata="dc.identifier.file"
        else
                metadata="$1"
        fi

        IFS='.' read -a m <<< "$metadata"

        schema="${m[0]}"
        element="${m[1]}"
        qualifier="${m[2]}"

}

function makeDirectoryName {
        printf "item_%05d" "$1"
}

function makeContentsFile {
        printf "%s\tbundle:ORIGINAL" "$1" > "$2"/contents
}

function makeDCxmlFile {
        checkMetadataToUse "$3"
        printf "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>\n<dublin_core schema=\"$schema\">\n  <dcvalue element=\"$element\" qualifier=\"$qualifier\" language=\"\">%s</dcvalue>\n</dublin_core>" "$1" > "$2"/dublin_core.xml
}

function main {
        CONT=1
        DIR_PDF=$1
        DIR_OUT=$2
        METADATA=$3

        for pdf in $DIR_PDF/*.pdf
        do
                PCKG_DIR="$DIR_OUT"/$(makeDirectoryName "$CONT")
                mkdir "$PCKG_DIR"
                cp "$pdf" "$PCKG_DIR"
                makeContentsFile "${pdf/*\//}" "$PCKG_DIR"
                makeDCxmlFile "${pdf/*\//}" "$PCKG_DIR" "$METADATA"
                CONT=$((CONT+1))
        done
}

main "$1" "$2" "$3"
