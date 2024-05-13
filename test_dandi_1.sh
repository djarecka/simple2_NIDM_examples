#!/bin/bash

set -eu
set -o pipefail

# 1. creat ttl from jsonld
#find  "/Users/dorota/dandi_repos/data_query_test/" -type f -name '*.jsonld' -exec sh -c '
#for file do
#   echo "$file"
#  reproschema convert --format turtle  "$file" > "${file%.jsonld}.ttl"
#done
#' sh {} +


# 2. to upload all the turtle files, from the root of this repo do:
#    Using GNU parallel to expedite it a little
#    Need to exclude data-config.ttl which is a config file for graphDB
find "/Users/dorota/dandi_repos/data_query_test/" -name "*.ttl" \
    | parallel --halt now,fail=1 --jobs 4 --cf --bar './upload.sh {}'

# Serial way
# We need to trick xargs to exit as soon as first command to fail.
#    | xargs '-I{}' sh -c './upload.sh '{}' || exit 255'

# 3,4. Run the query
output=queries/dandi1_gb.csv
/usr/bin/time curl --silent -X POST "${GRAPHDB_QUERY_URL}" --data-binary '@queries/dandi1.sparql' -H 'Accept: text/csv' -H "Content-Type: application/sparql-query" >| "$output"
    

