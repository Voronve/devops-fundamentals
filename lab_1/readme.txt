  Usage: ./db.sh [OPTION] [OPTION]

  This script supports all neccessary commands for operating a users database.
  Use this script with a following arguments to perform appropriate actions 

  add			- Adds new user to the database. You will need to enter the username and it's role. All of them must be spelled in latin letters only
  help			- Showing this information (also available if enter ./db.sh command without any arguments)
  backup		- making a backup copy of database
  find			- finding a user by his name. You will need to enter the username. If there are multiple users with the same name in db, thay all will be found
  list	--inverse	- Printing the list of all users in db from the earliest to the latest. You can inversify this order by passing additional parameter --inverse
