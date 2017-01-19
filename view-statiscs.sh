#!/bin/bash

# This script extracts view statistics from your dspace
# Requires: OAI SOLR INDEX
# usage: ./view-statistics.sh <SOLR QUERY>
# Eg. ./view-statistics.sh dc.type:Article > view_statistics.txt # It will return all view statistics from Articles 
#     ./view-statistics.sh *:* > view_statistics.txt #it will return all view statistics from all dspace items

#URLS
SOLR_URL=http://localhost:8080/solr
SOLR_SEARCH=$SOLR_URL/search/select
SOLR_OAI=$SOLR_URL/oai/select
SOLR_STATISTICS=$SOLR_URL/statistics/select
#TMP FILES
TMP_FILE=tmp
HANDLE2ID_TMP=h2i
STATISTICS_TMP=sttmp

function main(){
  #PARAMS
  QUERY="$1"

  #ROUTINE
  wget -O $TMP_FILE "$SOLR_SEARCH?q=$QUERY&fq=discoverable:true&wt=csv&fl=handle,dc.identifier.uri&rows=200000" 2> /dev/null
  while IFS=, read handle uri
  do
    ID=$(handleToId $handle)
    echo $uri $(getViewStatistics $ID)
  done < $TMP_FILE

  rm $TMP_FILE
  rm $HANDLE2ID_TMP
  rm $STATISTICS_TMP
}

function handleToId(){
  #PARAMS
  handle="$1"

  #ROUTINE
  wget -O $HANDLE2ID_TMP "$SOLR_OAI?q=item.handle:$handle&wt=csv&fl=item.id&row=1" 2> /dev/null
  tail -1l $HANDLE2ID_TMP
}

function getViewStatistics(){
  #PARAMS
  id="$1"

  #ROUTINE
  wget -O $STATISTICS_TMP "$SOLR_STATISTICS?q=id:$id&wt=csv&fl=id&row=999999&fq=isBot:false&statistics_type:view" 2> /dev/null
  count=$(wc -l $STATISTICS_TMP | awk '{print $1}')
  echo $((count-1))
}

main "$1"
