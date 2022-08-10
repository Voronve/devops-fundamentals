#!/usr/bin/env bash
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


fileCheck ()
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
    local DB='../data/users.db'

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

    fileCheck $DB

    local CHECK_RESULT=$?

    if [ $CHECK_RESULT -eq 0 ]
    then
         printf "$USERNAME, $ROLE\n" >> $DB
         echo "Data was successfully saved!"
    else
        echo "Sorry data was not saved"
    fi
}	# ----------  end of function addingUser  ----------

if [ $1 == 'add' ];
then
    addingUser
else
    echo 'Its not an add argument'
fi
