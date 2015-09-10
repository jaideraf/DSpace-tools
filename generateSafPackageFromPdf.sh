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
# Opcionalmente, há o terceiro parâmetro para especificar o metadado 
# utilizado: "./generateSafPackageFromPdf.sh pdfs out metadado"
# 
# Author: vitorsilverio
# Author: jaideraf
#
# Last update: 2015-09-01
###########################################################################

function checkMetadataToUse {
        
        #Params
        local _metadata="$1"
        
        if [ -z "$_metadata" ]
        then
                metadata="dc.identifier.file"
        else
                metadata="$_metadata"
        fi

        IFS='.' read -ra m <<< "$metadata"

        schema="${m[0]}"
        element="${m[1]}"
        qualifier="${m[2]}"
}

function makeDirectoryName {
        
        #Params
        local _number="$1"
        
        printf "item_%05d" "$_number"
}

function makeContentsFile {
        
        #Params
        local _file="$1"
        local _path="$2"
        
        printf "%s\tbundle:ORIGINAL" "$_file" > "$_path"/contents
}

function makeDCxmlFile {
        
        #Params
        local _file="$1"
        local _path="$2" 
        local _metadata="$3"
        
        checkMetadataToUse "$_metadata"
        printf "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>\n<dublin_core schema=\"$schema\">\n  <dcvalue element=\"$element\" qualifier=\"$qualifier\" language=\"\">%s</dcvalue>\n</dublin_core>" "$_file" > "$_path"/dublin_core.xml
}

function main {
        
        #Params
        local _pdf_dir="$1"
        local _output_dir="$2"
        local _metadata="$3"
        
        #Local Variables
        local count=1

        for pdf in $_pdf_dir/*.pdf
        do
                PCKG_DIR="$_output_dir"/$(makeDirectoryName "$count")
                mkdir "$PCKG_DIR"
                cp "$pdf" "$PCKG_DIR"
                makeContentsFile "${pdf/*\//}" "$PCKG_DIR"
                makeDCxmlFile "${pdf/*\//}" "$PCKG_DIR" "$_metadata"
                count=$((count+1))
        done
}

# Params
# 1 - pdfs path
# 2 - output path
# 3 - metadata (optional)
main "$1" "$2" "$3"
