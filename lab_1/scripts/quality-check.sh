#!/usr/bin/env bash
#===============================================================================
#
#          FILE: quality-check.sh
#
#         USAGE: ./quality-check.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: KOS (ADMIN), voronve1987@gmail.com
#  ORGANIZATION: EPAM
#       CREATED: 14.08.22 22:33:49
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

cd "$( dirname -- "$0" )/../shop-angular-cloudfront"

stopPrint=0

echo "Next errors were found in project:"
echo
while read -r testLine
do

    if [[ "$testLine" =~ .*[Ee]rror:.* ]] && [[ $stopPrint -eq 0 ]]
    then
        echo "$testLine"
    fi

    if [[ "$testLine" =~ .*TOTAL.* ]]
    then
        echo "$testLine"
        stopPrint=1
    fi
done < <(npm run test)

echo
echo "Next errors were found during linter scanning:"
echo
while read -r linterLine
do
    if [[ "$linterLine" =~ .*[Ee]rror\ + ]]
    then
        echo "$linterLine"
    fi
done < <(npm run lint)

echo
echo "NPM audit report:"
echo
while read -r auditLine
do
    if [[ "$auditLine" =~ vulnerabilities ]]
    then
        echo "$auditLine"
    fi
done < <(npm audit)
