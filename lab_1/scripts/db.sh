#===============================================================================
#
#          FILE: db.sh
#
#         USAGE: ./db.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: KOS (ADMIN), voronve1987@gmail.com
#  ORGANIZATION: EPAM
#       CREATED: 10.08.22 21:42:35
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
CURRENT_DIR="$( dirname -- "$0" )"
DB_DIR="$CURRENT_DIR/../data/"
DB="$DB_DIR/users.db"
ARG1=${1:-'default'}
ARG2=${2:-'default'}


createFile ()
{
    if [ -f "$1" ]
    then
        return 0
    else
        echo "The $1 file is not exist yet. Do you want to create it? (y/n)"

        local YESNO=''
        until [ "$YESNO" = "y" ] || [ "$YESNO" = "n" ];
        do
            read YESNO
        done

        if [ "$YESNO" = "n"  ]
        then
            return 1
        else
            touch $1
            chmod 755 $1
        fi
    fi

}	# ----------  end of function fileCheck  ----------

addingUser ()
{
    local USERNAME=''
    local ROLE=''

    until [[ $USERNAME =~ ^[A-Za-z]+$ ]];
    do
        echo "Enter username. Please, use only latin letters"
        read USERNAME
    done

    until [[ $ROLE =~ ^[A-Za-z]+$ ]];
    do
        echo "Enter role. Please, use only latin letters"
        read ROLE
    done

    createFile $DB

    local CHECK_RESULT=$?

    if [ $CHECK_RESULT -eq 0 ]
    then
         printf "$USERNAME, $ROLE\n" >> $DB
         echo "Data was successfully saved!"
    else
        echo "Sorry data was not saved"
    fi
}	# ----------  end of function addingUser  ----------


backupDB ()
{
    cp $DB "$DB_DIR$( date +%m-%d-%y\(%k:%M\) )-users.db.backup"
    echo "DB was successfully saved"
}	# ----------  end of function backupDB  ----------


searchUser ()
{
    n=0
    local USERNAME=''
    until [[ $USERNAME =~ ^[A-Za-z]+$ ]];
    do
        echo "Enter username to search in db. Please, use only latin letters"
        read USERNAME
    done

    while read line
    do
        STR_ARR=( ${line//,/} )

        if [ ${STR_ARR[0]} = $USERNAME ]
        then
            ((n++))
            echo "Name: ${STR_ARR[0]} Role: ${STR_ARR[1]}"
        fi
    done < $DB

    if [ $n -eq 0 ]
    then
        echo "User not found"
    fi

}	# ----------  end of function searchUser  ----------


restoreDB ()
{
    BACKUP_ARR=( $(ls "$DB_DIR" | sort -r) )

    if [ ${#BACKUP_ARR[@]} -le 1 ]
    then
        echo "No backub file found"
        return 1
    fi
    cp "$DB_DIR${BACKUP_ARR[1]}" $DB
    echo "Backup was sucessfully used"
}	# ----------  end of function restoreDB  ----------


usersList ()
{
    n=0
    USERS=()

    while read line
    do
        USERS[$n]="$((++n)). $line"
    done < $DB

    if [ $1 == '--inverse' ]
    then
        for (( index=$n; index>0; index-- ))
        do
            echo ${USERS[$index]}
        done
    else
        for user in "${USERS[@]}"
        do
            echo $user
        done
    fi
}	# ----------  end of function usersList  ----------


helpInfo ()
{
    cat "$CURRENT_DIR/../readme.txt"
}	# ----------  end of function helpInfo  ----------

case "$ARG1" in
    add)
        addingUser;;
    backup)
        backupDB;;
    restore)
        restoreDB;;
    find)
        searchUser;;
    list)
        usersList $ARG2;;
    help | *)
        helpInfo;;
esac
