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


ARG1=${1:-''}

jqCheck ()
{
    VERSION=$(jq --version)

    if [[ !($VERSION =~ ^jd-) ]]
    then
        printf "
        Your os doesnt't have installed JQ yet.
        you can install it with the next commands depends from your os:
        Windows - use \"Chocolatey NuGet\" to install jq 1.5 with command \"chocolatey install jq\"
        Linux:
        For Debian and Ubuntu - install using \"sudo apt-get install jq\"
        For Fedora - install using \"sudo dnf install jq\"
        For openSUSE - install using \"sudo zypper install jq\"
        For Arch - install using \"sudo pacman -S jq\"
        OS-X:
        Use Homebrew to install jq 1.6 with \"brew install jq\"
        Use MacPorts to install jq 1.6 with \"port install jq\"
        FreeBSD:
        \"pkg install jq\" as root installs a pre-built binary package.
        make -C /usr/ports/textproc/jq install clean as root installs the jq port from source.
        Solaris:
        \"pkgutil -i jq\" in OpenCSW for Solaris 10+, Sparc and x86.
        "
        exit 1
    fi
}	# ----------  end of function jqCheck  ----------


pathCheck ()
{
    if [[ "$1" == '' ]]
    then
        echo "You should set the path to the JSON file" >&2
        exit 1
    elif [[ "$1" =~ '-' ]]
    then
        echo "First argument must be path to JSON file" >&2
        exit 1
    elif [[ ! -f $1 ]]
    then
        echo "File is not exist" >&2
        exit 1
    else
        URL=$1
    fi
}	# ----------  end of function pathCheck  ----------


defaultActions ()
{
    JSON=$(
        cat $URL |
        jq 'del(.metadata)' |
        jq '.pipeline.version = (.pipeline.version + 1)'
    )
}	# ----------  end of function defaultActions  ----------


propValidate ()
{
    BRANCH_EXIST=$( echo $JSON | jq ".pipeline.stages[].actions[].configuration.Branch | if . == null then \"false\" else \"true\" end" )
    if [[ "$BRANCH_EXIST" =~ 'true' ]]
    then
        BRANCH_EXIST='true'
    fi

    OWNER_EXIST=$( echo $JSON | jq ".pipeline.stages[].actions[].configuration.Owner | if . == null then \"false\" else \"true\" end" )
    if [[ "$OWNER_EXIST" =~ 'true' ]]
    then
        OWNER_EXIST='true'
    fi

    POLL_EXIST=$( echo $JSON | jq ".pipeline.stages[].actions[].configuration.PollForSourceChanges | if . == null then \"false\" else \"true\" end" )
    if [[ "$POLL_EXIST" =~ 'true' ]]
    then
        POLL_EXIST='true'
    fi;

    ENV_EXIST=$( echo $JSON | jq ".pipeline.stages[].actions[].configuration.EnvironmentVariables | if . == null then \"false\" else \"true\" end" )
    if [[ "$ENV_EXIST" =~ 'true' ]]
    then
        ENV_EXIST='true'
    fi;

    PROP_ARR=($BRANCH_EXIST, $OWNER_EXIST, $POLL_EXIST, $ENV_EXIST);

    if [[ "${PROP_ARR[*]}" =~ 'false' ]]
    then
       echo "Not all data are in the object" >&2
       exit 1
    fi
}	# ----------  end of function propValidate  ----------



iterateVar ()
{
    STAGES=$( echo "${JSON}" | jq '.pipeline.stages | length' )
    ((STAGES--))

    for stageLine in $( seq 0 $STAGES )
    do
        ACTIONS=$( echo "${JSON}" | jq ".pipeline.stages[$stageLine].actions | length" )
        ((ACTIONS--))

        for line in $( seq 0 $ACTIONS )
        do
            CURRENT_ACTION=$( echo "${JSON}" | jq ".pipeline.stages[$stageLine].actions[$line]")
            IS_TRUE=$( echo "${CURRENT_ACTION}"| jq 'contains({configuration: {EnvironmentVariables: "BUILD"}})' )
            if [[ "$IS_TRUE" == true ]]
            then
                ENV=$(echo "${JSON}" | jq ".pipeline.stages[$stageLine].actions[$line].configuration.EnvironmentVariables | fromjson | .[0].value = \"$1\" | tostring")
                JSON=$(echo "${JSON}" | jq ".pipeline.stages[$stageLine].actions[$line].configuration.EnvironmentVariables = $ENV")
            fi
        done
    done
}	# ----------  end of function iterateVar  ----------

jqCheck
pathCheck "$ARG1"
defaultActions
propValidate

OPTS=$(getopt --long branch:,owner:,poll-for-source-changes:,configuration: -- "$@")
eval set -- "$OPTS"

EXIST="false"

while :
do
    case "$1" in
        --branch)
            JSON=$( echo $JSON | jq ".pipeline.stages[0].actions[0].configuration.Branch = \"$2\"")
            shift 2
            ;;
        --owner)
            JSON=$( echo $JSON | jq ".pipeline.stages[0].actions[0].configuration.Owner = \"$2\"")
            shift 2
            ;;
        --poll-for-source-changes)
            if [[ $2 == 'true' ]]
            then
                JSON=$( echo $JSON | jq ".pipeline.stages[0].actions[0].configuration.PollForSourceChanges = true")
            elif [[ $2 == 'false' ]]
            then
                JSON=$( echo $JSON | jq ".pipeline.stages[0].actions[0].configuration.PollForSourceChanges = false")
            fi
            shift 2
            ;;
        --configuration)
            iterateVar $2
            shift 2
            ;;
        --) shift; break
            ;;
        *) echo "Wrong argument $1"; break
    esac
done


echo "$JSON" > "$ARG1"
