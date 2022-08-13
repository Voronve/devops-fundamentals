#!/usr/bin/env bash
#===============================================================================
#
#          FILE: build-client.sh
#
#         USAGE: ./build-client.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: KOS (ADMIN), voronve1987@gmail.com
#  ORGANIZATION: EPAM
#       CREATED: 13.08.22 22:33:12
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

ENV_CONFIGURATION=${1:-''}

cd ../shop-angular-cloudfront/
npm i

if [[ $ENV_CONFIGURATION != 'production' ]]
then
    ENV_CONFIGURATION=''
fi


if [[ -f ./dist/client-app.zip  ]]
then
    rm ./dist/client-app.zip
fi

npm run build --configuration=$ENV_CONFIGURATION
cd ./dist
zip -r client-app.zip app
