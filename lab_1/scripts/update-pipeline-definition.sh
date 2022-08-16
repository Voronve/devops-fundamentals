#!/usr/bin/env bash
#===============================================================================
#
#          FILE: update-pipeline-definition.sh
#
#         USAGE: ./update-pipeline-definition.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: KOS (ADMIN), voronve1987@gmail.com
#  ORGANIZATION: EPAM
#       CREATED: 16.08.22 10:32:39
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

JSON=$(
    cat ../data/pipeline.json |
    jq 'del(.metadata)' |
    jq '.pipeline.version = (.pipeline.version + 1)' |
    jq '.pipeline.stages[0].actions[0].configuration.Branch = "develop"' |
    jq '.pipeline.stages[0].actions[0].configuration.Owner = "Kos"' |
    jq '.pipeline.stages[0].actions[0].configuration.PollForSourceChanges = false'
)



#JSON=$( echo "${JSON}" | jq 'del(.metadata)' )
#JSON=$( echo "${JSON}" | jq '.pipeline.version = (.pipeline.version + 1)' )
echo "$JSON"
